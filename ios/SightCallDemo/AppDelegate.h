//
//  AppDelegate.h
//  SightCallDemo
//
//  Created by Pedro Jorquera on 14/5/17.
//  Copyright © 2017 Okode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
@import AirshipKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PKPushRegistryDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

