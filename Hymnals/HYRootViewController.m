//
//  HYRootViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYRootViewController.h"
#import "HYIndividualPageViewController.h"
#import "HYSearchViewController.h"
#import "HYNumberPadViewController.h"
#import "HYServiceListsViewController.h"
#import "HYAddHymnToServiceListViewController.h"
#import "HYHymnalListViewController.h"
#import "HYListenViewController.h"
#import "Reachability.h"
#import "SKBSStoreManager.h"
#import "HYHymnalCell.h"
#import "HYStoreViewController.h"
#import "Reachability.h"
#import "HYAlertView.h"

@implementation HYRootViewController

@synthesize navigationView;
@synthesize helpView;
@synthesize hintView;
@synthesize supportView;
@synthesize libraryTableView;
@synthesize backgroundImageView;
@synthesize fullscreenHelpImageView;
@synthesize helpHomeImageView;
@synthesize helpCloseImageView;
@synthesize hymnTitleButton;
@synthesize serviceListsButton;
@synthesize addButton;
@synthesize hymnalsListButton;
@synthesize listenButton;
@synthesize helpButton;
@synthesize searchButton;
@synthesize annotationButton;
@synthesize homeButton;
@synthesize storeButton;
@synthesize listNameLabel;

@synthesize contentPageViewController;
@synthesize contentPopoverController;
@synthesize individualPagesArray;
@synthesize ownedArray;
@synthesize listNameString;
@synthesize isShowingHome;

static NSInteger kTagRestorePurchases = 10;

