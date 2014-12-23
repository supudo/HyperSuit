//
//  AppDelegate.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "AppDelegate.h"
#import "Appirater.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Appirater setAppId:[GameSettings sharedInstance].appStoreID];
    [Appirater setDaysUntilPrompt:2];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:5];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];

    return YES;
}

- (void) applicationWillEnterForeground:(UIApplication*)application {
    [Appirater appEnteredForeground:YES];
}

@end
