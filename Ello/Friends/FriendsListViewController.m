//
//  FriendsListViewController.m
//  Ello
//
//  Created by vd-rahim on 11/29/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendsTableViewCell.h"
#import "UserModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserChattingViewController.h"

@interface FriendsListViewController ()

@end

@implementation FriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fireBaseRef = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"user"]];
    users = [[NSMutableArray alloc] init];
    [self observeMessage];
    firUser = [FIRAuth auth].currentUser;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Functions.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FriendsTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendsTableViewCell" owner:self options:nil] objectAtIndex:0];
    cell.userName.text = ((UserModel *)users[indexPath.row]).name;
    
    [cell.userImage sd_setImageWithURL:[NSURL URLWithString:((UserModel *)users[indexPath.row]).imgUrl]
                           placeholderImage:[UIImage imageNamed:@"placeholder.png"]  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                               
                               
                           }];
    return cell;
}

- (void)getUserMessage{
    [[self.fireBaseRef child:[NSString stringWithFormat: @"message/user-%@",@"rahim"]] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *usersDict = snapshot.value;
        
        NSLog(@"Info : %@",usersDict);
        for(NSDictionary *msg in usersDict){
            NSTEasyJSON *userJson = [NSTEasyJSON withObject:msg];
            NSLog(@"%@", [userJson dictionary]);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[self performSegueWithIdentifier:@"showDetailsSegue" sender:tableView];
    
    UIStoryboard *chattingStoryboard = [UIStoryboard storyboardWithName:@"ChattingStoryboard" bundle:[NSBundle mainBundle]];
    
    UserChattingViewController *chattingVC = [chattingStoryboard instantiateViewControllerWithIdentifier:@"UserChattingViewController"];
    chattingVC.friendID = ((UserModel *)users[indexPath.row]).uID;
    [self.navigationController pushViewController:chattingVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)observeMessage{
    FIRDatabaseQuery *messageQuery = [_fireBaseRef queryLimitedToLast:25];
    [messageQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *userDict = snapshot.value;
        NSLog(@"%@",userDict);
        UserModel *user = [[UserModel alloc] initWithData:userDict[@"name"] imgUrl:userDict[@"imageUrl"] email:userDict[@"email"] uID:userDict[@"uid"]];
        if(![user.uID isEqualToString:firUser.uid]){
            [users addObject:user];
            [_tableView reloadData];
        }
    }];
}
@end
