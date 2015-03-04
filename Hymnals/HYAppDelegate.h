//
//  HYAppDelegate.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnInterface.h>
#import "HYWindow.h"
#import "SKBSStoreManager.h"
#import "SKBSWebOperationQueue.h"
#import "HYPublishedHymnalsWebOperation.h"
#import "HYHymnalInfoWebOperation.h"
#import "HYPDFDownloadWebOperation.h"
#import "HYDownloadProgressViewController.h"
#import "HYUpdateViewController.h"
#import "AjiPDFLib.h"
#import <MessageUI/MessageUI.h>
#import <HockeySDK/HockeySDK.h>

@interface HYAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, SKBSWebOperationDelegate, MFMailComposeViewControllerDelegate, BITHockeyManagerDelegate>

@property (nonatomic, strong) HYWindow *window;
@property (nonatomic, strong) UIWindow *blockingWindow;

@property (nonatomic, strong) HYUpdateViewController *updateViewController;

@property (nonatomic, strong) SKBSStoreManager *storeManager;

@property (nonatomic, strong) APLibrary *branchfireLibrary;

@property (nonatomic, strong) NSMutableArray *needsUpdateArray;

@end
