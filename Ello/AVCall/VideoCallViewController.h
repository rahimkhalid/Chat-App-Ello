//
//  VideoCallViewController.h
//  Ello
//
//  Created by vd-rahim on 1/27/18.
//  Copyright © 2018 vd-rahim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCallViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *micBtn;
@property (weak, nonatomic) IBOutlet UIButton *callEndButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (strong, nonatomic) NSString *callIdentifier;
@property (strong, nonatomic) NSString *userIdentifier;

- (void)setCallIdentifier:(NSString *)userIden callIdentifier:(NSString *)callIdentifier;
@end
