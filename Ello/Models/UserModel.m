//
//  UserModel.m
//  Ello
//
//  Created by vd-rahim on 11/29/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

-(instancetype)initWithData:(NSString *)name imgUrl:(NSString *)imgUrl email:(NSString *)email uID:(NSString *)uID{
    if(self = [super init]){
        _name = name;
        _imgUrl = imgUrl;
        _email = email;
        _uID = uID;
    }
    return self;
}

@end
