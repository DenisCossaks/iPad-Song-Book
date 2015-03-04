//
//  ViewController.h
//  AnnotationSample
//
//  Created by Branchfire, Inc. on 4/18/13.
//  Copyright (c) 2013 Branchfire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AjiPDFLib.h"

@interface ViewController : UIViewController <APAnnotatingPDFViewDelegate, APPDFProcessorDelegate, UIActionSheetDelegate>
{
    APAnnotatingPDFViewController *pdfView;
    UIActionSheet *actionSheet;
    
    IBOutlet UIView *hostView;
    IBOutlet UIBarButtonItem *syncButton;
    IBOutlet UIBarButtonItem *flattenButton;
    IBOutlet UIBarButtonItem *moreAnnosButton;
    IBOutlet UIToolbar *annotationToolbar;
}

-(IBAction)ink;
-(IBAction)highlight;
-(IBAction)underline;
-(IBAction)note;
-(IBAction)moreAnnotations;
-(IBAction)sync;
-(IBAction)flatten;

-(void)updateButtonsAnnotating:(BOOL)annotating;

@end
