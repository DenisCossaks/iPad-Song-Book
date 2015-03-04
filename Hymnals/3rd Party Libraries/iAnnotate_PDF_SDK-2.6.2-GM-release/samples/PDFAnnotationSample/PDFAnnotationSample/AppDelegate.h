//
//  AppDelegate.h
//  AnnotationSample
//
//  Created by Branchfire, Inc. on 4/18/13.
//  Copyright (c) 2013 Branchfire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AjiPDFLib.h"

@class ViewController;
@class ViewController_Phone;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    APLibrary *library;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) ViewController_Phone *viewControllerPhone;

@end
