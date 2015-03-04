//
//  PDFAnnotationSampleAppDelegate.h
//  PDFAnnotationSample
//
//  Copyright Aji, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFAnnotationSampleViewController;
@class APLibrary;

@interface PDFAnnotationSampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PDFAnnotationSampleViewController *viewController;
    APLibrary *m_ajiLibrary;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PDFAnnotationSampleViewController *viewController;

@end

