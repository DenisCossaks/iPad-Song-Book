//
//  AppDelegate.m
//  AnnotationSample
//
//  Created by Matthew Calllahan on 4/18/13.
//  Copyright (c) 2013 Branchfire, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ViewController_Phone.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Initializing the iAnnotate PDF SDK's library. */
    library = [[APLibrary alloc] initWithLicenseKey:@"BQJNE-IRNMR-IPDQM-JUWRN-DNKFH-MTTTP-NJOKE-IQQMM " dataFolder:nil];
    NSAssert(nil != library, @"AjiPDFLib failed to initialize.");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        self.window.rootViewController = self.viewController;
    }
    else
    {
        self.viewControllerPhone = [[ViewController_Phone alloc] initWithNibName:@"ViewController_Phone" bundle:nil];
        self.window.rootViewController = self.viewControllerPhone;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
