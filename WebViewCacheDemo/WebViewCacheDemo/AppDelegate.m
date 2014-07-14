//
//  AppDelegate.m
//  WebViewCacheDemo
//
//  Created by tao on 14-7-3.
//  Copyright (c) 2014年 willonboy. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [RootViewController new];
    
    return YES;
}

@end
