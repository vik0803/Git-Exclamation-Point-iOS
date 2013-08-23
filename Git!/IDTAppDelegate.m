//
//  IDTAppDelegate.m
//  Git!
//
//  Created by E&Z Pierson on 6/29/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTAppDelegate.h"
#import "IDTFileEditViewController.h"
@implementation IDTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController.view.tintColor = [UIColor purpleColor];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UISplitViewController *splitVC = (UISplitViewController *)self.window.rootViewController;
    IDTFileEditViewController *fileEditVC = [splitVC.viewControllers lastObject];
    [fileEditVC closeDocument];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    UISplitViewController *splitVC = (UISplitViewController *)self.window.rootViewController;
    IDTFileEditViewController *fileEditVC = [splitVC.viewControllers lastObject];
    [fileEditVC openDocument];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    UISplitViewController *splitVC = (UISplitViewController *)self.window.rootViewController;
    IDTFileEditViewController *fileEditVC = [splitVC.viewControllers lastObject];
    [fileEditVC closeDocument];
}

@end
