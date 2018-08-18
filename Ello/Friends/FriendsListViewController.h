//
//  FriendsListViewController.h
//  Ello
//
//  Created by vd-rahim on 11/29/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseStorage/FirebaseStorage.h>

@interface FriendsListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *users;
    FIRStorage *storage;
    FIRUser *firUser;
}

@property (strong, nonatomic) FIRDatabaseReference *fireBaseRef;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
