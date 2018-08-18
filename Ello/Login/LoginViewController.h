//
//  LoginViewController.h
//  Ello
//
//  Created by vd-rahim on 10/28/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFloatLabelTextField.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "FBSDKLoginButton.h"
#import "FireBaseService.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate>{
    FireBaseService *firebaseService;
}

@property (weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *descText;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *usernameText;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *passwordText;
@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//@property (strong, nonatomic) FIRDatabaseReference *fireBaseRef;
//@property (weak, nonatomic) IBOutlet FBSDKLoginButton *faceBookLoginButton;

@end
