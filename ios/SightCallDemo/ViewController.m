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

- (IBAction)registerAgent:(id)sender {
    if ([self.lsUniversal.agentHandler isAvailable]) {
        NSLog(@"Agent already registered!");
        return;
    }
    [self.lsUniversal.agentHandler registerWithPin:@"532438" andToken:@"aFX2IL6fx4n4TGLGEx3lmLvHu3a0MHhv" onSignIn:^(BOOL success, NSInteger statusCode, RegistrationError_t status){
        if (success) {
            NSLog(@"Registration successful!");
        } else {
            NSLog(@"Registration error!");
        }
    }];
}

- (IBAction)invite:(id)sender {
    if (![self.lsUniversal.agentHandler isAvailable]) {
        NSLog(@"Agent not registered!");
        return;
    }
    [self.lsUniversal.agentHandler fetchUsecases:^(BOOL success, NSArray<NSObject<LSMAUsecase> *> *usecaselist) {
        if (success) {
            [self.lsUniversal.agentHandler sendNotificationForUsecase:(LSMAGuestUsecase*)[usecaselist objectAtIndex:0] toPhone:@"649355192" andDisplayName:@"rpanadero" andNotify:^(NSInteger statusCode) {
                if (statusCode == 200) {
                    NSLog(@"Invitation was successful");
                } else {
                    NSLog(@"Invitation sent error!");
                }
            }];
        } else {
            NSLog(@"Invitation error!");
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
