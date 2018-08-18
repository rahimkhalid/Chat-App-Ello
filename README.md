# Chat-App-Ello
A chatting app with signup, login, chatting with anyone signed-up on this app and even calling them.

Basically, This app includes :

1. Firebase as realtime DB.
2. Gmail authentication as user verification.
3. Twilio for video calling.

# Adding Firebase to the project :
To add firebase to your project kindly follow the below link.

A Quick Starter to FireBase : (https://firebase.google.com/docs/ios/setup)

# Twilio Video in this project :

A quick starter to TWILIO : (https://github.com/twilio/video-quickstart-swift)

This project already contain code to have video calling with any contact, but to use that feature *Goto twilio console and register for video calling feature, moreover there is also code writen which allows you to connect with the server with twilio established. *

*Please see the following files for more information about Twilio activation :*

1. VideoCallViewController.m

*For using a 30 mins twilio valid key :*
1. Replace the accessToken with twilio granted key:
self.accessToken = @"TWILIO_ACCESS_TOKEN";

*For using server to provide video session keys :*
1. Replace the tokenUrl in the below line with your url :
self.tokenUrl =[NSString stringWithFormat:@"YOUR SERVER URL"];
2. No need to update  *self.accessToken = @"TWILIO_ACCESS_TOKEN";* with twilio key.

