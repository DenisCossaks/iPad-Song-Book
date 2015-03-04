//
//  HYWindow.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/24/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYWindow.h"

@implementation HYWindow

@synthesize viewToObserve;

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    
    if (!viewToObserve) {
        return;   
    }
    
    NSSet *touches = [event allTouches];
    if (touches.count != 1) {
        return;
    }
    
    UITouch *touch = touches.anyObject;
    if (touch.tapCount == 2) {
        CGPoint tapPoint = [touch locationInView:viewToObserve];
        CGRect tappableRect = CGRectMake(viewToObserve.frame.size.width * .2 , viewToObserve.frame.origin.y, viewToObserve.frame.size.width * .6, viewToObserve.frame.size.height);
        if (CGRectContainsPoint(tappableRect, tapPoint)) {
            //if([viewToObserve pointInside:tapPoint withEvent:nil]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDoubleTapDetected object:nil];
        }
    }
}

@end
