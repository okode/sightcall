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
        case lsConnectionStatus_idle: NSLog(@"IDLE"); break;
        case lsConnectionStatus_agentConnected: NSLog(@"Agent connected"); break;
        case lsConnectionStatus_agentConnecting: NSLog(@"Agent connecting"); break;
        case lsConnectionStatus_connecting: NSLog(@"Connecting"); break;
        case lsConnectionStatus_active: NSLog(@"Active"); break;
        case lsConnectionStatus_calling: NSLog(@"Calling"); break;
        case lsConnectionStatus_callActive:
        {
            NSLog(@"Call active");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:self.lsUniversal.callViewController animated:YES completion:nil];
            });
        }; break;
        case lsConnectionStatus_disconnecting: NSLog(@"Disconnecting"); break;
        case lsConnectionStatus_networkLoss: NSLog(@"Network loss"); break;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
