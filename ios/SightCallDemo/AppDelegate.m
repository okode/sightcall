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
    [UAirship takeOff];
    [UAirship push].userPushNotificationsEnabled = YES;
    [UAirship push].pushNotificationDelegate = self;
    [UAirship push].defaultPresentationOptions = (UNNotificationPresentationOptionAlert |
                                                  UNNotificationPresentationOptionBadge |
                                                  UNNotificationPresentationOptionSound);
    
    UAAction *customDLA = [UAAction actionWithBlock: ^(UAActionArguments *args, UAActionCompletionHandler handler)  {
        
        handler([UAActionResult resultWithValue:args.value]);
    } acceptingArguments:^BOOL(UAActionArguments *arg)  {
        if (arg.situation == UASituationBackgroundPush || arg.situation == UASituationBackgroundInteractiveButton) {
            return NO;
        }
        
        return [arg.value isKindOfClass:[NSURL class]] || [arg.value isKindOfClass:[NSString class]];
    }];
    
    [[UAirship shared].actionRegistry updateAction:customDLA forEntryWithName:kUADeepLinkActionDefaultRegistryName];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"ppr" forKey:@"kStorePlatform"];

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

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"didReceiveIncomingPushWithPayload");
    ViewController* viewController = (ViewController*) self.window.rootViewController;
    if ([viewController.lsUniversal canHandleNotification:userInfo]) {
        [viewController.lsUniversal handleNotification:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}


/** Works on iOS9, but not supported at the moment **/
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    NSLog(@"Action");
    completionHandler();
}

#pragma mark UAPushNotificationDelegate

- (void)receivedNotificationResponse:(UANotificationResponse *)notificationResponse completionHandler:(void(^)())completionHandler {
    UA_LDEBUG(@"The application was launched or resumed from a notification %@", notificationResponse);
    if ([notificationResponse.actionIdentifier isEqualToString:UANotificationDefaultActionIdentifier]) {
        UA_LDEBUG(@"The application was launched or resumed from a notification %@", notificationResponse);
        sleep(10);
        if ([CallLocalNotification isLocalCallNotification:notificationResponse.notificationContent.notificationInfo]) {
            NSString *url = notificationResponse.notificationContent.notificationInfo[@"callUrl"];
            ViewController* viewController = (ViewController*) self.window.rootViewController;
            [viewController.lsUniversal startWithString:url];
        }
    }
    completionHandler();
}


- (void)receivedForegroundNotification:(UANotificationContent *)notificationContent completionHandler:(void(^)())completionHandler {
    UA_LDEBUG(@"Received a notification while the app was already in the foreground %@", notificationContent);
    completionHandler();
}

- (void)receivedBackgroundNotification:(UANotificationContent *)notificationContent
                     completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UA_LDEBUG(@"Received a background notification %@", notificationContent);
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
