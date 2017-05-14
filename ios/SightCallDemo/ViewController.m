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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
