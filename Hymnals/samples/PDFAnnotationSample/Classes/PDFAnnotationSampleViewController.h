//
//  PDFAnnotationSampleViewController.h
//  PDFAnnotationSample
//
//  Copyright Aji, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AjiPDFLib.h"

@interface PDFAnnotationSampleViewController : UIViewController <APAnnotatingPDFViewDelegate, APPDFProcessorDelegate>
{
    IBOutlet UIView *hostView;
    IBOutlet UIActivityIndicatorView *spinnerView;
    IBOutlet UIBarButtonItem *processButton;
    IBOutlet UIBarButtonItem *noteButton;
    IBOutlet UIBarButtonItem *highlightButton;
    IBOutlet UIBarButtonItem *underlineButton;
    IBOutlet UIBarButtonItem *photoButton;
    IBOutlet UIBarButtonItem *inkButton;
    IBOutlet UIBarButtonItem *straightLineButton;
    IBOutlet UIBarButtonItem *bookmarkButton;
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *finishButton;
    IBOutlet UIBarButtonItem *outlineButton;
    IBOutlet UIBarButtonItem *goToPageButton;
    IBOutlet UIBarButtonItem *annotationsButton;
    IBOutlet UIBarButtonItem *bookmarksButton;
    IBOutlet UIBarButtonItem *syncButton;
    IBOutlet UIBarButtonItem *flattenButton;
    IBOutlet UIBarButtonItem *searchButton;
    IBOutlet UIBarButtonItem *nextPageButton;
    IBOutlet UIBarButtonItem *prevPageButton;
    IBOutlet UIBarButtonItem *selectButton;
    IBOutlet UIToolbar *annotationToolbar;
    IBOutlet UIToolbar *navigationToolbar;
    
    APAnnotatingPDFViewController *pdfView;
}

@property(retain) UIView *hostView;
@property(retain) UIActivityIndicatorView *spinnerView;
@property(retain) UIBarButtonItem *processButton;
@property(retain) UIBarButtonItem *noteButton;
@property(retain) UIBarButtonItem *highlightButton;
@property(retain) UIBarButtonItem *underlineButton;
@property(retain) UIBarButtonItem *photoButton;
@property(retain) UIBarButtonItem *inkButton;
@property(retain) UIBarButtonItem *straightLineButton;
@property(retain) UIBarButtonItem *bookmarkButton;
@property(retain) UIBarButtonItem *cancelButton;
@property(retain) UIBarButtonItem *finishButton;
@property(retain) UIBarButtonItem *outlineButton;
@property(retain) UIBarButtonItem *goToPageButton;
@property(retain) UIBarButtonItem *annotationsButton;
@property(retain) UIBarButtonItem *bookmarksButton;
@property(retain) UIBarButtonItem *syncButton;
@property(retain) UIBarButtonItem *flattenButton;
@property(retain) UIBarButtonItem *searchButton;
@property(retain) UIBarButtonItem *nextPageButton;
@property(retain) UIBarButtonItem *prevPageButton;
@property(retain) UIBarButtonItem *selectButton;
@property(retain) UIToolbar *annotationToolbar;
@property(retain) UIToolbar *navigationToolbar;

-(IBAction)note;
-(IBAction)highlight;
-(IBAction)underline;
-(IBAction)photo;
-(IBAction)ink;
-(IBAction)straightLine;
-(IBAction)bookmark;
-(IBAction)finishCurrentAnnotation;
-(IBAction)cancelCurrentAnnotation;
-(IBAction)toggleSelectMode;
-(IBAction)outline;
-(IBAction)goToPage;
-(IBAction)annotations;
-(IBAction)bookmarks;
-(IBAction)nextPage;
-(IBAction)prevPage;
-(IBAction)process;
-(IBAction)syncAnnotations;
-(IBAction)flatten;
-(IBAction)search;

@end

