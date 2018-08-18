//
//  VideoCallViewController.m
//  Ello
//
//  Created by vd-rahim on 1/27/18.
//  Copyright © 2018 vd-rahim. All rights reserved.
//

#import "VideoCallViewController.h"

#import "Utils.h"
#import <TwilioVideo/TwilioVideo.h>

@interface VideoCallViewController ()< TVIParticipantDelegate, TVIRoomDelegate, TVIVideoViewDelegate, TVICameraCapturerDelegate>

// Configure access token manually for testing in `ViewDidLoad`, if desired! Create one manually in the console.
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenUrl;

#pragma mark Video SDK components

@property (nonatomic, strong) TVICameraCapturer *camera;
@property (nonatomic, strong) TVILocalVideoTrack *localVideoTrack;
@property (nonatomic, strong) TVILocalAudioTrack *localAudioTrack;
@property (nonatomic, strong) TVIParticipant *participant;
@property (nonatomic, weak) TVIVideoView *remoteView;
@property (nonatomic, strong) TVIRoom *room;

#pragma mark UI Element Outlets and handles

// `TVIVideoView` created from a storyboard
@property (weak, nonatomic) IBOutlet TVIVideoView *previewView;

@end

@implementation VideoCallViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    NSLog(@"%@",[NSString stringWithFormat:@"TwilioVideo v%@", [TwilioVideo version]]);
    NSLog(@" call with user with identifier    %@",self.callIdentifier);
    // Configure access token for testing. Create one manually in the console
    // at https://www.twilio.com/console/video/runtime/testing-tools
    self.accessToken = @"TWILIO_ACCESS_TOKEN";
    
    // Using a token server to provide access tokens? Make sure the tokenURL is pointing to the correct location.
    self.tokenUrl =[NSString stringWithFormat:@"http://vermicidal-scale.000webhostapp.com/video/video/index.php?identity=%@&room=%@",_userIdentifier,_callIdentifier];
    
    // Preview our local camera track in the local video preview view.
    [self startPreview];
    
    // Disconnect and mic button will be displayed when client is connected to a room.
    //self.callEndButton.hidden = YES;
    //self.micBtn.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self connectCallBetweenUsers];
}

- (void)setCallIdentifier:(NSString *)userIden callIdentifier:(NSString *)callIdentifier{
    _callIdentifier = callIdentifier;
    _userIdentifier = userIden;
}

- (void)setupUI{
    _micBtn.layer.cornerRadius = _micBtn.bounds.size.width/2;
    _micBtn.layer.masksToBounds = YES;
    
    _callEndButton.layer.cornerRadius = _callEndButton.bounds.size.width/2;
    _callEndButton.layer.masksToBounds = YES;
    
    _videoButton.layer.cornerRadius = _videoButton.bounds.size.width/2;
    _videoButton.layer.masksToBounds = YES;
    
    self.navigationController.navigationBar.alpha = 0.7;
}

#pragma mark - Public

- (void)connectCallBetweenUsers{
    [self showRoomUI:YES];
    
    if ([self.accessToken isEqualToString:@"TWILIO_ACCESS_TOKEN"]) {
        NSLog(@"%@",[NSString stringWithFormat:@"Fetching an access token"]);
        [TokenUtils retrieveAccessTokenFromURL:self.tokenUrl completion:^(NSString *token, NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!err) {
                    self.accessToken = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [self doConnect];
                } else {
                    NSLog(@"%@",[NSString stringWithFormat:@"Error retrieving the access token"]);
                    [self showRoomUI:NO];
                }
            });
        }];
    } 
}

