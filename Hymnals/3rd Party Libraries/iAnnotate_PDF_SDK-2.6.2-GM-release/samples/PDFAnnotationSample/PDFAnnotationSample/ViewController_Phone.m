//
//  ViewController_Phone.m
//  AnnotationSample
//
//  Created by Branchfire, Inc. on 5/2/13.
//  Copyright (c) 2013 Branchfire, Inc. All rights reserved.
//

#import "ViewController_Phone.h"

@interface ViewController_Phone ()

@end

@implementation ViewController_Phone

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* For this sample, we store the PDF in the Documents area, and the information file in the Library area. */
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pdfPath = [[docPaths objectAtIndex:0] stringByAppendingPathComponent:@"test.pdf"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
        /* if the PDF isn't in the documents directly we get a copy from the application bundle */
        NSString *pdfBundlePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
        NSAssert(nil != pdfBundlePath, @"missing pdf in bundle?");
        [[NSFileManager defaultManager] copyItemAtPath:pdfBundlePath toPath:pdfPath error:nil];
    }
    
    /* Again, for this sample we keep the information files in the Library area. */
    NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *infoPath = [[libPaths objectAtIndex:0] stringByAppendingPathComponent:@"test.pdf.info"];
    
    /* Create the PDF information object; this will load the cached
     * file if it exists, or prepare it if it does not yet exist. */
    APPDFInformation *info = [[APPDFInformation alloc] initWithPath:infoPath];
    
    /* Now we create the PDF document object. If the information file
     * already exists then. */
    APPDFDocument *pdfDocument = [[APPDFDocument alloc] initWithPath:pdfPath information:info];
    
    /* We load and launch the annotating PDF view controller. */
    pdfView = [[APAnnotatingPDFViewController alloc] initWithPDF:pdfDocument];
    pdfView.delegate = self;
    pdfView.view.frame = hostView.bounds;
    pdfView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [pdfView fitToWidth];
    [hostView addSubview:pdfView.view];
    hostView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    /* Automatically process the PDF if it hasn't been already. We recommend
     * doing this on a background thread. */
    if (!pdfView.pdf.information.isProcessed)
    {
        [self performSelectorInBackground:@selector(doProcessing) withObject:nil];
    }
}

-(void)doProcessing
{
    /* Create an APPDFProcessor object to process the PDF; check status
     * in APPDFProcessorDelegate methods. Processing is required to
     * support search, PDF outlines, and hyperlinks. It will also show
     * previously made annotations (those that have been written into the
     * file itself). */
    APPDFProcessor *processor = [[APPDFProcessor alloc] init];
    processor.delegate = self;
    [processor processPDF:pdfView.pdf];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)annotationSelection
{
    annotationsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick An Annotation" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Highlight", @"Ink", @"Note", @"More Annotations?", nil];
    [annotationsActionSheet showFromToolbar:standardToolbar];
}

-(IBAction)actionSelection
{
    actionsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick An Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sync Annotations", @"Flatten PDF", nil];
    [actionsActionSheet showFromToolbar:standardToolbar];
}

-(IBAction)penWidthSelection
{
    penWidthActionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Pen Width" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 pixel", @"4 pixels", @"8 pixels", @"16 pixels", @"24 pixels", nil];
    [penWidthActionSheet showFromToolbar:inkToolbar];
}

-(IBAction)colorSelection
{
    colorActionSheet = [[UIActionSheet alloc] initWithTitle:@"Change the Annotation's Color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Red", @"Orange", @"Yellow", @"Green", @"Blue", @"Purple", nil];
    [colorActionSheet showFromToolbar:standardToolbar];
}

-(void)showOtherAnnotationsAlert
{
    NSString *string = [NSString stringWithFormat:@"For purposes of our sample application we only show three annotation types on the iPhone and iPod Touch. All annotations are available for these devices, as long as you create an interface for them."];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Other Annotations"
                                       message:string
                                       delegate:self
                                       cancelButtonTitle:@"Okay"
                                       otherButtonTitles:nil];
    [av show];
}

-(void)changePenWidthForActiveAnnoTo:(CGFloat)newWidth
{
    APInk *ink = (APInk *)[pdfView activeAnnotation];
    ink.penWidth = newWidth;
    [pdfView updateActiveAnnotation:ink];
}

-(void)performSync
{
    /* Create an APPDFProcessor object and sync annotations
     * to your PDF. Note that this step is not required when
     * placing an annotation, only when you want to ensure
     * that annotations are preserved when the PDF is exported
     * from your application. */
    APPDFProcessor *processor = [[APPDFProcessor alloc] init];
    processor.delegate = self;
    [processor syncAnnotationsToPDF:pdfView.pdf];
}

-(void)performFlatten
{
    /* To flatten, first create an APPDFProcessor object. */
    APPDFProcessor *processor = [[APPDFProcessor alloc] init];
    processor.delegate = self;
    
    /* Get a path for the flattened file. We automatically remove
     * any previous flattened files for purposes of this sample. */
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *flattenPath = [[docPaths objectAtIndex:0] stringByAppendingPathComponent:@"flattened.pdf"];
    [[NSFileManager defaultManager] removeItemAtPath:flattenPath error:nil];
    
    /* Write out a copy of the PDF with the flattened option. */
    [processor writePDFWithAnnotations:pdfView.pdf toPath:flattenPath options:[APPDFProcessorWriteOptions optionsWithFlags:kAPPDFWriteOptionsFlatten]];
}

