//
//  FireBaseService.m
//  Ello
//
//  Created by vd-rahim on 1/14/18.
//  Copyright © 2018 vd-rahim. All rights reserved.
//

#import "FireBaseService.h"

@implementation FireBaseService

- (id)init{
    if(self=[super init]){
        fireBaseRef = [[FIRDatabase database] reference];
    }
    return self;
}

- (id)initWithPath:(NSString *)path{
    if(self = [self init]){
        fireBaseRef = [[[FIRDatabase database] reference] child:path];
    }
    return  self;
}

- (void)updateFireBaseRefPath:(NSString *)path{
    fireBaseRef = [[[FIRDatabase database]reference] child:path];
}

- (NSString *)getUserID{
    FIRUser *user = [FIRAuth auth].currentUser;
    if (user)
        return user.uid;
    return nil;
}

- (BOOL)isUserLoggedIn{
    if([FIRAuth auth].currentUser)
        return true;
    return false;
}

- (void)addUserDetailsIfNotExist:(NSString *)displayName photoUrl:(NSURL *)photoUrl email:(NSString *)email{
    
    [self updateFireBaseRefPath:[NSString stringWithFormat: @"user/%@",[self getUserID]]];
                [fireBaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    
                    NSDictionary *record = snapshot.value;
                    if([record isKindOfClass:[NSNull class]]) {
                        [fireBaseRef setValue:@{@"name": displayName,
                                                @"imageUrl":[photoUrl absoluteString],
                                                @"uid":[self getUserID],
                                                @"email":email
                                                }];
                    }
                }];
    
    //FIRDatabaseReference *fireBaseRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat: @"user/%@",user.uid]];
    
}

- (void)isUSerExist:(NSString *)username password:(NSString *)password andCompletionHandler:(void (^)(bool result))completionHandler{
    
    [[fireBaseRef child:[NSString stringWithFormat: @"user/user-%@",username]] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *usersDict = snapshot.value;
        
        NSLog(@"Info : %@",usersDict);
        
        NSTEasyJSON *userJson = [NSTEasyJSON withObject:usersDict];
        if([userJson[@"username"].stringValue isEqualToString:username] && [userJson[@"password"].stringValue isEqualToString:password])
            completionHandler(YES);
        else
            completionHandler (NO);
        
    }];
}

- (void)observeMessage:(UserChattingViewController *)vc{
    FIRDatabaseQuery *messageQuery = [fireBaseRef queryLimitedToLast:25];
    [messageQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *messageDict = snapshot.value;
        NSLog(@"%@",messageDict);
        
        if([messageDict[@"user1"] isEqualToString:[self getUserID]])
            [vc showMessageBubble:@"Rahim" message:messageDict[@"message"] time:@"23:14" type:@"self" mediaType:[messageDict[@"media"] boolValue] user1:messageDict[@"user1"] user2:messageDict[@"user2"]];
        else
            [vc showMessageBubble:@"Rahim" message:messageDict[@"message"] time:@"23:14" type:@"other" mediaType:[messageDict[@"media"] boolValue] user1:messageDict[@"user1"] user2: messageDict[@"user2"]];
        
    }];
}

- (void)sendMessage:(NSString *)message user1:(NSString *)user1 user2:(NSString *)user2 media:(NSNumber *)media time:(NSDate *)time{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *date = [dateFormat stringFromDate:time];
    [fireBaseRef.childByAutoId setValue:@{@"message": message,
                                               @"user1":user1,
                                          @"user2":user2,
                                               @"media":media,
                                          @"time":date
                                               }];
}

- (void)addMessageToMessageHistoryIfNotExist:(NSString *)msgPath uid:(NSString *)uid{
    FIRDatabaseReference *tempRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"user/%@/messages",uid]];
    [tempRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //NSLog(@"test   %@",snapshot.value);
        NSArray *resultArray = [[NSArray alloc] init];
        if(![snapshot.value isKindOfClass:[NSNull class]]){
            resultArray = [[snapshot.value allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(messagesPath == %@)",msgPath]];
            
        }
        if(resultArray.count<=0)
            [tempRef.childByAutoId setValue:@{@"messagesPath":msgPath}];
        
    }];
    
}

- (void)storeImageInFireBaseStorage:(NSData *)data user1:(NSString *)user1 user2:(NSString *)user2{
    firebaseStorage = [FIRStorage storageWithURL:@"gs://ello-f8b2b.appspot.com"];
    FIRStorageReference *storageRef = [firebaseStorage reference];
    
    FIRStorageReference *riversRef = [storageRef child:[NSString stringWithFormat:@"images/%@",[NSDate date]]];
    [riversRef putData:data
                                                 metadata:nil
                                               completion:^(FIRStorageMetadata *metadata,
                                                            NSError *error) {
                                                   if (error != nil) {
                                                       // Uh-oh, an error occurred!
                                                       NSLog(@"image not uploaded");
                                                   } else {
                                                       // Metadata contains file metadata such as size, content-type, and download URL.
                                                       NSURL *downloadURL = metadata.downloadURL;
                                                       [self sendMessage:[downloadURL absoluteString] user1:user1 user2:user2 media:@YES time:[NSDate date]];
                                                       
                                                       NSLog(@"image uploaded URL is %@",downloadURL);
                                                   }
                                               }];
}

- (void)fetchMessageHistory:(NSString *)path messageHistory:(MessageHistoryViewController *)messageHistory{
    FIRDatabaseReference *tempRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@/message",path]];
    FIRDatabaseQuery *messageQuery = [tempRef queryLimitedToLast:1];
    [messageQuery observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *messageDict = snapshot.value;
        if(![messageDict isKindOfClass:[NSNull class]]){
            for (NSString* key in messageDict) {
                [messageHistory updateMessageHistory:[messageDict objectForKey:key] msgID:path];
            }
            
        }
    }];
}

- (void)getMessageHistory:(MessageHistoryViewController *)messageHistoryVC{
    FIRDatabaseReference *tempRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"user/%@/messages",[self getUserID]]];
    
    [tempRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *messageDict = snapshot.value;
        NSLog(@"%@",messageDict);
        if(![messageDict isKindOfClass:[NSNull class]]){
            [messageHistoryVC.message removeAllObjects];
            for (NSString* key in messageDict) {
                NSString *value = [(NSDictionary *)[messageDict objectForKey:key] objectForKey:@"messagesPath"];
                [self fetchMessageHistory:value messageHistory:messageHistoryVC];
            }
            
        }
    }];

}
- (void)getUserModelFromFirebase:(NSString *)userId withSuccess:(void(^)(UserModel *user))success andFailure:(void(^)(NSError *error))failure{
    
    FIRDatabaseReference *tempRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"user/%@",userId]];
    [tempRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(![snapshot.value isKindOfClass:[NSNull class]]){
            UserModel *user = [[UserModel alloc] initWithData:snapshot.value[@"name"] imgUrl:snapshot.value[@"imageUrl"] email:snapshot.value[@"email"] uID:userId];
            success(user);
        }else{
            failure(nil);
        }
    }];
}

@end
