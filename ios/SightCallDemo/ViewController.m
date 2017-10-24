//
//  ViewController.m
//  SightCallDemo
//
//  Created by Pedro Jorquera on 14/5/17.
//  Copyright © 2017 Okode. All rights reserved.
//
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lsUniversal = [[LSUniversal alloc] init];
    self.lsUniversal.delegate = self;
    [self.lsUniversal setPictureDelegate: self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer: tap];
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
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:TRUE completion:nil];
                });
            }
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

- (void)savedPicture:(UIImage *_Nullable)image andMetadata:(LSPictureMetadata *_Nullable)metadata {
    NSLog(@"A picture has been taken: %@", image);
    if (image != NULL) {
        [self savePictoreOnDisk:image];
    }
}

- (void)savePictoreOnDisk: (UIImage *_Nullable) image {
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString* tempDirectoryPath = NSTemporaryDirectory();

    long long now = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *imagePath =[tempDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.png", now]];
    
    NSLog(@"pre writing to file");
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog(@"Failed to cache image data to disk");
    }
    else
    {
        NSLog(@"the cachedImagedPath is %@ and size %d",imagePath, [imageData length]);
    }
}

- (void)callTheGuest:(NSString *)callURL {
    NSLog(@"Calling the guest");
    [self showLocalCallNotification:callURL];
}

- (void)presentDialog: (NSString*) msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            // Called when user taps outside
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (IBAction)registerAgent:(id)sender {
    if ([self.lsUniversal.agentHandler isAvailable]) {
        NSLog(@"Agent already registered!");
        return;
    }
    [self.lsUniversal.agentHandler registerWithPin:@"307076" andToken:@"LafJqLkrQsAZKDhuFUwcFTzOPRzFw0rC" onSignIn:^(BOOL success, NSInteger statusCode, RegistrationError_t status){
        if (success) {
            NSLog(@"Registration successful!");
            [self presentDialog:@"Registration success"];
        } else {
            NSLog(@"Registration error!");
            [self presentDialog:@"Registration error"];
        }
    }];
}

- (IBAction)generateURL:(id)sender {
    if (![self.lsUniversal.agentHandler isAvailable]) {
        NSLog(@"Agent not registered!");
        [self presentDialog:@"Agent not registered"];
        return;
    }
    [self.lsUniversal.agentHandler fetchUsecases:^(BOOL success, NSArray<NSObject<LSMAUsecase> *> *usecaselist) {
        if (success) {
            [self.lsUniversal.agentHandler createInvitationForUsecase:(LSMAGuestUsecase*)[usecaselist objectAtIndex:0]  usingSuffix:@"GUEST" andNotify:^(BOOL didSucceed, NSString * _Nullable invite) {
                if (didSucceed) {
                    NSLog(@"Invitation was successful");
                    [self presentDialog:@"Invitation URL generated"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UITextField *textValue = (UITextField *)[self.view viewWithTag:4];
                        [textValue setText:invite];
                    });
                } else {
                    NSLog(@"Invitation sent error!");
                    [self presentDialog:@"Invitation error"];
                }
            }];
        } else {
            NSLog(@"Invitation error!");
            [self presentDialog:@"Error getting user cases"];
        }
    }];
    
}

- (IBAction)startCall:(id)sender {
    UITextField *textValue = (UITextField *)[self.view viewWithTag:4];
    NSString *chkText = textValue.text;
    [self.lsUniversal startWithString:chkText];    
}

- (IBAction)showLocalNotification:(id)sender {
    [self showLocalCallNotification: @"prueba"];
}

- (void) registerCallNotificationCategory {
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        // Register the notification categories.
        UNNotificationCategory* callCategory = [CallLocalNotification getUNNNotificationCategory];
        [center setNotificationCategories:[NSSet setWithObjects:callCategory,
                                           nil]];
    } else {
        UIMutableUserNotificationCategory *callCategory = [CallLocalNotification getUIMutableUserNotificationCategory];
        
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories: [NSSet setWithObject:callCategory]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
}

- (void)showLocalCallNotification: (NSString *)callUrl  {
    [self registerCallNotificationCategory];
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent* content = [CallLocalNotification buildCallNotificationContent: callUrl];

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:false];
        UNNotificationRequest* request = [UNNotificationRequest
                                          requestWithIdentifier:@"SIGHTCALL_CALL_ALARM" content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center removeDeliveredNotificationsWithIdentifiers:@[@"SIGHTCALL_CALL_ALARM"]];
            }
        }];
    } else {
        UILocalNotification *localNotification = [CallLocalNotification buildUILocalNotification: callUrl];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }

}

-(void)dismissKeyboard
{
    UITextField *textValue = (UITextField *)[self.view viewWithTag:4];
    [textValue resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UNUserNotificationCenterDelegate

//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    if ([response.notification.request.content.categoryIdentifier isEqualToString:CallLocalNotificationCategory]) {
        // Handle actions
        if ([response.actionIdentifier isEqualToString:CallLocalNotificationAcceptActionID])
        {
            NSString *url = response.notification.request.content.userInfo[@"callUrl"];
            [self.lsUniversal startWithString:url];
        }
    }
    completionHandler();
}

@end
