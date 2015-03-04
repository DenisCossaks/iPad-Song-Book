//
//  HYRootViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AirTurnInterface/AirTurnInterface.h>
#import "NBPopoverController.h"
#import "HYWindow.h"

@interface HYRootViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIPopoverControllerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    BOOL isNotFirstLoad;
    BOOL isFullscreen;
    BOOL isAnimating;
}

@property (nonatomic, weak) IBOutlet UIView *navigationView;
@property (nonatomic, weak) IBOutlet UIView *helpView;
@property (nonatomic, weak) IBOutlet UIView *hintView;
@property (nonatomic, weak) IBOutlet UIView *supportView;

@property (nonatomic, weak) IBOutlet UITableView *libraryTableView;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *fullscreenHelpImageView;
@property (nonatomic, weak) IBOutlet UIImageView *helpHomeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *helpCloseImageView;

@property (nonatomic, weak) IBOutlet UIButton *hymnTitleButton;
@property (nonatomic, weak) IBOutlet UIButton *serviceListsButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *hymnalsListButton;
@property (nonatomic, weak) IBOutlet UIButton *listenButton;
@property (nonatomic, weak) IBOutlet UIButton *helpButton;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIButton *annotationButton;
@property (nonatomic, weak) IBOutlet UIButton *homeButton;
@property (nonatomic, weak) IBOutlet UIButton *storeButton;

@property (nonatomic, weak) IBOutlet UILabel *listNameLabel;

@property (nonatomic, strong) UIPageViewController *contentPageViewController;

@property (nonatomic, strong) NBPopoverController *contentPopoverController;

@property (nonatomic, strong) NSMutableArray *individualPagesArray;

@property (nonatomic, strong) NSArray *ownedArray;

@property (nonatomic, strong) NSString *listNameString;

@property (nonatomic, assign) BOOL isShowingHome;

- (IBAction)hymnTitleButtonTouched;
- (IBAction)backButtonTouched;
- (IBAction)forwardButtonTouched;
- (IBAction)serviceListsButtonTouched;
- (IBAction)addButtonTouched;
- (IBAction)hymnalsListButtonTouched;
- (IBAction)listenButtonTouched;
- (IBAction)homeButtonTouched;
- (IBAction)sampleButtonTouched:(UIButton*)sender;
- (IBAction)hymnalButtonTouched:(UIButton*)sender;
- (IBAction)getSatisfactionButtonTouched;
- (IBAction)helpButtonTouched;
- (IBAction)searchButtonTouched;
- (IBAction)annotationButtonTouched;
- (IBAction)storeButtonTouched:(id)sender;
@end
