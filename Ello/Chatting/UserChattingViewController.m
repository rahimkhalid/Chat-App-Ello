	//
//  UserChattingViewController.m
//  Ello
//
//  Created by vd-rahim on 10/28/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "UserChattingViewController.h"
#import "ContentView.h"
#import "ChatTableViewCellXIB.h"
#import "ChatCellSettings.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Hex.h"
#import "MessageModel.h"
#import "VideoCallViewController.h"

@interface UserChattingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *chatTable;
@property (weak, nonatomic) IBOutlet ContentView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;

/*Uncomment second line and comment first to use XIB instead of code*/
//@property (strong,nonatomic) ChatTableViewCell *chatCell;
@property (strong,nonatomic) ChatTableViewCellXIB *chatCell;


@property (strong,nonatomic) ContentView *handler;


@end

@implementation UserChattingViewController
{
    NSMutableArray *currentMessages;
    ChatCellSettings *chatCellSettings;
    NSString *uid;
}
@synthesize chatCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentMessages = [[NSMutableArray alloc] init];
    chatCellSettings = [ChatCellSettings getInstance];
    [chatCellSettings setSenderBubbleColorHex:@"007AFF"];
    [chatCellSettings setReceiverBubbleColorHex:@"DFDEE5"];
    [chatCellSettings setSenderBubbleNameTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleNameTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleMessageTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleMessageTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleTimeTextColorHex:@"FFFFFF"];
    [chatCellSettings setReceiverBubbleTimeTextColorHex:@"000000"];
    
    [chatCellSettings setSenderBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:11]];
    [chatCellSettings setReceiverBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:11]];
    [chatCellSettings setSenderBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:14]];
    [chatCellSettings setReceiverBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:14]];
    [chatCellSettings setSenderBubbleFontWithSizeForTime:[UIFont systemFontOfSize:11]];
    [chatCellSettings setReceiverBubbleFontWithSizeForTime:[UIFont systemFontOfSize:11]];
    
    [chatCellSettings senderBubbleTailRequired:YES];
    [chatCellSettings receiverBubbleTailRequired:YES];
    
    self.navigationItem.title = @"Rahim";
    
    [[self chatTable] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    firebaseService = [[FireBaseService alloc] init];
    
    uid = [firebaseService getUserID];
    if(uid){
        users = [@[uid,_friendID] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [firebaseService updateFireBaseRefPath:[NSString stringWithFormat:@"%@-%@/message",users[0],users[1]]];
        [firebaseService observeMessage:self];
    }
    
    UINib *nib = [UINib nibWithNibName:@"ChatSendCell" bundle:nil];
    [[self chatTable] registerNib:nib forCellReuseIdentifier:@"chatSend"];
    nib = [UINib nibWithNibName:@"ChatReceiveCell" bundle:nil];
    [[self chatTable] registerNib:nib forCellReuseIdentifier:@"chatReceive"];
   
    self.handler = [[ContentView alloc] initWithTextView:self.chatTextView ChatTextViewHeightConstraint:self.chatTextViewHeightConstraint contentView:self.contentView ContentViewHeightConstraint:self.contentViewHeightConstraint andContentViewBottomConstraint:self.contentViewBottomConstraint];
    
    //Setting the minimum and maximum number of lines for the textview vertical expansion
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:3];
    
    //Tap gesture on table view so that when someone taps on it, the keyboard is hidden
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    self.chatTextView.delegate = self;
    
    [self.chatTable addGestureRecognizer:gestureRecognizer];
}

- (void) dismissKeyboard
{
    [self.chatTextView resignFirstResponder];
}
- (IBAction)videoCallButtonPressed:(id)sender {
    
    UIStoryboard *callStoryboard = [UIStoryboard storyboardWithName:@"AVCallStoryBoard" bundle:[NSBundle mainBundle]];
    VideoCallViewController *callVC = [callStoryboard instantiateViewControllerWithIdentifier:@"AVCallViewController"];
    [callVC setCallIdentifier:uid callIdentifier:[NSString stringWithFormat:@"%@-%@",users[0],users[1]]];
    [self.navigationController pushViewController:callVC animated:YES];
}

- (void)showMessageBubble:(NSString *)name message:(NSString *)message time:(NSString *)time type:(NSString *)type mediaType:(BOOL)mediaType user1:(NSString *)user1 user2:(NSString *)user2{
    
    MessageModel *sendMessage = [[MessageModel alloc] initIMessageWithName:name messageID:[NSString stringWithFormat:@"%@-%@",users[0],users[1]] message:message time:time type:type mediaImage:mediaType user1:user1 user2:user2];
    [self updateTableView:sendMessage];
}

