//
//  Utils.h
//  Ello
//
//  Created by vd-rahim on 1/27/18.
//  Copyright © 2018 vd-rahim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlatformUtils : NSObject

+ (BOOL)isSimulator;

@end

@interface TokenUtils : NSObject

+ (void)retrieveAccessTokenFromURL:(NSString *)tokenURLStr
                        completion:(void (^)(NSString* token, NSError *err)) completionHandler;

@end