#pragma mark - loading
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hymnSelected:) name:kHymnSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hymnalSelected:) name:kHymnalSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceListSelected:) name:kServiceListSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hymnAdded:) name:kHymnAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doubleTapDetected:) name:kDoubleTapDetected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeManagerProductsDownloaded:) name:kSKBSStoreManagerProductsDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airTurnEventReceived:) name:AirTurnButtonNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airTurnConnectionStateChanged:) name:AirTurnConnectedStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airTurnModeChanged:) name:AirTurnModeChangedNotification object:nil];
    
    [[AirTurnInterface sharedInterface] setEnabled:YES];
    [[AirTurnInterface sharedInterface] setParentView:self.view];
    [[AirTurnInterface sharedInterface] becomeFirstResponder];

    hymnTitleButton.titleLabel.numberOfLines = 2;
    hymnTitleButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    supportView.layer.cornerRadius = 10;
    supportView.layer.masksToBounds = YES;
        
    contentPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    contentPageViewController.delegate = self;
    contentPageViewController.dataSource = self;
    
    [self addChildViewController:contentPageViewController];
    [self.view insertSubview:contentPageViewController.view belowSubview:helpView];
    [contentPageViewController didMoveToParentViewController:self];
    contentPageViewController.view.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);
    contentPageViewController.view.clipsToBounds = YES;
    contentPageViewController.view.hidden = YES;
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        backgroundImageView.image = [UIImage imageNamed:@"background-landscape"];
    }
    
    for (UIGestureRecognizer *gesturerec in contentPageViewController.gestureRecognizers) {
        gesturerec.delegate = self;
    }
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if([window isKindOfClass:[HYWindow class]]) {
            ((HYWindow*)window).viewToObserve = contentPageViewController.view;
            break;
        }
    }
    
    [self networkReachabilityChanged:nil];
    [self hymnAdded:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsFullscreen];
    
    isShowingHome = YES;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        backgroundImageView.image = [UIImage imageNamed:@"background-landscape"];
    }
    else {
        backgroundImageView.image = [UIImage imageNamed:@"background-portrait"];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableArray *allOwnedArray = [[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE isOwned = 1"] mutableCopy];
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    for(NSDictionary *ownedDict in allOwnedArray) {
        if(![[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_code = '%@'", [ownedDict objectForKey:@"hymnal_code"]] count]) {
            [removeArray addObject:ownedDict];
        }
    }
    [allOwnedArray removeObjectsInArray:removeArray];
    ownedArray = allOwnedArray;
    [libraryTableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[[SKBSStoreManager sharedStoreManager] checkForMissingPurchases];
}
#pragma mark - view transitioning
- (void)showHymnalsList:(BOOL)shouldLoadRestorePurchases hymnal:(NSDictionary *)hymnal {
    HYHymnalListViewController *hymnalListViewController = [[HYHymnalListViewController alloc] initWithNibName:nil bundle:nil];
    hymnalListViewController.shouldRedownloadPurchasesOnLoad = shouldLoadRestorePurchases;
    hymnalListViewController.hymnalToRedownload = hymnal;
    contentPopoverController = [[NBPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:hymnalListViewController]];
    contentPopoverController.delegate = self;
    [contentPopoverController presentPopoverFromRect:hymnalsListButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
#pragma mark - status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        backgroundImageView.image = [UIImage imageNamed:@"background-landscape"];
    }
    else {
        backgroundImageView.image = [UIImage imageNamed:@"background-portrait"];
    }
    
    [contentPopoverController.contentViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

#pragma mark - notifications
- (void)networkReachabilityChanged:(NSNotification*)notification {
    if([[contentPageViewController viewControllers] count]) {
        if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
            listenButton.alpha = .5;
            [listenButton setImage:[UIImage imageNamed:@"button-listen-off"] forState:UIControlStateNormal];
        }
        else if([[[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"audio_file"] isKindOfClass:[NSNull class]]) {
            listenButton.alpha = .5;
            [listenButton setImage:[UIImage imageNamed:@"button-listen-off"] forState:UIControlStateNormal];
        }
        else {
            listenButton.alpha = 1;
            [listenButton setImage:[UIImage imageNamed:@"button-listen"] forState:UIControlStateNormal];
        }
    }
}

- (void)hymnAdded:(NSNotification*)notification {
    [contentPopoverController dismissPopoverAnimated:YES];
//    NSArray *rawData = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE isOwned = 1 AND isComplete = 1"];
//    for(NSDictionary *hymnalDict in rawData) {
//        UIButton *hymnalButton;
//        if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"G3"]) {
//            hymnalButton = downloadG3Button;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"G3C"]) {
//            hymnalButton = downloadG3CButton;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"G3G"]) {
//            hymnalButton = downloadG3GButton;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"G3AK"]) {
//            hymnalButton = downloadG3KButton;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"W4"]) {
//            hymnalButton = downloadW4Button;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"W4C"]) {
//            hymnalButton = downloadW4CButton;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"W4G"]) {
//            hymnalButton = downloadW4GButton;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"W4AK"]) {
//            hymnalButton = downloadW4KButton;
//        }
//        else if ([[hymnalDict objectForKey:@"hymnal_code"] isEqualToString:@"LMGM"]) {
//            hymnalButton = downloadLMGMButton;
//        }
//        
//        hymnalButton.hidden = NO;
//        [hymnalButton setTitle:@"View" forState:UIControlStateNormal];
//    }
    [contentPopoverController dismissPopoverAnimated:YES];
}

- (void)hymnSelected:(NSNotification*)notification {
    self.individualPagesArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT hymnals.* FROM hymnals WHERE hymnal_code = '%@' ORDER BY hymnal_number, sort", [[notification object] objectForKey:@"hymnal_code"]];
    listNameString = nil;
    listNameLabel.hidden = YES;
    
    NSInteger lcv = 0;
    for (NSDictionary *dict in individualPagesArray) {
        if ([[dict objectForKey:@"id"] isEqual:[[notification object] objectForKey:@"id"]]) {

            [self logHymnViewed:dict];
            
            __weak HYRootViewController *weakSelf = self;
            [contentPageViewController setViewControllers:[NSArray arrayWithObject:[[HYIndividualPageViewController alloc] initWithPageInfo:dict index:lcv isPageTurn:NO rootViewController:self]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:^(BOOL finished) {
                if (finished) {
                    HYRootViewController *strongSelf = weakSelf;
                    if (strongSelf.isShowingHome) {
                        [strongSelf homeButtonTouched];
                    }
                    else {
                        [strongSelf.annotationButton setImage:[UIImage imageNamed:@"button-annotate-off"] forState:UIControlStateNormal];
                        strongSelf.annotationButton.selected = NO;
                    }
                    [strongSelf networkReachabilityChanged:nil];
                }
            }];
            [contentPopoverController dismissPopoverAnimated:YES];
            [self popoverControllerShouldDismissPopover:contentPopoverController];
            break;
        }
        lcv++;
    }
}

- (void)hymnalSelected:(NSNotification*)notification {
    if ([self presentedViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    self.individualPagesArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT hymnals.* FROM hymnals WHERE hymnal_code = '%@' ORDER BY hymnal_number, sort", [[notification object] objectForKey:@"hymnal_code"]];
    listNameString = nil;
    listNameLabel.hidden = YES;
    
    if (!individualPagesArray.count) { // edge case: if the "Imported Music" book is shown, and the user deletes all the imported music, tapping on the book will crash the app
        ShowAlert(@"", @"There is not any imported music.");
        return;
    }
    
    NSDictionary *hymnal = [individualPagesArray objectAtIndex:0];
    HYIndividualPageViewController *individualPageViewController = [[HYIndividualPageViewController alloc] initWithPageInfo:hymnal index:0 isPageTurn:NO rootViewController:self];
    if (!individualPageViewController) {
        HYAlertView *alertView = [[HYAlertView alloc] initWithTitle:@"Unable to Load Hymnal" message:@"Hymnals will redownload it into your library." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = kTagRestorePurchases;
        alertView.objectOfInterest1 = hymnal;
        [alertView show];
        return;
    }
    [self logHymnViewed:hymnal];
    __weak HYRootViewController *weakSelf = self;
    [contentPageViewController setViewControllers:@[individualPageViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:^(BOOL finished) {
        if (finished) {
            HYRootViewController *strongSelf = weakSelf;
            if (strongSelf.isShowingHome) {
                [strongSelf homeButtonTouched];
            }
            else {
                [strongSelf.annotationButton setImage:[UIImage imageNamed:@"button-annotate-off"] forState:UIControlStateNormal];
                strongSelf.annotationButton.selected = NO;
            }
            [strongSelf networkReachabilityChanged:nil];
        }
    }];
    
    isNotFirstLoad = YES;    
    [contentPopoverController dismissPopoverAnimated:YES];
    [self popoverControllerShouldDismissPopover:contentPopoverController];
}

- (void)serviceListSelected:(NSNotification*)notification {
    self.individualPagesArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT hymnals.*, servicelist_hymnals.display_order, servicelist_hymnals.id FROM servicelist_hymnals, hymnals WHERE servicelist_hymnals.servicelist_id = %@ AND servicelist_hymnals.hymnal_id = hymnals.id ORDER BY servicelist_hymnals.display_order", [[notification object] objectForKey:@"servicelistId"]];
    
    NSInteger currentPage = [[[notification object] objectForKey:@"currentPage"] integerValue];
    listNameString = [[notification object] objectForKey:@"listName"];
    listNameLabel.hidden = NO;
    
    NSDictionary *hymn = [individualPagesArray objectAtIndex:0];
    [self logHymnViewed:hymn];
    
    __weak HYRootViewController *weakSelf = self;
    [contentPageViewController setViewControllers:[NSArray arrayWithObject:[[HYIndividualPageViewController alloc] initWithPageInfo:[individualPagesArray objectAtIndex:currentPage] index:currentPage isPageTurn:NO rootViewController:self]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:^(BOOL finished) {
        if (finished) {
            HYRootViewController *strongSelf = weakSelf;
            if (strongSelf.isShowingHome) {
                [strongSelf homeButtonTouched];
            }
            else {
                [strongSelf.annotationButton setImage:[UIImage imageNamed:@"button-annotate-off"] forState:UIControlStateNormal];
                strongSelf.annotationButton.selected = NO;
            }
            [strongSelf networkReachabilityChanged:nil];
        }
    }];
    
    [contentPopoverController dismissPopoverAnimated:YES];
    [self popoverControllerShouldDismissPopover:contentPopoverController];
}

- (void)doubleTapDetected:(NSNotification*)notifation {
    if(!isAnimating && ![contentPopoverController isPopoverVisible] && !isShowingHome && !helpView.alpha) {
        isAnimating = YES;
        if (isFullscreen) {
            [Flurry logEvent:@"Reader - Fullscreen Dismiss"];
            isFullscreen = NO;
            fullscreenHelpImageView.hidden = YES;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsFullscreen];
            [UIView animateWithDuration:kAnimationDuration animations:^ {
                if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                    contentPageViewController.view.frame = CGRectMake(0, 44, self.view.frame.size.height, self.view.frame.size.width - 44);
                }
                else {
                    contentPageViewController.view.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);
                }
                navigationView.frame = CGRectMake(0, 0, navigationView.frame.size.width, navigationView.frame.size.height);
            } completion:^(BOOL finished) {
                isAnimating = NO; 
                hintView.hidden = NO;
            }];
        }
        else {
            [Flurry logEvent:@"Reader - Fullscreen Enter"];
            isFullscreen = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsFullscreen];
            [[contentPageViewController.viewControllers objectAtIndex:0] performSelectorOnMainThread:@selector(enterFullscreen:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
            [UIView animateWithDuration:kAnimationDuration animations:^ {
                if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                    contentPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
                }
                else {
                    contentPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                }
                navigationView.frame = CGRectMake(0, -44, navigationView.frame.size.width, navigationView.frame.size.height);
            }completion:^(BOOL finished) {
                isAnimating = NO; 
                hintView.hidden = YES;
                fullscreenHelpImageView.hidden = NO;
            }];
        }
    }
}

- (void)storeManagerProductsDownloaded:(NSNotification*)notification {
    for(SKProduct *product in [[notification userInfo] objectForKey:@"Products"]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:product.priceLocale];
        
        //NSLog(@"Detected Product: %@", product.productIdentifier);
        
//        if([product.productIdentifier isEqualToString:@"com.gia.G3"]) {
//            G3PriceLabel.text = [G3PriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadG3Button.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.G3C"]) {
//            G3CPriceLabel.text = [G3CPriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadG3CButton.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.G3G"]) {
//            G3GPriceLabel.text = [G3GPriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadG3GButton.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.G3AK"]) {
//            G3KPriceLabel.text = [G3KPriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadG3KButton.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.W4"]) {
//            W4PriceLabel.text = [W4PriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadW4Button.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.W4C"]) {
//            W4CPriceLabel.text = [W4CPriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadW4CButton.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.W4G"]) {
//            W4GPriceLabel.text = [W4GPriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadW4GButton.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.W4AK"]) {
//            W4KPriceLabel.text = [W4KPriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadW4KButton.hidden = NO;
//        }
//        else if([product.productIdentifier isEqualToString:@"com.gia.LMGM"]) {
//            LMGMPriceLabel.text = [LMGMPriceLabel.text stringByAppendingString:[formatter stringFromNumber:product.price]];
//            downloadLMGMButton.hidden = NO;
//        }
    }
}

- (void)airTurnEventReceived:(NSNotification*)notification {
    AirTurnPort button = [(NSNumber *)[[notification userInfo] objectForKey:AirTurnButtonPressedKey] intValue];
    NSLog(@"Port: %d", button);
    
    switch (button) {
        case AirTurnPort1:
            [self backButtonTouched];
            break;
        case AirTurnPort2:
            break;
        case AirTurnPort3:
            [self forwardButtonTouched];
            break;
        case AirTurnPort4:
            break;
        default:
            break;
    }
}

- (void)airTurnConnectionStateChanged:(NSNotification*)notification {
    //NSLog(@"airTurnConnectionStateChanged");
}

- (void)airTurnModeChanged:(NSNotification*)notification {
    //NSLog(@"airTurnModeChanged");
}

#pragma mark - actions
- (IBAction)serviceListsButtonTouched {
    contentPopoverController = [[NBPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:[[HYServiceListsViewController alloc] initWithNibName:nil bundle:nil]]];
    contentPopoverController.delegate = self;
    [contentPopoverController presentPopoverFromRect:serviceListsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)hymnTitleButtonTouched {
    contentPopoverController = [[NBPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:[[HYNumberPadViewController alloc] initWithNibName:nil bundle:nil]]];
    contentPopoverController.delegate = self;
    [contentPopoverController presentPopoverFromRect:hymnTitleButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [hymnTitleButton setTitle:@"Type a Hymnal Number" forState:UIControlStateNormal];
    listNameLabel.hidden = YES;
}

- (IBAction)addButtonTouched {
    if([[contentPageViewController viewControllers] count]) {
        NSNumber *hymnalId = [[[contentPageViewController.viewControllers objectAtIndex:0] pageInfoDict] objectForKey:@"id"];
        contentPopoverController = [[NBPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:[[HYAddHymnToServiceListViewController alloc] initWithHymnalId:hymnalId]]];
        contentPopoverController.delegate = self;
        [contentPopoverController presentPopoverFromRect:addButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (IBAction)hymnalsListButtonTouched {
    [self showHymnalsList:NO hymnal:nil];
}
- (IBAction)listenButtonTouched {
    if([[contentPageViewController viewControllers] count]) {
        if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
            [[[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, an Internet connection is required to listen to audio sample." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        }
        else if([[[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"audio_file"] isKindOfClass:[NSNull class]]) {
            [[[UIAlertView alloc] initWithTitle:@"File Not Available" message:@"Sorry, we do not currently have an audio sample for this hymn." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        }
        else {
            if([[[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"audio_file"] length]) {
                contentPopoverController = [[NBPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:[[HYListenViewController alloc] initWithHymnAudioFile:[[[contentPageViewController.viewControllers objectAtIndex:0] pageInfoDict] objectForKey:@"audio_file"]
                                   itunes:[[[contentPageViewController.viewControllers objectAtIndex:0] pageInfoDict] objectForKey:@"itunes"]]]];
                contentPopoverController.delegate = self;
                [contentPopoverController presentPopoverFromRect:listenButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"File Not Available" message:@"Sorry, we do not currently have an audio sample for this hymn." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            }
        }
    }
}

- (IBAction)backButtonTouched {
    if([[contentPageViewController viewControllers] count]) {
        if([[(HYIndividualPageViewController*)[[contentPageViewController viewControllers] objectAtIndex:0] pdf] pageCount] > 1 && [(HYIndividualPageViewController*)[[contentPageViewController viewControllers] objectAtIndex:0] currentPage] > 1) {
            [(HYIndividualPageViewController*)[[contentPageViewController viewControllers] objectAtIndex:0] pageUpButtonTouched];
        }
        else {        
            NSUInteger currentIndex = [[[contentPageViewController viewControllers] objectAtIndex:0] pageIndex] - 1;
            
            if (currentIndex + 1) {
                __weak HYRootViewController *weakSelf = self;
                [contentPageViewController setViewControllers:[NSArray arrayWithObject:[[HYIndividualPageViewController alloc] initWithPageInfo:[individualPagesArray objectAtIndex:currentIndex] index:currentIndex isPageTurn:NO rootViewController:weakSelf]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                    if(finished) {
                        HYRootViewController *strongSelf = weakSelf;
                        if(strongSelf.isShowingHome) {
                            [strongSelf homeButtonTouched];
                        }
                        
                        NSString *versionString = @"";
                        if(![[[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"version"] isKindOfClass:[NSNull class]]) {
                            versionString = [NSString stringWithFormat:@" %@",  [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"version"]];
                        }

                        if (strongSelf.listNameString) {
                            strongSelf.listNameLabel.text = strongSelf.listNameString;
                            [strongSelf.hymnTitleButton setTitle:[NSString stringWithFormat:@"\n%@ #%@%@", [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_shortname"], [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
                        }
                        else if ([[[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_code"] isEqualToString:@"IM"]) {
                            [strongSelf.hymnTitleButton setTitle:[[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"title"] forState:UIControlStateNormal];
                        }
                        else {
                            [strongSelf.hymnTitleButton setTitle:[NSString stringWithFormat:@"%@ #%@%@", [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_shortname"], [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
                        }
                        [strongSelf networkReachabilityChanged:nil];
                    }
                }];
            }
        }
    }
}

- (IBAction)forwardButtonTouched {
    if([[contentPageViewController viewControllers] count]) {
        if([[(HYIndividualPageViewController*)[[contentPageViewController viewControllers] objectAtIndex:0] pdf] pageCount] > 1 && [[(HYIndividualPageViewController*)[[contentPageViewController viewControllers] objectAtIndex:0] pdf] pageCount] != [(HYIndividualPageViewController*)[[contentPageViewController viewControllers] objectAtIndex:0] currentPage]) {
            [(HYIndividualPageViewController*)[[contentPageViewController viewControllers] objectAtIndex:0] pageDownButtonTouched];
        }
        else {
            NSUInteger currentIndex = [[[contentPageViewController viewControllers] objectAtIndex:0] pageIndex] + 1;
            
            if (currentIndex < individualPagesArray.count) {
                __weak HYRootViewController *weakSelf = self;
                [contentPageViewController setViewControllers:[NSArray arrayWithObject:[[HYIndividualPageViewController alloc] initWithPageInfo:[individualPagesArray objectAtIndex:currentIndex] index:currentIndex isPageTurn:NO rootViewController:weakSelf]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                    if(finished) {
                        HYRootViewController *strongSelf = weakSelf;
                        if(strongSelf.isShowingHome) {
                            [strongSelf homeButtonTouched];
                        }
                        
                        NSString *versionString = @"";
                        if(![[[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"version"] isKindOfClass:[NSNull class]]) {
                            versionString = [NSString stringWithFormat:@" %@",  [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"version"]];
                        }
                        
                        if (strongSelf.listNameString) {
                            strongSelf.listNameLabel.text = strongSelf.listNameString;
                            [strongSelf.hymnTitleButton setTitle:[NSString stringWithFormat:@"\n%@ #%@%@", [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_shortname"], [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
                        }
                        else if ([[[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_code"] isEqualToString:@"IM"]) {
                            [strongSelf.hymnTitleButton setTitle:[[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"title"] forState:UIControlStateNormal];
                        }
                        else {
                            [strongSelf.hymnTitleButton setTitle:[NSString stringWithFormat:@"%@ #%@%@", [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_shortname"], [[strongSelf.individualPagesArray objectAtIndex:currentIndex] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
                        }
                        [strongSelf networkReachabilityChanged:nil];
                    }
                }];
            }
        }
    }
}

- (IBAction)homeButtonTouched {
    if (isShowingHome && contentPageViewController.viewControllers.count) {
        [Flurry logEvent:@"Reader - Home Touched - Show Reader"];
        supportView.hidden = YES;
        hintView.hidden = NO;
        libraryTableView.hidden = YES;
        contentPageViewController.view.hidden = NO;
        helpButton.hidden = NO;
        annotationButton.hidden = NO;
        homeButton.hidden = NO;
        addButton.hidden = NO;
        listenButton.hidden = NO;
        storeButton.hidden = YES;
        isShowingHome = NO;
        helpHomeImageView.image = [UIImage imageNamed:@"help-home-2"];
    }
    else {
        [Flurry logEvent:@"Reader - Home Touched - Hide Reader"];
        supportView.hidden = NO;
        hintView.hidden = YES;
        libraryTableView.hidden = NO;
        contentPageViewController.view.hidden = YES;
        helpButton.hidden = YES;
        annotationButton.hidden = YES;
        homeButton.hidden = YES;
        addButton.hidden = YES;
        listenButton.hidden = YES;
        storeButton.hidden = NO;
        isShowingHome = YES;
        helpHomeImageView.image = [UIImage imageNamed:@"help-home"];
    }
    [annotationButton setImage:[UIImage imageNamed:@"button-annotate-off"] forState:UIControlStateNormal];
    annotationButton.selected = NO;
}

- (IBAction)sampleButtonTouched:(UIButton*)sender {
    NSArray *resultsArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE id = %i", sender.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHymnSelected object:[resultsArray objectAtIndex:0]];
}

- (IBAction)hymnalButtonTouched:(UIButton*)sender {
    NSString *hymnal_code;
//    if ([sender isEqual:downloadG3Button]) {
//        hymnal_code = @"G3";
//    }
//    else if ([sender isEqual:downloadG3CButton]) {
//        hymnal_code = @"G3C";
//    }
//    else if ([sender isEqual:downloadG3GButton]) {
//        hymnal_code = @"G3G";
//    }
//    else if ([sender isEqual:downloadG3KButton]) {
//        hymnal_code = @"G3AK";
//    }
//    else if ([sender isEqual:downloadW4Button]) {
//        hymnal_code = @"W4";
//    }
//    else if ([sender isEqual:downloadW4CButton]) {
//        hymnal_code = @"W4C";
//    }
//    else if ([sender isEqual:downloadW4GButton]) {
//        hymnal_code = @"W4G";
//    }
//    else if ([sender isEqual:downloadW4KButton]) {
//        hymnal_code = @"W4AK";
//    }
    
    NSArray *resultsArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE hymnal_code = %@", SQLEscapeAndQuote(hymnal_code)];
    if([sender.titleLabel.text isEqualToString:@"View"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHymnalSelected object:[NSDictionary dictionaryWithObjectsAndKeys:[[resultsArray objectAtIndex:0] objectForKey:@"hymnal_code"] , @"hymnal_code", nil]];
    }
    else {
        [self hymnalsListButtonTouched];

        NSDictionary *hymnal = resultsArray[0];
        if([[hymnal objectForKey:@"isOwned"] boolValue]) {
            [(HYHymnalListViewController*)((UINavigationController*)contentPopoverController.contentViewController).topViewController downloadHymnalWithInfo:hymnal includeAllMissingHymnals:NO];
        }
        else {
            [(HYHymnalListViewController*)((UINavigationController*)contentPopoverController.contentViewController).topViewController purchaseHymnalWithInfo:hymnal];
        }
    }
}

- (IBAction)getSatisfactionButtonTouched {
    [Flurry logEvent:@"Reader - Support Touched"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://getsatisfaction.com/hymnals/products/hymnals_hymnals_ipad_app"]];
}

- (IBAction)helpButtonTouched {
    [Flurry logEvent:@"Reader - Help Touched"];
    if(helpView.alpha) {
        [UIView animateWithDuration:kAnimationDuration animations:^ {
            helpView.alpha = 0;
        }];
    }
    else {
        [UIView animateWithDuration:kAnimationDuration animations:^ {
            helpView.alpha = 1;
        }];
    }
}

- (IBAction)searchButtonTouched {
    contentPopoverController = [[NBPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:[[HYSearchViewController alloc] initWithNibName:nil bundle:nil]]];
    contentPopoverController.delegate = self;
    [contentPopoverController presentPopoverFromRect:searchButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)annotationButtonTouched {
    annotationButton.selected = !annotationButton.selected;
    if (annotationButton.selected) {
        [annotationButton setImage:[UIImage imageNamed:@"button-annotate-on"] forState:UIControlStateNormal];
    }
    else {
        [annotationButton setImage:[UIImage imageNamed:@"button-annotate-off"] forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnnotationModeChanged object:[NSNumber numberWithBool:annotationButton.selected]];
}
- (IBAction)storeButtonTouched:(id)sender {
    if ([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
        ShowAlert(nil, @"An internet connection is needed to access the Hymnals Store");
        return;
    }
    else if (![[SKBSStoreManager sharedStoreManager] productsLoaded]) {
        ShowAlert(nil, @"The available Hymnal information has not been fetched from the iTunes Store yet, please try again later");
        return;
    }
    
    HYStoreViewController *storeViewController =  [[self storyboard] instantiateViewControllerWithIdentifier:@"HYStoreViewController1"];;
    [storeViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:storeViewController animated:YES];
}
#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  ceilf(ownedArray.count / 4.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYHymnalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYHymnalCell"];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.hymnalArray = ownedArray;
    [cell reloadCell];
    return cell;
}

#pragma mark - hymnalcell
- (void)hymnalCell:(HYHymnalCell *)hymnalCell selectedHymnal:(NSDictionary *)hymnal {
    if ([[hymnal objectForKey:@"isComplete"] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHymnalSelected object:[NSDictionary dictionaryWithObjectsAndKeys:[hymnal objectForKey:@"hymnal_code"] , @"hymnal_code", nil]];
    }
    else {
        [self hymnalsListButtonTouched];
        [(HYHymnalListViewController*)((UINavigationController*)contentPopoverController.contentViewController).topViewController downloadHymnalWithInfo:hymnal includeAllMissingHymnals:NO];
    }
}

#pragma mark - pageviewcontroller
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(completed) {
        [self networkReachabilityChanged:nil];
        if (self.individualPagesArray.count == 1) {
            NSString *versionString = @"";
            versionString = [NSString stringWithFormat:@" %@",  [[self.individualPagesArray lastObject] objectForKey:@"version"]];
            
            if (self.listNameString) {
                self.listNameLabel.text = self.listNameString;
                [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"\n%@ #%@%@", [[self.individualPagesArray lastObject] objectForKey:@"hymnal_shortname"], [[self.individualPagesArray lastObject] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
            }
            else if ([[[self.individualPagesArray lastObject] objectForKey:@"hymnal_code"] isEqualToString:@"IM"]) {
                [self.hymnTitleButton setTitle:[[self.individualPagesArray lastObject] objectForKey:@"title"] forState:UIControlStateNormal];
            }
            else {
                [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"%@ #%@%@", [[self.individualPagesArray lastObject] objectForKey:@"hymnal_shortname"], [[self.individualPagesArray lastObject] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
            }
            
            NSDictionary *hymn = [self.individualPagesArray lastObject];
            [self logHymnViewed:hymn];
        }
        else if([[[pageViewController viewControllers] objectAtIndex:0] pageIndex] > [[previousViewControllers objectAtIndex:0] pageIndex]) {
            NSString *versionString = @"";
            if (![[[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"version"] isKindOfClass:[NSNull class]]) {
                versionString = [NSString stringWithFormat:@" %@",  [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"version"]];
            }

            if (self.listNameString) {
                self.listNameLabel.text = self.listNameString;
                [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"\n%@ #%@%@", [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"hymnal_shortname"], [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
            }
            else if ([[[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"hymnal_code"] isEqualToString:@"IM"]) {
                [self.hymnTitleButton setTitle:[[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"title"] forState:UIControlStateNormal];
            }
            else {
                [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"%@ #%@%@", [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"hymnal_shortname"], [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
            }
            
            NSDictionary *hymn = [self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] + 1];
            [self logHymnViewed:hymn];
        }
        else {
            NSString *versionString = @"";
            if (![[[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"version"] isKindOfClass:[NSNull class]]) {
                versionString = [NSString stringWithFormat:@" %@",  [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"version"]];
            }
            
            if (self.listNameString) {
                self.listNameLabel.text = self.listNameString;
                [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"\n%@ #%@%@", [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"hymnal_shortname"], [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
            }
            else if ([[[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"hymnal_code"] isEqualToString:@"IM"]) {
                [self.hymnTitleButton setTitle:[[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"title"] forState:UIControlStateNormal];
            }
            else {
                [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"%@ #%@%@", [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"hymnal_shortname"], [[self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
            }
            
            NSDictionary *hymn = [self.individualPagesArray objectAtIndex:[[previousViewControllers objectAtIndex:0] pageIndex] - 1];
            [self logHymnViewed:hymn];
        }
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = ((HYIndividualPageViewController*)viewController).pageIndex - 1;
    if (currentIndex + 1) {
        return [[HYIndividualPageViewController alloc] initWithPageInfo:[individualPagesArray objectAtIndex:currentIndex] index:currentIndex isPageTurn:YES rootViewController:self];
    }
    return [[HYIndividualPageViewController alloc] initWithPageInfo:[individualPagesArray lastObject] index:individualPagesArray.count isPageTurn:YES rootViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = ((HYIndividualPageViewController*)viewController).pageIndex + 1;
    if (currentIndex < individualPagesArray.count) {
        return [[HYIndividualPageViewController alloc] initWithPageInfo:[individualPagesArray objectAtIndex:currentIndex] index:currentIndex isPageTurn:YES rootViewController:self];
    }
    return [[HYIndividualPageViewController alloc] initWithPageInfo:[individualPagesArray objectAtIndex:0] index:0 isPageTurn:YES rootViewController:self];
}

#pragma mark - popovercontroller
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {    
    if([[contentPageViewController viewControllers] count]) {
        NSString *versionString = @"";
        if(![[[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"version"] isKindOfClass:[NSNull class]]) {
            versionString = [NSString stringWithFormat:@" %@", [[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"version"]];
        }
        
        if (listNameString) {
            self.listNameLabel.text = self.listNameString;
            self.listNameLabel.hidden = NO;
            [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"\n%@ #%@%@", [[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"hymnal_shortname"], [[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
        }
        else if ([[[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"hymnal_code"] isEqualToString:@"IM"]) {
            [self.hymnTitleButton setTitle:[[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"title"] forState:UIControlStateNormal];
        }
        else {
            [self.hymnTitleButton setTitle:[NSString stringWithFormat:@"%@ #%@%@", [[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"hymnal_shortname"], [[[[contentPageViewController viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"hymnal_number"], versionString] forState:UIControlStateNormal];
        }
    }
    
    return YES;
}

#pragma mark - gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint([[[contentPageViewController.viewControllers objectAtIndex:0] pageDownButton] frame], [touch locationInView:[[contentPageViewController.viewControllers objectAtIndex:0] view]]) || CGRectContainsPoint([[[contentPageViewController.viewControllers objectAtIndex:0] pageUpButton] frame], [touch locationInView:[[contentPageViewController.viewControllers objectAtIndex:0] view]]) || CGRectContainsPoint([[[contentPageViewController.viewControllers objectAtIndex:0] firstPageButton] frame], [touch locationInView:[[contentPageViewController.viewControllers objectAtIndex:0] view]]) || CGRectContainsPoint([[[contentPageViewController.viewControllers objectAtIndex:0] largePageDownButton] frame], [touch locationInView:[[contentPageViewController.viewControllers objectAtIndex:0] view]]) || CGRectContainsPoint([[[contentPageViewController.viewControllers objectAtIndex:0] largePageUpButton] frame], [touch locationInView:[[contentPageViewController.viewControllers objectAtIndex:0] view]])) {
        return NO;
    }
    else if ([(HYIndividualPageViewController*)[contentPageViewController.viewControllers objectAtIndex:0] isAnnotating]) {
        return NO;
    }
    return YES;
}
#pragma mark - logging
- (void)logHymnViewed:(NSDictionary *)hymn {
    NSDictionary *paramsOfInterest = [hymn dictionaryByFilteringHymnValuesForFlurry];
    [Flurry logEvent:@"Reader - Hymn Viewed" withParameters:paramsOfInterest];
}
#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.contentPageViewController = nil;
    self.contentPopoverController = nil;
    self.individualPagesArray = nil;
    self.listNameString = nil;
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTagRestorePurchases) {
        [self showHymnalsList:YES hymnal:[(HYAlertView *)alertView objectOfInterest1]];
    }
}
@end
