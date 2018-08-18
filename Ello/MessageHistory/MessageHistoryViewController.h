//
//  MessageHistoryViewController.h
//  Ello
//
//  Created by vd-rahim on 10/28/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseAuth/FirebaseAuth.h>

@class FireBaseService;

@interface MessageHistoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSString *userId;
    FireBaseService *firebaseService;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *message;

- (void)updateMessageHistory:(NSDictionary *)msgDict msgID:(NSString *)msgID;
@end
