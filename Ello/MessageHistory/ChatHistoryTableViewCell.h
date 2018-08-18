//
//  ChatHistoryTableViewCell.h
//  Ello
//
//  Created by vd-rahim on 10/22/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatHistoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *msgText;
@property (weak, nonatomic) IBOutlet UIView *isOnlineView;
@property (weak, nonatomic) IBOutlet UILabel *msgTime;

@end
