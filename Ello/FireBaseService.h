//
//  FireBaseService.h
//  Ello
//
//  Created by vd-rahim on 1/14/18.
//  Copyright © 2018 vd-rahim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "UserChattingViewController.h"
#import "MessageHistoryViewController.h"
#import "UserModel.h"

@class UserChattingViewController;

@interface FireBaseService : NSObject{
    FIRDatabaseReference *fireBaseRef;
    FIRStorage *firebaseStorage;
}
- (id)initWithPath:(NSString *)path;
- (NSString *)getUserID;
- (void)updateFireBaseRefPath:(NSString *)path;
- (BOOL)isUserLoggedIn;
- (void)observeMessage:(UserChattingViewController *)vc;
- (void)isUSerExist:(NSString *)username password:(NSString *)password andCompletionHandler:(void (^)(bool result))completionHandler;
- (void)sendMessage:(NSString *)message user1:(NSString *)user1 user2:(NSString *)user2 media:(NSNumber *)media time:(NSDate *)time;
- (void)storeImageInFireBaseStorage:(NSData *)data user1:(NSString *)user1 user2:(NSString *)user2;
- (void)addMessageToMessageHistoryIfNotExist:(NSString *)msgPath uid:(NSString *)uid;
- (void)getMessageHistory:(MessageHistoryViewController *)messageHistoryVC;
- (void)addUserDetailsIfNotExist:(NSString *)displayName photoUrl:(NSURL *)photoUrl email:(NSString *)email;
- (void)getUserModelFromFirebase:(NSString *)userId withSuccess:(void(^)(UserModel *user))success andFailure:(void(^)(NSError *error))failure;
@end
