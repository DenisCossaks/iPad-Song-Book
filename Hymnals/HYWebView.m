//
//  HYWebView.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/24/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYWebView.h"

@implementation HYWebView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self removeDoubleTapInView:self];
}

- (void)removeDoubleTapInView:(UIView *)view {
    for (UIView *subview in [view subviews]) {
        if (subview != view) {
            [self removeDoubleTapInView:subview];
        }
    }
    for (UIGestureRecognizer *reco in [view gestureRecognizers]) {
        if ([reco isKindOfClass:[UITapGestureRecognizer class]]) {
            if ([(UITapGestureRecognizer *)reco numberOfTapsRequired] == 2) {
                [view removeGestureRecognizer:reco];
            }
        }
    }
}

@end
