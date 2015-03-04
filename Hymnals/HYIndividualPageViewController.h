//
//  HYIndividualPageViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYWebView.h"
#import "AjiPDFLib.h"
#import "HYAnnotationToolbarView.h"
#import "HYRootViewController.h"

@interface HYIndividualPageViewController : APAnnotatingPDFViewController <UIAlertViewDelegate, APPDFViewDelegate, APAnnotatingPDFViewDelegate, APPDFProcessorDelegate> {
    UIView *pageCountView;
}

@property (nonatomic, weak) IBOutlet UIButton *pageUpButton;
@property (nonatomic, weak) IBOutlet UIButton *pageDownButton;
@property (nonatomic, weak) IBOutlet UIButton *firstPageButton;
@property (nonatomic, weak) IBOutlet UIButton *largePageUpButton;
@property (nonatomic, weak) IBOutlet UIButton *largePageDownButton;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) HYAnnotationToolbarView *annotationToolbar;

@property (nonatomic, weak) HYRootViewController *rootViewController;

@property (nonatomic, strong) NSDictionary *pageInfoDict;

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) CGFloat pageHeight;
@property (nonatomic, assign) CGFloat pageOffset;

@property (nonatomic, assign) BOOL isPageTurn;
@property (nonatomic, assign) BOOL isAnnotating;

- (id)initWithPageInfo:(NSDictionary*)info index:(NSInteger)index isPageTurn:(BOOL)pageTurn rootViewController:(HYRootViewController*)viewController;

- (IBAction)pageDownButtonTouched;
- (IBAction)pageUpButtonTouched;
- (IBAction)firstPageButtonTouched;

- (void)highlightButtonTouched;
- (void)underlineButtonTouched;
- (void)enterFullscreen:(NSNumber*)animated;

@end