- (IBAction)sendMessage:(id)sender {
    if([self.chatTextView.text length]!=0){
        
        [firebaseService sendMessage:self.chatTextView.text user1:[firebaseService getUserID] user2:_friendID media:@NO time:[NSDate date]];
        
        [self.sendMessageBtn setTitle:@"" forState:UIControlStateNormal];
        [self.sendMessageBtn setImage:[UIImage imageNamed:@"icons8-facebook-like-24"] forState:UIControlStateNormal];
    }
    else{
        [firebaseService sendMessage:@"👍" user1:[firebaseService getUserID] user2:_friendID media:@NO time:[NSDate date]];
    }
    [firebaseService addMessageToMessageHistoryIfNotExist:[NSString stringWithFormat:@"%@-%@",users[0],users[1]] uid: _friendID];
    [firebaseService addMessageToMessageHistoryIfNotExist:[NSString stringWithFormat:@"%@-%@",users[0],users[1]] uid: [firebaseService getUserID]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(![textView.text isEqualToString:@""]){
        [self.sendMessageBtn setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendMessageBtn setImage:nil forState:UIControlStateNormal];
    }else{
        [self.sendMessageBtn setTitle:@"" forState:UIControlStateNormal];
        [self.sendMessageBtn setImage:[UIImage imageNamed:@"icons8-facebook-like-24"] forState:UIControlStateNormal];
    }
    return true;
}

- (IBAction)sendAttachment:(id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                 init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo {
    
    [firebaseService storeImageInFireBaseStorage:[self compressUploadingImageWith:image]user1:[firebaseService getUserID] user2:_friendID];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSData *)compressUploadingImageWith:(UIImage *)image{
    CGSize newSize = CGSizeMake(200.0f, 200.0f);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(newImage);
}

-(void) updateTableView:(MessageModel *)msg
{
    [self.chatTextView setText:@""];
    [self.handler textViewDidChange:self.chatTextView];
    
    [self.chatTable beginUpdates];
    
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:currentMessages.count inSection:0];
    
    [currentMessages insertObject:msg atIndex:currentMessages.count];
    
    [self.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1, nil] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.chatTable endUpdates];
    
    //Always scroll the chat table when the user sends the message
    if([self.chatTable numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.chatTable numberOfRowsInSection:0]-1 inSection:0];
        [self.chatTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *message = [currentMessages objectAtIndex:indexPath.row];
    if([message.messageType isEqualToString:@"self"])
    {
        
        chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatSend" forIndexPath:indexPath];
        
        chatCell.chatUserImage.image = nil;
        [firebaseService getUserModelFromFirebase:message.user1 withSuccess:^(UserModel *user) {
            [chatCell.chatUserImage setImageWithURL:[NSURL URLWithString:user.imgUrl] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        } andFailure:^(NSError *error) {
            
        }];
      //  chatCell.mediaImage.image = nil;
        if(message.mediaImage==1){
            [chatCell.tailcurve setHidden:YES];
            chatCell.mediaImage.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
            chatCell.mediaImage.layer.borderWidth = 1.0f;
            if(chatCell.mediaImage.layer.cornerRadius==0)
                chatCell.mediaImage.layer.cornerRadius = chatCell.mediaImage.bounds.size.height/5;
            chatCell.mediaImage.layer.masksToBounds = YES;
            [chatCell.mainView setBackgroundColor:[UIColor whiteColor]];
            [chatCell.mediaImageLoadIndicator startAnimating];
            [chatCell.chatMessageLabel setHidden:YES];
            [chatCell.mediaImage setImageWithURL:[NSURL URLWithString:message.userMessage] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        else{
            [chatCell.chatMessageLabel setHidden:NO];
            chatCell.layer.masksToBounds = NO;
            chatCell.mediaImage.layer.borderWidth = 0;
            [chatCell.mainView setBackgroundColor:[UIColor colorFromHex:SenderMainColor]];
            chatCell.chatMessageLabel.text = message.userMessage;
        }
        
        
    }else{
        
        chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive" forIndexPath:indexPath];
        
    //    chatCell.mediaImage.image = nil;
    //    chatCell.chatUserImage.image = nil;
        
        [firebaseService getUserModelFromFirebase:message.user1 withSuccess:^(UserModel *user) {
            [chatCell.chatUserImage setImageWithURL:[NSURL URLWithString:user.imgUrl] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        } andFailure:^(NSError *error) {
            
        }];
        if(message.mediaImage==1){
            [chatCell.tailcurve setHidden:YES];
            chatCell.mediaImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
            chatCell.mediaImage.layer.borderWidth = 1.0f;
            [chatCell.mainView setBackgroundColor:[UIColor whiteColor]];
            [chatCell.mediaImageLoadIndicator startAnimating];
            [chatCell.chatMessageLabel setHidden:YES];
            if(chatCell.mediaImage.layer.cornerRadius==0)
                chatCell.mediaImage.layer.cornerRadius = chatCell.mediaImage.bounds.size.height/5;
            chatCell.mediaImage.layer.masksToBounds = YES;
            [chatCell.mediaImage setImageWithURL:[NSURL URLWithString:message.userMessage] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }else{
            
            [chatCell.chatMessageLabel setHidden:NO];
            chatCell.layer.masksToBounds = NO;
            chatCell.mediaImage.layer.borderWidth = 0;
            [chatCell.mainView setBackgroundColor:[UIColor colorFromHex:ReceiverMainColor]];
            chatCell.chatMessageLabel.text = message.userMessage;
        }
    }
    return chatCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *message = [currentMessages objectAtIndex:indexPath.row];
    
    CGSize size;
    
    CGSize Namesize;
    CGSize Timesize;
    CGSize Messagesize;
    
    NSArray *fontArray = [[NSArray alloc] init];
    
    if([message.messageType isEqualToString:@"self"])
    {
        fontArray = chatCellSettings.getSenderBubbleFontWithSize;
    }
    else
    {
        fontArray = chatCellSettings.getReceiverBubbleFontWithSize;
    }
    
    Messagesize = [message.userMessage boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:fontArray[1]}
                                                    context:nil].size;
    
    size.height = Messagesize.height + Namesize.height + Timesize.height + 48.0f;
    
    return size.height;
}

@end
