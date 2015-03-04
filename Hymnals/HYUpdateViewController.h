//
//  HYUpdateViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 8/31/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYUpdateViewController : UIViewController {
    UIWindow *mainWindow;
}

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, assign) BOOL isVisible;

- (id)init;

- (void)show;
- (void)hide;

@end
