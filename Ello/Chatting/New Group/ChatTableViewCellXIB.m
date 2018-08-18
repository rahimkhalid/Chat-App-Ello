//
//  ChatTableViewCellXIB.m
//  iMessageBubble
//
//  Created by Prateek Grover on 19/09/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import "ChatTableViewCellXIB.h"

@implementation ChatTableViewCellXIB

@synthesize chatUserImage;
@synthesize chatMessageLabel;
@synthesize chatNameLabel;
@synthesize chatTimeLabel;
@synthesize mediaImage;
@synthesize mediaImageLoadIndicator;
@synthesize mainView;
@synthesize tailcurve;

- (void)awakeFromNib {
    [super awakeFromNib];
    mediaImage.image = nil;
}
@end
