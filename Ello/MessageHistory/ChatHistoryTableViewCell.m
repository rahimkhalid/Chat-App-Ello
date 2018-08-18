//
//  ChatHistoryTableViewCell.m
//  Ello
//
//  Created by vd-rahim on 10/22/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "ChatHistoryTableViewCell.h"

@implementation ChatHistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
    
}

- (void)setupUI{
    _userImage.layer.cornerRadius = _userImage.bounds.size.width/2;
    _userImage.layer.masksToBounds = YES;
    
    _isOnlineView.layer.cornerRadius = _isOnlineView.bounds.size.width/2;
    _isOnlineView.layer.masksToBounds = YES;
    
    _userImage.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    _userImage.layer.borderWidth = 2.0f;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
