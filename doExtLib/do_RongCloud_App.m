//
//  do_RongCloud_App.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_RongCloud_App.h"
#import <RongIMKit/RongIMKit.h>
#import "DoRCConversationViewController.h"
#import "doScriptEngineHelper.h"
#import "do_RongCloud_SM.h"
#import "doJsonHelper.h"
static do_RongCloud_App* instance;
@implementation do_RongCloud_App
@synthesize OpenURLScheme;
+(id) Instance
{
    if(instance==nil)
        instance = [[do_RongCloud_App alloc]init];
    return instance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 注册用户通知
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        //注册推送，用于iOS8之前的系统
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateInactive) {
        [self fireEvent:notification.userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    if (application.applicationState == UIApplicationStateInactive) {
        [self fireEvent:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    if (application.applicationState == UIApplicationStateInactive) {
        [self fireEvent:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

//点击推送触发
- (void)fireEvent:(NSDictionary *)userInfo
{
    do_RongCloud_SM *rongCloud = (do_RongCloud_SM*)[doScriptEngineHelper ParseSingletonModule:nil :@"do_RongCloud"];
    doInvokeResult *result = [[doInvokeResult alloc] init];
    NSDictionary *apsDict = [userInfo objectForKey:@"aps"];
    NSString *message = [apsDict objectForKey:@"alert"] == nil ? @"" : [apsDict objectForKey:@"alert"];
    
    NSMutableDictionary *customDict = [NSMutableDictionary dictionary];
    for (NSString *infoKey in userInfo) {
        if (![infoKey isEqualToString:@"aps"]) {
            [customDict setValue:[userInfo valueForKey:infoKey] forKey:infoKey];
        }
    }
    NSString *customContent = [doJsonHelper ExportToText:customDict :NO];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    [resultDict setObject:message forKey:@"message"];
    [resultDict setObject:customContent forKey:@"customContent"];
    [rongCloud.EventCenter FireEvent:@"messageClicked" :result];
    
}


@end
