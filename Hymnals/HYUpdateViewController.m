//
//  HYUpdateViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 8/31/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYUpdateViewController.h"
#import "HYAppDelegate.h"

@implementation HYUpdateViewController

@synthesize contentView;

@synthesize isVisible;

#pragma mark - loading
- (id)init {
    if(self = [super initWithNibName:nil bundle:nil]) {
        mainWindow = [[UIApplication sharedApplication] keyWindow];
        
		[(HYAppDelegate*)[[UIApplication sharedApplication] delegate] setBlockingWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
		[[(HYAppDelegate*)[[UIApplication sharedApplication] delegate] blockingWindow] setWindowLevel:1.0];
		[[(HYAppDelegate*)[[UIApplication sharedApplication] delegate] blockingWindow] setOpaque:NO];
        [[(HYAppDelegate*)[[UIApplication sharedApplication] delegate] blockingWindow] setRootViewController:self];
        
        self.view.alpha = 0;
        self.view.frame = [[(HYAppDelegate*)[[UIApplication sharedApplication] delegate] blockingWindow] bounds];
        self.contentView.alpha = 0;
        
        self.contentView.layer.cornerRadius = 10;
        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)show {
    [[(HYAppDelegate*)[[UIApplication sharedApplication] delegate] blockingWindow] makeKeyAndVisible];
    
    isVisible = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^(void) {
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self animateIn];
//        [self performSelector:@selector(animateIn) withObject:nil afterDelay:kAnimationDuration];
    }];
}

- (void)hide {
    isVisible = NO;
    [self animateOut];
}

- (void)animateIn {
    [UIView animateWithDuration:kAnimationDuration animations:^(void) {
        contentView.alpha = 1;
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:kAnimationDuration animations:^(void) {
        contentView.alpha = 0;
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [[(HYAppDelegate*)[[UIApplication sharedApplication] delegate] blockingWindow] setHidden:YES];
        [mainWindow makeKeyWindow];
    }];
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
}

@end