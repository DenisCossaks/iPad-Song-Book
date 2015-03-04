//
//  ViewController.m
//  AnnotationSample
//
//  Created by Branchfire, Inc. on 4/18/13.
//  Copyright (c) 2013 Branchfire, Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

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
    [pdfView fitToWidth];
    pdfView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [hostView addSubview:pdfView.view];
    
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

#pragma mark --
#pragma mark Passing View Notifications

-(void)viewWillAppear:(BOOL)animated
{
    /* Overrides UIViewController method. Call this appropriately when adding the PDF view
     * to your application's view heirarchy. */
    [pdfView viewWillAppear:animated];
    [pdfView fitToWidth];
}

-(void)viewDidAppear:(BOOL)animated
{
    /* Overrides UIViewController method. Call this appropriately when adding the PDF view
     * to your application's view heirarchy. */
    [pdfView viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    /* Overrides UIViewController method. Call this appropriately when adding the PDF view
     * to your application's view heirarchy. */
    [pdfView viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    /* Overrides UIViewController method. Call this appropriately when adding the PDF view
     * to your application's view heirarchy. */
    [pdfView viewWillDisappear:animated];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /* UIViewController override. Be sure to call this appropriately when handling device auto-rotation.
     * If your application does not support rotation, then it is always safe to leave the view unrotated;
     * but rotating and resizing the view may have adverse effects in annotation mode, so this method
     * should be called to verify that the PDF view is in an appropriate state before allowing device
     * auto-rotation. */
    return (nil == pdfView ? YES : [pdfView shouldAutorotate]);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pdfView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [pdfView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark --
#pragma mark Action Handling

-(IBAction)ink
{
    /* Enter ink annotation mode. */
    [pdfView addAnnotationOfType:kAPAnnotationTypeInk];
}

-(IBAction)highlight
{
    /* Check to see if the page has text. You won't be able
     * to add a text markup if the page doesn't have text. */
    if (![pdfView.pdf.information hasText])
    {
        [self notifyNoText];
        return;
    }
    
    /* Enter highlight annotation mode. */
    [pdfView addAnnotationOfType:kAPAnnotationTypeHighlight];
}

-(IBAction)underline
{
    /* Check to see if the page has text. You won't be able
     * to add a text markup if the page doesn't have text. */
    if (![pdfView.pdf.information hasText])
{
        [self notifyNoText];
        return;
    }

    /* Enter underline annotation mode. */
    [pdfView addAnnotationOfType:kAPAnnotationTypeUnderline];
}

-(IBAction)note
{
    /* Enter note annotation mode. */
    [pdfView addAnnotationOfType:kAPAnnotationTypeNote];
}

-(IBAction)moreAnnotations
{
    /* Showing an action sheet with buttons for remaining annotations. Please note that
     * Sound Clip and Photo annotations cannot function correctly in the simulator, only
     * on device. */
    if (actionSheet.visible)
    {
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick an Annotation" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Strikeout", @"Stamp", @"Bookmark", @"Straight-Line", @"Free Text", @"Sound Clip", @"Photo", nil];
        [actionSheet showFromBarButtonItem:moreAnnosButton animated:YES];
    }
}

-(IBAction)sync
{
    /* Syncing annotations writes them into the PDF's file
     * structure, for later use in a compliant PDF application.
     * This should always be done on a background thread. */
    [self performSelectorInBackground:@selector(performSync) withObject:nil];
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

-(IBAction)flatten
{
    /* Flattening annotations draws them onto the same "layer"
     * as the PDF page, rendering them uneditable (and capable
     * of being printed. Several annotation types cannot be
     * flattened, so we leave a marker in their place. This
     * should always be done on a background thread. */
    [self performSelectorInBackground:@selector(performFlatten) withObject:nil];
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

-(void)notifyNoText
{
    /* Here we notify users when there's no text to markup
     * (for highlights and underlines - the strikeout button
     * in the popup will simply be disabled). */
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Text"
                                                 message:@"This PDF does not have any selectable text"
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

-(void)updateButtonsAnnotating:(BOOL)annotating
{
    /* While you can certainly sync annotations and write out PDFs
     * while in annotation mode, the active annotation will be
     * included. Therefore we disable these buttons while you're
     * annotating, so you don't sync or flatten an unfinished markup. */
    syncButton.enabled = !annotating;
    flattenButton.enabled = !annotating;
}

#pragma mark --
#pragma mark Action Sheet Delegate Implementations

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /* Enter annotation mode or each of the remaining annotation types. */
    switch (buttonIndex) {
        case 0:
            [pdfView addAnnotationOfType:kAPAnnotationTypeStrikeout];
            break;
        case 1:
            [pdfView addAnnotationOfType:kAPAnnotationTypeStamp];
            break;
        case 2:
            [pdfView addAnnotationOfType:kAPAnnotationTypeBookmark];
            break;
        case 3:
            [pdfView addAnnotationOfType:kAPAnnotationTypeStraightLine];
            break;
        case 4:
            [pdfView addAnnotationOfType:kAPAnnotationTypeFreeText];
            break;
        case 5:
            [pdfView addAnnotationOfType:kAPAnnotationTypeSound];
            break;
        case 6:
            [pdfView addAnnotationOfType:kAPAnnotationTypePhoto];
            break;
        default:
            break;
    }
}

#pragma mark --
#pragma mark Annotating PDF View Delegate Implementations

-(void)pdfController:(APAnnotatingPDFViewController *)controller didEnterAnnotationMode:(APAnnotationType)type
{
    /* Use this method to update your UI whenever the
     * PDF SDK enters annotation mode. */
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didPlaceAnnotation:(APAnnotation *)annotation
{
    /* This method returns when an annotation is placed
     * on the page; most useful for tracking when "single-tap
     * annotations" like notes are placed on a pdf. */
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didCreateAnnotation:(APAnnotation *)annotation
{
    /* This method tells you when a new annotation has 
     * been created. */
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didEndAnnotationMode:(APAnnotationType)type
{
    /* Use this method to update your UI whenever the
     * PDF SDK ends annotation mode (usually when the
     * "Done" or "Cancel" buttons are pressed in the
     * annotation ribbon. */
    [self updateButtonsAnnotating:NO];
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didModifyAnnotation:(APAnnotation *)annotation
{
    /* Use this method to update your UI whenever an
     * annotation has been modified. */
}

-(NSString *)pdfController:(APAnnotatingPDFViewController *)controller pathForAnnotationType:(APAnnotationType)annotType
{
    /* Provide a path to get an image for a stamp annotation. */
    if (kAPAnnotationTypeStamp != annotType)
        return nil;
    /* For purposes of this sample we return an arbitrary image from resources. */
    return [[NSBundle mainBundle] pathForResource:@"AP_stamp_toolbar@2x" ofType:@"png"];
}

-(UIColor *)pdfController:(APAnnotatingPDFViewController *)controller colorForNewAnnotationOfType:(APAnnotationType)annotType
{
    /* Return a default color for each annotation type; you MUST provide a
     * a color for each type of annotation offered (or a default color). */
    switch (annotType)
    {
        case kAPAnnotationTypeNote:
            return [UIColor yellowColor];
            
        case kAPAnnotationTypeHighlight:
            return [UIColor yellowColor];
            
        case kAPAnnotationTypeUnderline:
            return [UIColor blueColor];
            
        case kAPAnnotationTypeStrikeout:
            return [UIColor redColor];
            
        case kAPAnnotationTypeBookmark:
            return [UIColor orangeColor];
            
        case kAPAnnotationTypeInk:
            return [UIColor redColor];
            
        case kAPAnnotationTypeStraightLine:
            return [UIColor greenColor];
            
        case kAPAnnotationTypeFreeText:
            return [UIColor blackColor];
            
        case kAPAnnotationTypeSound:
        case kAPAnnotationTypePhoto:
        case kAPAnnotationTypeStamp:
            return nil;
            
        default:
            NSLog(@"Unhandled annotation type: %d", annotType);
            return [UIColor redColor];
    }
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
