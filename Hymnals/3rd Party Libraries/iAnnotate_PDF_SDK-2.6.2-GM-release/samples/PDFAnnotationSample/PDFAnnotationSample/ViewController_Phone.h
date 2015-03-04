//
//  ViewController_Phone.h
//  AnnotationSample
//
//  Created by Branchfire, Inc. on 5/2/13.
//  Copyright (c) 2013 Branchfire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AjiPDFLib.h"

@interface ViewController_Phone : UIViewController<APAnnotatingPDFViewDelegate, APPDFProcessorDelegate, UIActionSheetDelegate>
{
    APAnnotatingPDFViewController *pdfView;
    
    UIActionSheet *actionsActionSheet;
    UIActionSheet *annotationsActionSheet;
    UIActionSheet *penWidthActionSheet;
    UIActionSheet *colorActionSheet;
    
    IBOutlet UIView *hostView;
    IBOutlet UIToolbar *standardToolbar;
    IBOutlet UIToolbar *inkToolbar;
    IBOutlet UIToolbar *highlightToolbar;
    IBOutlet UIToolbar *noteToolbar;
}

-(IBAction)annotationSelection;
-(IBAction)actionSelection;

@end
