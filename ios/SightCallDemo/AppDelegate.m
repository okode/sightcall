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
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    return YES;
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

@end
