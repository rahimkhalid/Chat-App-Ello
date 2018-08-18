//
//  FriendsTableViewCell.m
//  Ello
//
//  Created by vd-rahim on 11/29/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "FriendsTableViewCell.h"

@implementation FriendsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupUI{
    self.userImage.layer.cornerRadius = _userImage.bounds.size.width/2;
    _userImage.layer.masksToBounds = YES;
}

@end
