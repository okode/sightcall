//
//  ViewController.m
//  SightCallDemo
//
//  Created by Pedro Jorquera on 14/5/17.
//  Copyright © 2017 Okode. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lsUniversal = [[LSUniversal alloc] init];
    self.lsUniversal.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer: tap];
}

-(void) connectionEvent:(lsConnectionStatus_t)status
{
    switch (status) {
        case lsConnectionStatus_callActive:
            {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:self.lsUniversal.callViewController animated:YES completion:nil];
            });
            }
            break;
        case lsConnectionStatus_disconnecting:
            [self dismissViewControllerAnimated:TRUE completion:nil];
            break;
        default: break;
    }
}

- (void)connectionError:(lsConnectionError_t)error
{
    NSLog(@"connectionError");
}

- (void)callReport:(lsCallReport_s)callEnd
{
     NSLog(@"callReport");
}

- (void)presentDialog: (NSString*) msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            // Called when user taps outside
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (IBAction)registerAgent:(id)sender {
    if ([self.lsUniversal.agentHandler isAvailable]) {
        NSLog(@"Agent already registered!");
        return;
    }
    [self.lsUniversal.agentHandler registerWithPin:@"473653" andToken:@"hhlBKiPMyiy3wPxtuLQ4aJ2oKJnL6Ues" onSignIn:^(BOOL success, NSInteger statusCode, RegistrationError_t status){
        if (success) {
            NSLog(@"Registration successful!");
            [self presentDialog:@"Registration success"];
        } else {
            NSLog(@"Registration error!");
            [self presentDialog:@"Registration error"];
        }
    }];
}

- (IBAction)generateURL:(id)sender {
    if (![self.lsUniversal.agentHandler isAvailable]) {
        NSLog(@"Agent not registered!");
        [self presentDialog:@"Agent not registered"];
        return;
    }
    [self.lsUniversal.agentHandler fetchUsecases:^(BOOL success, NSArray<NSObject<LSMAUsecase> *> *usecaselist) {
        if (success) {
            [self.lsUniversal.agentHandler createInvitationForUsecase:(LSMAGuestUsecase*)[usecaselist objectAtIndex:0]  usingSuffix:@"GUEST" andNotify:^(BOOL didSucceed, NSString * _Nullable invite) {
                if (didSucceed) {
                    NSLog(@"Invitation was successful");
                    [self presentDialog:@"Invitation URL generated"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UITextField *textValue = (UITextField *)[self.view viewWithTag:4];
                        [textValue setText:invite];
                    });
                } else {
                    NSLog(@"Invitation sent error!");
                    [self presentDialog:@"Invitation error"];
                }
            }];
        } else {
            NSLog(@"Invitation error!");
            [self presentDialog:@"Error getting user cases"];
        }
    }];
    
}

- (IBAction)startCall:(id)sender {
    UITextField *textValue = (UITextField *)[self.view viewWithTag:4];
    NSString *chkText = textValue.text;
    [self.lsUniversal startWithString:chkText];
    [self presentDialog:@"Calling..."];
    
}

-(void)dismissKeyboard
{
    UITextField *textValue = (UITextField *)[self.view viewWithTag:4];
    [textValue resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
