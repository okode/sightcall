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
    self.lsUniversal.logDelegate = self;
    
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
    [self.lsUniversal.agentHandler registerWithCode:@"659f284ae8b" andReference:@"com.okode.SightCallDemo.s" onSignIn:^(LSMARegistrationStatus_t t, NSString * _Nullable tokenID) {
        if (t == LSMARegistrationStatus_registered) {
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
    [self.lsUniversal.agentHandler fetchIdentity:^(BOOL success) {
        if (success) {
            [self.lsUniversal.agentHandler createInvitationForUsecase:[self.lsUniversal.agentHandler.identity pincodeUsecases][0] withReference:@"REFERENCE_ID" andNotify:^(LSMAPincodeStatus_t status, NSString * _Nullable inviteURL) {
                if (status == LSMAPincodeStatus_created) {
                    NSLog(@"Invitation was successful");
                    [self presentDialog:@"Invitation URL generated"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UITextField *textValue = (UITextField *)[self.view viewWithTag:4];
                        [textValue setText:inviteURL];
                    });
                } else {
                    NSLog(@"Invitation sent error!");
                    [self presentDialog:@"Invitation error"];
                }
            }];
        }
        else {
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
            }
            [self removeLocalCallNotification];
        }];
    } else {
        UILocalNotification *localNotification = [CallLocalNotification buildUILocalNotification: callUrl];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }

}

- (void) removeLocalCallNotification {
    // Delay execution of my block for 20 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeDeliveredNotificationsWithIdentifiers:@[@"SIGHTCALL_CALL_ALARM"]];
    });
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

//this delegate method is called when a log line is emitted by the SDK
- (void)logLevel:(NSInteger)level logModule:(NSInteger)module fromMethod:(NSString *)originalSel message:(NSString *)message, ...;
{
    va_list pe;
    va_start(pe, message);
    NSString *sMessage = [[NSString alloc] initWithFormat:message arguments:pe];
    va_end(pe);
    NSLog(@"%@ %@", originalSel, sMessage);
}

@end
