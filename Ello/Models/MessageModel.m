//
//  MessageModel.m
//  Ello
//
//  Created by vd-rahim on 11/18/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

-(id) initIMessageWithName:(NSString *)name
                 messageID:(NSString *)messageID
                   message:(NSString *)message
                      time:(NSString *)time
                       type:(NSString *)type
                mediaImage:(BOOL )mediaImage
                     user1:(NSString *)user1
                     user2:(NSString *)user2
{
    self = [super init];
    if(self)
    {
        self.userName = name;
        self.userMessage = message;
        self.userTime = time;
        self.messageType = type;
        self.mediaImage = mediaImage;
        self.user1 = user1;
        self.user2 = user2;
        self.messageID = messageID;
    }
    
    return self;
}

@end

