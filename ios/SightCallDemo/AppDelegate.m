//
//  AppDelegate.m
//  SightCallDemo
//
//  Created by Pedro Jorquera on 14/5/17.
//  Copyright © 2017 Okode. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register for remote notifications.
    [UAirship takeOff];
    [UAirship push].userPushNotificationsEnabled = YES;
    [UAirship push].defaultPresentationOptions = (UNNotificationPresentationOptionAlert |
                                                  UNNotificationPresentationOptionBadge |
                                                  UNNotificationPresentationOptionSound);
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];

    ViewController* viewController = (ViewController*) self.window.rootViewController;
    [viewController.lsUniversal.agentHandler setNotificationToken: deviceTokenString];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    ViewController* viewController = (ViewController*) self.window.rootViewController;
    if ([viewController.lsUniversal canHandleNotification:userInfo]) {
        NSString *url = userInfo[@"data"][@"guest_ready"][@"url"];
        [viewController.lsUniversal startWithString:url];
        // This method doesn't work properly but it internally does a start with the URL received as parameter (not sure but it is working in this way)
        // [viewController.lsUniversal handleNotification:userInfo];
    }
}
@end
