//
//  ViewController.h
//  SightCallDemo
//
//  Created by Pedro Jorquera on 14/5/17.
//  Copyright © 2017 Okode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <LSUniversalSDK/LSUniversalSDK.h>
#import "CallLocalNotification.h"

@interface ViewController : UIViewController <LSUniversalDelegate, LSPictureProtocol, UNUserNotificationCenterDelegate, LSUniversalLogDelegate>
@property (strong, nonatomic) LSUniversal* lsUniversal;
@end

