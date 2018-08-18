//
//  UIColor+Hex.m
//  Ello
//
//  Created by vd-rahim on 10/29/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *) colorFromHex : (NSUInteger)hexValue{
    
    return [UIColor colorWithRed:((CGFloat)((hexValue & 0xff0000) >> 16)) / 255.0 \
                           green:((CGFloat)((hexValue & 0x00ff00) >> 8)) / 255.0  \
                            blue:((CGFloat)((hexValue & 0x0000ff) >> 0)) / 255.0  \
                           alpha:1.0];
}

@end
