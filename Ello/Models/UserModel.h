//
//  UserModel.h
//  Ello
//
//  Created by vd-rahim on 11/29/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic) NSString* name;
@property (nonatomic) NSString* imgUrl;
@property (nonatomic) BOOL isFriend;
@property (nonatomic) NSString* email;
@property (nonatomic) NSString* uID;

- (instancetype)initWithData:(NSString *)name imgUrl:(NSString *)imgUrl email:(NSString *)email uID:(NSString *)uID;
@end