-(IBAction)endAnnotationMode
{
    APAnnotation *annotation = [pdfView activeAnnotation];
    
    if ([annotation isKindOfClass:[APTextMarkup class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            highlightToolbar.frame = CGRectMake(0, self.view.frame.size.height, highlightToolbar.frame.size.width, highlightToolbar.frame.size.height);
        }];
    }
    else if ([annotation isKindOfClass:[APInk class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            inkToolbar.frame = CGRectMake(0, self.view.frame.size.height, inkToolbar.frame.size.width, inkToolbar.frame.size.height);
        }];
    }
    else if ([annotation isKindOfClass:[APText class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            noteToolbar.frame = CGRectMake(0, self.view.frame.size.height, noteToolbar.frame.size.width, noteToolbar.frame.size.height);
        }];
    }
    
    [pdfView finishCurrentAnnotation];
    [pdfView clearActiveAnnotation];
}

#pragma mark --
#pragma mark Action Sheet Delegate Implementations

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == annotationsActionSheet)
    {
        switch (buttonIndex)
        {
            case 0:
                [pdfView addAnnotationOfType:kAPAnnotationTypeHighlight];
                break;
            case 1:
                [pdfView addAnnotationOfType:kAPAnnotationTypeInk];
                break;
            case 2:
                [pdfView addAnnotationOfType:kAPAnnotationTypeNote];
                break;
            case 3:
                [self showOtherAnnotationsAlert];
                break;
            default:
                break;
        }
    }
    
    if (actionSheet == actionsActionSheet)
    {
        switch (buttonIndex)
        {
            case 0:
                [self performSelectorInBackground:@selector(performSync) withObject:nil];
                break;
            case 1:
                [self performSelectorInBackground:@selector(performFlatten) withObject:nil];
                break;
            default:
                break;
        }
    }
    
    if (actionSheet == penWidthActionSheet)
    {
        switch (buttonIndex)
        {
            case 0:
                [self changePenWidthForActiveAnnoTo:1.0];
                break;
            case 1:
                [self changePenWidthForActiveAnnoTo:4.0];
                break;
            case 2:
                [self changePenWidthForActiveAnnoTo:8.0];
                break;
            case 3:
                [self changePenWidthForActiveAnnoTo:16.0];
                break;
            case 4:
                [self changePenWidthForActiveAnnoTo:24.0];
                break;
            default:
                break;
        }
    }
    
    if (actionSheet == colorActionSheet)
    {
        /* JEEVES: For some reason the process below works to update colors in all cases EXCEPT when
         * the active anno is a Note anno that user just placed. Tap the note and modify its color later
         * and it works fine. Place a highlight or ink and it works fine. Cannot figure it out. */
        switch (buttonIndex)
        {
            case 0:
                [pdfView activeAnnotation].color = [APColor colorWithUIColor:[UIColor redColor]];
                break;
            case 1:
                [pdfView activeAnnotation].color = [APColor colorWithUIColor:[UIColor orangeColor]];
                break;
            case 2:
                [pdfView activeAnnotation].color = [APColor colorWithUIColor:[UIColor yellowColor]];
                break;
            case 3:
                [pdfView activeAnnotation].color = [APColor colorWithUIColor:[UIColor greenColor]];
                break;
            case 4:
                [pdfView activeAnnotation].color = [APColor colorWithUIColor:[UIColor blueColor]];
                break;
            case 5:
                [pdfView activeAnnotation].color = [APColor colorWithUIColor:[UIColor purpleColor]];
                break;
            default:
                break;
        }
        [pdfView updateActiveAnnotation:[pdfView activeAnnotation]];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    /* JEEVES: For some reason the modification toolbars return to origin.y == 568 when
     * the action sheet disappears. No clue why that's happening, so I just reshow the
     * appropriate sheet below. But if you know why definitely let me know. */
    APAnnotation *annotation = [pdfView activeAnnotation];
    
    if ([annotation isKindOfClass:[APTextMarkup class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            highlightToolbar.frame = CGRectMake(0, self.view.frame.size.height - highlightToolbar.frame.size.height, highlightToolbar.frame.size.width, highlightToolbar.frame.size.height);
        }];
    }
    else if ([annotation isKindOfClass:[APInk class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            inkToolbar.frame = CGRectMake(0, self.view.frame.size.height - highlightToolbar.frame.size.height, inkToolbar.frame.size.width, inkToolbar.frame.size.height);
        }];
    }
    else if ([annotation isKindOfClass:[APText class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            noteToolbar.frame = CGRectMake(0, self.view.frame.size.height - highlightToolbar.frame.size.height, noteToolbar.frame.size.width, noteToolbar.frame.size.height);
        }];
    }
}

#pragma mark --
#pragma mark Annotating PDF View Delegate Implementations

