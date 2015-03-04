//
//  HYAnnotationToolbarView.m
//  Hymnals
//
//  Created by Stephen Bradley on 12/11/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYAnnotationToolbarView.h"

@implementation HYAnnotationToolbarView

@synthesize highlightButton;
@synthesize underlineButton;
@synthesize strikeoutButton;
@synthesize noteButton;
@synthesize typeButton;
@synthesize freeformButton;
@synthesize backgroundImageView;

#pragma mark - loading
- (id)initWithFrame:(CGRect)frame {
    self = [[[NSBundle mainBundle] loadNibNamed:@"HYAnnotationToolbarView" owner:nil options:nil] objectAtIndex:0];
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, self.frame.size.width, self.frame.size.height);
    
    backgroundImageView.image = [backgroundImageView.image stretchableImageWithLeftCapWidth:0 topCapHeight:30];
    
    
    if (IsIOS7OrNewer) {
        [noteButton setTitle:nil forState:UIControlStateNormal];
        [freeformButton setTitle:nil forState:UIControlStateNormal];
        [typeButton setTitle:nil forState:UIControlStateNormal];
    }
    
    return self;
}

@end
