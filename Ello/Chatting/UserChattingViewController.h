//
//  UserChattingViewController.h
//  Ello
//
//  Created by vd-rahim on 10/28/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FireBaseService.h"

@class FireBaseService;

@interface UserChattingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UITextViewDelegate >{
    FireBaseService *firebaseService;
    NSArray *users;
}

@property (weak, nonatomic) IBOutlet UIButton *sendMessageBtn;
@property (weak, nonatomic) NSString *friendID;
- (void)showMessageBubble:(NSString *)name message:(NSString *)message time:(NSString *)time type:(NSString *)type mediaType:(BOOL)mediaType user1:(NSString *)user1 user2:(NSString *)user2;

@end
