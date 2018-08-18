//
//  LoginViewController.m
//  Ello
//
//  Created by vd-rahim on 10/28/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "LoginViewController.h"
#import "UIColor+Hex.h"
#import "tabBarViewController.h"

@interface LoginViewController (){
    Boolean isKeyboardEnable;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    firebaseService = [[FireBaseService alloc] init];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    
     NSString* isFirstTime = [NSUserDefaults.standardUserDefaults objectForKey:@"firstTime"];
    
    if([isFirstTime isEqualToString:@"NO"]){
        if([firebaseService isUserLoggedIn])
            [[GIDSignIn sharedInstance] signIn];
    }else{
        [NSUserDefaults.standardUserDefaults setObject:@"NO" forKey:@"firstTime"];
        [[GIDSignIn sharedInstance] signOut];
    }
    
    /*if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"its testing");
    }
     */
    //[[GIDSignIn sharedInstance] signOut];
    //[self setupSigninButtons];
    //_signInButton.style = kGIDSignInButtonStyleIconOnly;
    _signInButton.style = kGIDSignInButtonStyleIconOnly;
    [self setupUI];
    [self setupScrollViewContent];
    isKeyboardEnable = false;
    self.passwordText.delegate = self;
    self.usernameText.delegate = self;
    //_faceBookLoginButton.readPermissions = @[@"public_profile", @"email"];
    //_faceBookLoginButton.delegate = self;
}

- (void)setupSigninButtons{
    _signInButton.layer.cornerRadius = _signInButton.bounds.size.width/2;
    _signInButton.layer.masksToBounds = YES;
    
    //_faceBookLoginButton.layer.cornerRadius = _faceBookLoginButton.bounds.size.width/2;
    //_faceBookLoginButton.layer.masksToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupNotification];
}

- (void)setupScrollViewContent{
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)setupUI{
    
    [self.descText setAttributedText:[self setKerningString:@"Socializing app for Objectives"]];
    //[self.loginButton setAttributedTitle:[self setKerningString:@"Login"] forState:UIControlStateNormal];
    //[self.loginWithFb setAttributedTitle:[self setKerningString:@"Login With Facebook"] forState:UIControlStateNormal];
    
    _usernameText.floatLabelActiveColor = [UIColor orangeColor];
    _passwordText.floatLabelActiveColor = [UIColor orangeColor];
    
    [self SetTextFieldBorder:_passwordText];
    [self SetTextFieldBorder:_usernameText];
}

- (void)keyboardAppear:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    int width = MAX(keyboardSize.height,keyboardSize.width);
    
    [_scrollView setContentOffset:CGPointMake(0, height) animated:YES];
}

- (void)keyboardDisappear:(NSNotification *)notification{
    
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)setupNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppear:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDisappear:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (NSAttributedString *)setKerningString:(NSString *)placeHolderString{
    NSMutableAttributedString *attributedString;
    attributedString = [[NSMutableAttributedString alloc] initWithString:placeHolderString];
    [attributedString addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

- (void)SetTextFieldBorder :(UIFloatLabelTextField *)textField{
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor colorFromHex:0xDCDCDC].CGColor;
    
    border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    border.borderWidth = borderWidth;
    [textField.layer addSublayer:border];
    textField.layer.masksToBounds = YES;
}

#pragma mark - signin Methods.
- (IBAction)loginButtonPressed:(id)sender {
    [firebaseService isUSerExist:_usernameText.text password:_passwordText.text andCompletionHandler:^(bool result) {
        if(result)
            [self performSegueWithIdentifier:@"userLoggedin" sender:sender];
        else
            [self invalidUser];
    }];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    NSLog(@"singin");
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        // ...
        
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          // ...
                                          return;
                                      }
                                      NSLog(@"its my user UID %@", user.providerID);
                                  }];
    } else {
        // ...
    }
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"userLoggedin"] ){
        
        UIStoryboard *tabBarStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        tabBarViewController *myTabBar = [tabBarStoryboard instantiateViewControllerWithIdentifier:@"tabBarViewController"];
        myTabBar.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self showViewController:myTabBar sender:sender];
    }
}


- (void)successfulUserLogin{
    
}

- (void)invalidUser{
    
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if(error){
        NSLog(@"%@", error);
        return;
    }
    NSLog(@"user loged in");
    [self performSegueWithIdentifier:@"userLoggedin" sender:nil];
}


@end
