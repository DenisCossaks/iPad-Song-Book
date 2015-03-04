//
//  HYDownloadProgressViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/20/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface HYDownloadProgressViewController : UIViewController {
    UIWindow *mainWindow;
}

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UILabel *progresLabel;

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@property (nonatomic, assign) BOOL isVisible;

- (id)init;

- (void)show;
- (void)hide;
- (void)updateProgress:(CGFloat)progress;

@end
