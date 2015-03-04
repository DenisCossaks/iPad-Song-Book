//
//  HYAnnotationToolbarView.h
//  Hymnals
//
//  Created by Stephen Bradley on 12/11/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYAnnotationToolbarView : UIView

@property (nonatomic, weak) IBOutlet UIButton *highlightButton;
@property (nonatomic, weak) IBOutlet UIButton *underlineButton;
@property (nonatomic, weak) IBOutlet UIButton *strikeoutButton;
@property (nonatomic, weak) IBOutlet UIButton *noteButton;
@property (nonatomic, weak) IBOutlet UIButton *typeButton;
@property (nonatomic, weak) IBOutlet UIButton *freeformButton;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@end
