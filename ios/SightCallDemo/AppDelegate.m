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
    [UAirship push].pushNotificationDelegate = self;
    [UAirship push].userPushNotificationsEnabled = YES;
    [UAirship push].defaultPresentationOptions = (UNNotificationPresentationOptionAlert |
                                                  UNNotificationPresentationOptionBadge |
                                                  UNNotificationPresentationOptionSound);
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    ViewController* viewController = (ViewController*) self.window.rootViewController;
    [viewController.lsUniversal startWithString:[url absoluteString]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application { }
- (void)applicationDidEnterBackground:(UIApplication *)application { }
- (void)applicationWillEnterForeground:(UIApplication *)application { }
- (void)applicationDidBecomeActive:(UIApplication *)application { }
- (void)applicationWillTerminate:(UIApplication *)application { }
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    ViewController* viewController = (ViewController*) self.window.rootViewController;
    [viewController.lsUniversal.agentHandler setNotificationToken: deviceTokenString];
}

//In your code, a class conforms to the PushKit protocol and receive a notification
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    ViewController* viewController = (ViewController*) self.window.rootViewController;
    if ([viewController.lsUniversal canHandleNotification:payload.dictionaryPayload]) {
        [viewController.lsUniversal handleNotification:payload.dictionaryPayload];
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type {
    NSLog(@"Test");
}

-(void)receivedForegroundNotification:(UANotificationContent *)notificationContent completionHandler:(void (^)(void))completionHandler {
    NSLog(@"Test");
}


@end