-(void)pdfController:(APAnnotatingPDFViewController *)controller didEnterAnnotationMode:(APAnnotationType)type
{
    switch (type) {
        case kAPAnnotationTypeHighlight:
        {
            [UIView animateWithDuration:0.2f animations:^{
                highlightToolbar.frame = CGRectMake(0, self.view.frame.size.height - highlightToolbar.frame.size.height, highlightToolbar.frame.size.width, highlightToolbar.frame.size.height);
            }];
        }
            break;
        case kAPAnnotationTypeInk:
        {
            [UIView animateWithDuration:0.2f animations:^{
                inkToolbar.frame = CGRectMake(0, self.view.frame.size.height - inkToolbar.frame.size.height, inkToolbar.frame.size.width, inkToolbar.frame.size.height);
            }];
        }
            break;
        case kAPAnnotationTypeNote:
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteToolbar.frame = CGRectMake(0, self.view.frame.size.height - noteToolbar.frame.size.height, noteToolbar.frame.size.width, noteToolbar.frame.size.height);
            }];
        }
            break;
        default:
            break;
    }
}

-(void)pdfController:(APPDFViewController *)controller didTapOnAnnotation:(APAnnotation *)annotation inRect:(CGRect)rect
{
    if ([annotation isKindOfClass:[APTextMarkup class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            highlightToolbar.frame = CGRectMake(0, self.view.frame.size.height - highlightToolbar.frame.size.height, highlightToolbar.frame.size.width, highlightToolbar.frame.size.height);
        }];
    }
    else if ([annotation isKindOfClass:[APInk class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            inkToolbar.frame = CGRectMake(0, self.view.frame.size.height - highlightToolbar.frame.size.height, inkToolbar.frame.size.width, inkToolbar.frame.size.height);
        }];
    }
    else if ([annotation isKindOfClass:[APText class]])
    {
        [UIView animateWithDuration:0.2f animations:^{
            noteToolbar.frame = CGRectMake(0, self.view.frame.size.height - highlightToolbar.frame.size.height, noteToolbar.frame.size.width, noteToolbar.frame.size.height);
        }];
    }
}

-(UIColor *)pdfController:(APAnnotatingPDFViewController *)controller colorForNewAnnotationOfType:(APAnnotationType)annotType
{
    /* Return a default color for each annotation type; you MUST provide a
     * a color for each type of annotation offered (or a default color). */
    switch (annotType)
    {
        case kAPAnnotationTypeNote:
            return [UIColor orangeColor];
            
        case kAPAnnotationTypeHighlight:
            return [UIColor yellowColor];
          
        case kAPAnnotationTypeInk:
            return [UIColor redColor];
            
        default:
            NSLog(@"Unhandled annotation type: %d", annotType);
            return [UIColor redColor];
    }
}

-(CGFloat)pdfController:(APAnnotatingPDFViewController *)controller thicknessForNewAnnotationOfType:(APAnnotationType)annotType
{
    return [APInk thicknessForInkPenWidth:4.0f];
}

# pragma mark --
# pragma mark PDF Processor Delegate Implementations

-(void)pdfProcessor:(APPDFProcessor *)processor didProcessPDF:(APPDFDocument *)pdf
{
    /* If you're using a spinner or other UI element to indicate processing
     * progress this would be a good place to end the animation. */
}

-(void)pdfProcessor:(APPDFProcessor *)processor failedToProcessPDF:(APPDFDocument *)pdf withError:(NSError *)error
{
    /* For purposes of the sample we show an alert view to indicate processing failed. */
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Processing Error"
                                                 message:[NSString stringWithFormat:@"Error: %@", error]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

-(void)pdfProcessor:(APPDFProcessor *)processor didSyncAnnotationsToPDF:(APPDFDocument *)pdf
{
    /* For purposes of the sample we show an alert view to indicate annotations
     * have successfully been written to the PDF. */
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Annotations Updated"
                                                 message:@"The annotations were successfully updated to the PDF file."
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

-(void)pdfProcessor:(APPDFProcessor *)processor failedToSyncAnnotationsToPDF:(APPDFDocument *)pdf withError:(NSError *)error
{
    /* For purposes of the sample we show an alert view to indicate annotations
     * could not be written to the PDF. */
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sync Annotations Error"
                                                 message:[NSString stringWithFormat:@"Error: %@", error]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

-(void)pdfProcessor:(APPDFProcessor *)processor didWritePDFWithAnnotations:(APPDFDocument *)pdf toPath:(NSString *)path
{
    /* For purposes of the sample we show an alert view to indicate that a copy
     * of the file was successfully written out, and provide the path. */
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Annotations Flattened"
                                                 message:@"The annotations were successfully flattened (in documents folder)."
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    NSLog(@"Flattened PDF is at: %@", path);
}

-(void)pdfProcessor:(APPDFProcessor *)processor failedToWritePDFWithAnnotations:(APPDFDocument *)pdf toPath:(NSString *)path withError:(NSError *)error
{
    /* For purposes of the sample we show an laert view to indicate that a copy
     * of the file could not be written out. */
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Flatten PDF Error"
                                                 message:[NSString stringWithFormat:@"Error: %@", error]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

@end