- (IBAction)disconnectButtonPressed:(id)sender {
    [self.room disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)micButtonPressed:(id)sender {
    // We will toggle the mic to mute/unmute and change the title according to the user action.
    
    if (self.localAudioTrack) {
        self.localAudioTrack.enabled = !self.localAudioTrack.isEnabled;
        
        // Toggle the button title
        if (self.localAudioTrack.isEnabled) {
            [self.micBtn setImage:[UIImage imageNamed:@"mic-unmute"] forState:UIControlStateNormal];
        } else {
            [self.micBtn setImage:[UIImage imageNamed:@"mic-mute"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Private

- (void)startPreview {
    // TVICameraCapturer is not supported with the Simulator.
    if ([PlatformUtils isSimulator]) {
        [self.previewView removeFromSuperview];
        return;
    }
    
    self.camera = [[TVICameraCapturer alloc] initWithSource:TVICameraCaptureSourceFrontCamera delegate:self];
    self.localVideoTrack = [TVILocalVideoTrack trackWithCapturer:self.camera];
    if (!self.localVideoTrack) {
        NSLog(@"Failed to add video track");
    } else {
        // Add renderer to video track for local preview
        [self.localVideoTrack addRenderer:self.previewView];
        NSLog(@"Video track created");
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(flipCamera)];
        [self.previewView addGestureRecognizer:tap];
    }
}

- (void)flipCamera {
    if (self.camera.source == TVICameraCaptureSourceFrontCamera) {
        [self.camera selectSource:TVICameraCaptureSourceBackCameraWide];
    } else {
        [self.camera selectSource:TVICameraCaptureSourceFrontCamera];
    }
}

- (void)prepareLocalMedia {
    
    // We will share local audio and video when we connect to room.
    
    // Create an audio track.
    if (!self.localAudioTrack) {
        self.localAudioTrack = [TVILocalAudioTrack track];
        
        if (!self.localAudioTrack) {
            NSLog(@"Failed to add audio track");
        }
    }
    
    // Create a video track which captures from the camera.
    if (!self.localVideoTrack) {
        [self startPreview];
    }
}

- (void)doConnect {
    if ([self.accessToken isEqualToString:@"TWILIO_ACCESS_TOKEN"]) {
        NSLog(@"Please provide a valid token to connect to a room");
        return;
    }
    
    // Prepare local media which we will share with Room Participants.
    [self prepareLocalMedia];
    
    TVIConnectOptions *connectOptions = [TVIConnectOptions optionsWithToken:self.accessToken
                                                                      block:^(TVIConnectOptionsBuilder * _Nonnull builder) {
                                                                          
                                                                          // Use the local media that we prepared earlier.
                                                                          builder.audioTracks = self.localAudioTrack ? @[ self.localAudioTrack ] : @[ ];
                                                                          builder.videoTracks = self.localVideoTrack ? @[ self.localVideoTrack ] : @[ ];
                                                                          
                                                                          // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
                                                                          // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
                                                                          builder.roomName = self.callIdentifier;
                                                                      }];
    
    // Connect to the Room using the options we provided.
    self.room = [TwilioVideo connectWithOptions:connectOptions delegate:self];
    NSLog(@"%@",[NSString stringWithFormat:@"Attempting to connect to room %@", self.callIdentifier]);
}

- (void)setupRemoteView {
    // Creating `TVIVideoView` programmatically
    TVIVideoView *remoteView = [[TVIVideoView alloc] init];
    
    // `TVIVideoView` supports UIViewContentModeScaleToFill, UIViewContentModeScaleAspectFill and UIViewContentModeScaleAspectFit
    // UIViewContentModeScaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
    self.remoteView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view insertSubview:remoteView atIndex:0];
    self.remoteView = remoteView;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:centerX];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    [self.view addConstraint:centerY];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1
                                                              constant:0];
    [self.view addConstraint:width];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.remoteView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1
                                                               constant:0];
    [self.view addConstraint:height];
}

// Reset the client ui status
- (void)showRoomUI:(BOOL)inRoom {
    // self.micBtn.hidden = !inRoom;
    //self.callEndButton.hidden = !inRoom;
    [UIApplication sharedApplication].idleTimerDisabled = inRoom;
}

- (void)cleanupRemoteParticipant {
    if (self.participant) {
        if ([self.participant.videoTracks count] > 0) {
            [self.participant.videoTracks[0] removeRenderer:self.remoteView];
            [self.remoteView removeFromSuperview];
        }
        self.participant = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)testFieldShouldReturn:(UITextField *)textField {
    [self connectCallBetweenUsers];
    return YES;
}

#pragma mark - TVIRoomDelegate

- (void)didConnectToRoom:(TVIRoom *)room {
    // At the moment, this example only supports rendering one Participant at a time.
    NSLog(@"%@",[NSString stringWithFormat:@"Connected to room %@ as %@", room.name, room.localParticipant.identity]);
    
    if (room.participants.count > 0) {
        self.participant = room.participants[0];
        self.participant.delegate = self;
    }
}

- (void)room:(TVIRoom *)room didDisconnectWithError:(nullable NSError *)error {
    NSLog(@"%@",[NSString stringWithFormat:@"Disconncted from room %@, error = %@", room.name, error]);
    
    [self cleanupRemoteParticipant];
    self.room = nil;
    
    [self showRoomUI:NO];
}

- (void)room:(TVIRoom *)room didFailToConnectWithError:(nonnull NSError *)error{
    NSLog(@"%@",[NSString stringWithFormat:@"Failed to connect to room, error = %@", error]);
    
    self.room = nil;
    
    [self showRoomUI:NO];
}

- (void)room:(TVIRoom *)room participantDidConnect:(TVIParticipant *)participant {
    if (!self.participant) {
        self.participant = participant;
        self.participant.delegate = self;
    }
    NSLog(@"%@",[NSString stringWithFormat:@"Room %@ participant %@ connected", room.name, participant.identity]);
}

- (void)room:(TVIRoom *)room participantDidDisconnect:(TVIParticipant *)participant {
    if (self.participant == participant) {
        [self cleanupRemoteParticipant];
    }
    NSLog(@"%@",[NSString stringWithFormat:@"Room %@ participant %@ disconnected", room.name, participant.identity]);
}

#pragma mark - TVIParticipantDelegate

- (void)participant:(TVIParticipant *)participant addedVideoTrack:(TVIVideoTrack *)videoTrack {
    NSLog(@"%@",[NSString stringWithFormat:@"Participant %@ added video track.", participant.identity]);
    
    if (self.participant == participant) {
        [self setupRemoteView];
        [videoTrack addRenderer:self.remoteView];
    }
}

- (void)participant:(TVIParticipant *)participant removedVideoTrack:(TVIVideoTrack *)videoTrack {
    
    NSLog(@"%@",[NSString stringWithFormat:@"Participant %@ removed video track.", participant.identity]);
    
    if (self.participant == participant) {
        [videoTrack removeRenderer:self.remoteView];
        [self.remoteView removeFromSuperview];
    }
}

- (void)participant:(TVIParticipant *)participant addedAudioTrack:(TVIAudioTrack *)audioTrack {
    
    NSLog(@"%@",[NSString stringWithFormat:@"Participant %@ added audio track.", participant.identity]);
}

- (void)participant:(TVIParticipant *)participant removedAudioTrack:(TVIAudioTrack *)audioTrack {
    
    NSLog(@"%@",[NSString stringWithFormat:@"Participant %@ removed audio track.", participant.identity]);
}

- (void)participant:(TVIParticipant *)participant enabledTrack:(TVITrack *)track {
    NSString *type = @"";
    if ([track isKindOfClass:[TVIAudioTrack class]]) {
        type = @"audio";
    } else {
        type = @"video";
    }
    NSLog(@"%@",[NSString stringWithFormat:@"Participant %@ enabled %@ track.", participant.identity, type]);
}

- (void)participant:(TVIParticipant *)participant disabledTrack:(TVITrack *)track {
    NSString *type = @"";
    if ([track isKindOfClass:[TVIAudioTrack class]]) {
        type = @"audio";
    } else {
        type = @"video";
    }
    NSLog(@"%@",[NSString stringWithFormat:@"Participant %@ disabled %@ track.", participant.identity, type]);
}

#pragma mark - TVIVideoViewDelegate

- (void)videoView:(TVIVideoView *)view videoDimensionsDidChange:(CMVideoDimensions)dimensions {
    NSLog(@"Dimensions changed to: %d x %d", dimensions.width, dimensions.height);
    [self.view setNeedsLayout];
}

#pragma mark - TVICameraCapturerDelegate

- (void)cameraCapturer:(TVICameraCapturer *)capturer didStartWithSource:(TVICameraCaptureSource)source {
    self.previewView.mirror = (source == TVICameraCaptureSourceFrontCamera);
}

@end

