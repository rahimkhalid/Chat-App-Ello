//
//  MessageModel.h
//  Ello
//
//  Created by vd-rahim on 11/18/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel: NSObject

-(id) initIMessageWithName:(NSString *)name
                 messageID:(NSString *)messageID
                   message:(NSString *)message
                      time:(NSString *)time
                      type:(NSString *)type
                mediaImage:(BOOL)mediaImage
                     user1:(NSString *)user1
                     user2:(NSString *)user2;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userMessage;
@property (strong, nonatomic) NSString *userTime;
@property (strong, nonatomic) NSString *messageType;
@property (nonatomic) BOOL mediaImage;
@property (nonatomic) NSString *user1;
@property (nonatomic) NSString *user2;
@property (nonatomic) NSString *messageID;


@end
