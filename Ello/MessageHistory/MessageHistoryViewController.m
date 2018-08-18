//
//  MessageHistoryViewController.m
//  Ello
//
//  Created by vd-rahim on 10/28/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "MessageHistoryViewController.h"
#import "ChatHistoryTableViewCell.h"
#import "UserChattingViewController.h"
#import "MessageHistorySearchBar.h"
#import "MessageModel.h"
#import "LoginViewController.h"
#import "NSDate+Formatter.h"
#import "UserModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MessageHistoryViewController (){
    NSString *uid;
}
@end

@implementation MessageHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupTableView];
    _message = [[NSMutableArray alloc] init];
    firebaseService = [[FireBaseService alloc] init];
    NSString *uid = [firebaseService getUserID];
    if(uid){
        userId = uid;
        [firebaseService updateFireBaseRefPath:[NSString stringWithFormat:@"%@/message",uid]];
        [self getUserMessage];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)updateMessageHistory:(NSDictionary *)msgDict msgID:(NSString *)msgID{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID = %@",msgID];
    //TODO
    NSArray *mes = [_message filteredArrayUsingPredicate:predicate];
    
    if(mes.count>0)
        [_message removeObject:mes[0]];
    if([userId isEqualToString:msgDict[@"user1"]]){
        
        MessageModel *message = [[MessageModel alloc] initIMessageWithName:@"Rahim" messageID:msgID message:msgDict[@"message"] time:msgDict[@"time"] type:msgDict[@"type"] mediaImage:msgDict[@"media"] user1:msgDict[@"user1"] user2:msgDict[@"user2"]];
        [_message addObject:message];
    }else{
        MessageModel *message = [[MessageModel alloc] initIMessageWithName:@"Rahim" messageID:msgID message:msgDict[@"message"] time:msgDict[@"time"] type:msgDict[@"type"] mediaImage:msgDict[@"media"] user1:msgDict[@"user1"] user2:msgDict[@"user2"]];
        [_message addObject:message];
    }
    [_tableView reloadData];
}

- (ChatHistoryTableViewCell *)setupNib:(ChatHistoryTableViewCell *)cell{
    ChatHistoryTableViewCell *tableCell = [[[NSBundle mainBundle] loadNibNamed:@"ChatHistoryCell" owner:self options:nil] objectAtIndex:0];
    cell = tableCell;
    return cell;
}

- (IBAction)logoutUserButtonTapped:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    [[GIDSignIn sharedInstance] signOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    LoginViewController *add =
    [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    [self presentViewController:add
                       animated:YES
                     completion:nil];
}

- (void)setupUI{
    
}

- (void)setupTableView{
    ChatHistoryTableViewCell *searchBar = [[[NSBundle mainBundle] loadNibNamed:@"MessageHistorySearchBar" owner:self options:nil] objectAtIndex:0];
    self.tableView.tableHeaderView = searchBar;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - TableView Functions.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _message.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatHistoryTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatHistoryCell" owner:self options:nil] objectAtIndex:0];
    cell.userImage.image = [UIImage imageNamed:@"dummyUser"];
    MessageModel *msg = (MessageModel *)_message [indexPath.row];
    [firebaseService getUserModelFromFirebase:msg.user1 withSuccess:^(UserModel *user) {
        cell.userName.text = user.name;
        [cell.userImage setImageWithURL:[NSURL URLWithString:user.imgUrl] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.msgText.text = msg.userMessage;
    } andFailure:^(NSError *error) {
        
    }];



    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-mm-dd hh:mm:ss"];
    NSDate *date = [dateFormat dateFromString:msg.userTime];
    cell.msgTime.text = [NSDate GenerateMessageHistoryDate:date];
    return cell;
}

- (void)getUserMessage{
    
    [firebaseService getMessageHistory:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[self performSegueWithIdentifier:@"showDetailsSegue" sender:tableView];
    
    UIStoryboard *chattingStoryboard = [UIStoryboard storyboardWithName:@"ChattingStoryboard" bundle:[NSBundle mainBundle]];
    UserChattingViewController *chattingVC = [chattingStoryboard instantiateViewControllerWithIdentifier:@"UserChattingViewController"];
    NSString *user1 = [(MessageModel *)_message[indexPath.row] user1];
    NSString *user2 = [(MessageModel *)_message[indexPath.row] user2];
    if([[firebaseService getUserID] isEqualToString:user1])
        chattingVC.friendID = user2;
    else
        chattingVC.friendID = user1;
    [self.navigationController pushViewController:chattingVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
