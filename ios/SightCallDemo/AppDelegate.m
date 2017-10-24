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
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    UAAction *customDLA = [UAAction actionWithBlock: ^(UAActionArguments *args, UAActionCompletionHandler handler)  {
        
        handler([UAActionResult resultWithValue:args.value]);
    } acceptingArguments:^BOOL(UAActionArguments *arg)  {
        if (arg.situation == UASituationBackgroundPush || arg.situation == UASituationBackgroundInteractiveButton) {
            return NO;
        }
        
        return [arg.value isKindOfClass:[NSURL class]] || [arg.value isKindOfClass:[NSString class]];
    }];
    
    [[UAirship shared].actionRegistry updateAction:customDLA forEntryWithName:kUADeepLinkActionDefaultRegistryName];

    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    /*
     We don't register the APNS push token in Sightcall's backend because we need to register the VoIP token in order to receive VoIP notifications.
     So that the push arrives as VoIP and not as regular push, we need to register the VoIP token (See PushKit delegate methods) in Sightcall's backend by its SDK and just register the VoIP certificate in the Sigtcall's console (don't add APNS certificate because we won't work)
     */
}

/** Works on iOS9, but not supported at the moment **/
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    NSLog(@"Action");
}


#define PushKit Delegate Methods

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }
    NSLog(@"PushCredentials: %@", credentials.token);
    NSString * deviceTokenString = [[[[credentials.token description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];

    ViewController* viewController = (ViewController*) self.window.rootViewController;
    [viewController.lsUniversal.agentHandler setNotificationToken: deviceTokenString];

}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    NSLog(@"didReceiveIncomingPushWithPayload");
    ViewController* viewController = (ViewController*) self.window.rootViewController;
    if ([viewController.lsUniversal canHandleNotification:payload.dictionaryPayload]) {
        [viewController.lsUniversal handleNotification:payload.dictionaryPayload];
    }
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

@end
