//
//  ViewController.h
//  SightCallDemo
//
//  Created by Pedro Jorquera on 14/5/17.
//  Copyright © 2017 Okode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LSUniversalSDK/LSUniversalSDK.h>

@interface ViewController : UIViewController <LSUniversalDelegate>
@property (strong, nonatomic) LSUniversal* lsUniversal;
@end

