//
//  PDFAnnotationSampleAppDelegate.m
//  PDFAnnotationSample
//
//  Copyright Aji, LLC 2010. All rights reserved.
//

#import "PDFAnnotationSampleAppDelegate.h"
#import "PDFAnnotationSampleViewController.h"
#import "AjiPDFLib.h"


@implementation PDFAnnotationSampleAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    m_ajiLibrary = [[APLibrary alloc] initWithLicenseKey:@"FORSS-QSRWK-OIQEJ-KLQVL-GJKGT-HGVOU-OEROT-RPQTO" dataFolder:nil];
    NSAssert(nil != m_ajiLibrary, @"AjiPDFLib failed to initialize.");
    NSLog(@"Version: %@", [m_ajiLibrary versionString]);

    /* NOTE: the application root view controller should be defined so that UI elements (in particular, full-screen view of photos) can go fullscreen. */
    window.rootViewController = viewController;
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [m_ajiLibrary release];
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
