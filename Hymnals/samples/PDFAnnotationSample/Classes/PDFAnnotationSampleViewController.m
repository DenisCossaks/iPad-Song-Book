//
//  PDFAnnotationSampleViewController.m
//  PDFAnnotationSample
//
//  Copyright Aji, LLC 2010. All rights reserved.
//

#import "PDFAnnotationSampleViewController.h"

@implementation PDFAnnotationSampleViewController


@synthesize hostView;
@synthesize spinnerView;
@synthesize processButton;
@synthesize noteButton;
@synthesize highlightButton;
@synthesize underlineButton;
@synthesize photoButton;
@synthesize inkButton;
@synthesize straightLineButton;
@synthesize bookmarkButton;
@synthesize finishButton;
@synthesize cancelButton;
@synthesize outlineButton;
@synthesize goToPageButton;
@synthesize annotationsButton;
@synthesize bookmarksButton;
@synthesize syncButton;
@synthesize flattenButton;
@synthesize searchButton;
@synthesize nextPageButton;
@synthesize prevPageButton;
@synthesize selectButton;
@synthesize annotationToolbar;
@synthesize navigationToolbar;


-(void)updateButtonsAnnotating:(BOOL)annotating withType:(APAnnotationType)type
{
    noteButton.enabled = !annotating;
    highlightButton.enabled = !annotating;
    underlineButton.enabled = !annotating;
    photoButton.enabled = !annotating;
    bookmarkButton.enabled = !annotating;
    inkButton.enabled = !annotating;
    straightLineButton.enabled = !annotating;
    cancelButton.enabled = annotating;
    finishButton.enabled = annotating && (type != kAPAnnotationTypeNote) && (type != kAPAnnotationTypeBookmark) && (type != kAPAnnotationTypePhoto);
    selectButton.enabled = !annotating;
    processButton.enabled = !(pdfView.pdf.information.isProcessed);
    syncButton.enabled = pdfView.pdf.information.isModified;
    flattenButton.enabled = pdfView.pdf.information.hasUserAnnotations;
    bookmarksButton.enabled = [pdfView.pdf.information hasBookmarks];
    outlineButton.enabled = [pdfView.pdf.information hasPDFOutline];
    annotationsButton.enabled = [pdfView.pdf.information hasUserAnnotations];
    searchButton.enabled = pdfView.pdf.information.isProcessed && [pdfView.pdf.information hasText];
    nextPageButton.enabled = [pdfView hasNextPage];
    prevPageButton.enabled = [pdfView hasPreviousPage];
}

-(void)updateButtonsAnnotating:(BOOL)annotating
{
    [self updateButtonsAnnotating:annotating withType:kAPAnnotationTypeNone];
}

-(void)updateInterface
{
    [self updateButtonsAnnotating:NO];
}

-(void)adjustInterfaceForiPhone
{
    [navigationToolbar removeFromSuperview];
    [annotationToolbar removeFromSuperview];
    hostView.frame = [[hostView superview] bounds];
    spinnerView.center = CGPointMake(.5 * spinnerView.bounds.size.width, hostView.bounds.size.height - .5 * spinnerView.bounds.size.height);
    spinnerView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        /* on iphone, we have to use a stripped-down UI which only supports viewing of annotations */
        [self adjustInterfaceForiPhone];
    }

    /* for this sample, we store the PDF in the Documents area, and the information file in the Library area. */
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pdfPath = [[docPaths objectAtIndex:0] stringByAppendingPathComponent:@"test.pdf"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
        /* get the PDF from the application bundle */
        NSString *pdfBundlePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
        NSAssert(nil != pdfPath, @"missing pdf in bundle?");
        [[NSFileManager defaultManager] copyItemAtPath:pdfBundlePath toPath:pdfPath error:nil];
    }

    NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *infoPath = [[libPaths objectAtIndex:0] stringByAppendingPathComponent:@"test.pdf.info"];

    /* create the PDF information object; this will load the cached
     * file if it exists, or prepare it if it does not yet exist. */
    APPDFInformation *info = [[APPDFInformation alloc] initWithPath:infoPath];

    /* now the APPDFDocument object */
    APPDFDocument *pdfFile = [[APPDFDocument alloc] initWithPath:pdfPath information:info];
    NSAssert(nil != pdfFile, @"error creating APPDFDocument?");

    /* create the view controller -- interactive on the iPad, read-only on the iPhone/iPod Touch... */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        pdfView = [[APAnnotatingPDFViewController alloc] initWithPDF:pdfFile];
    else
        pdfView = (id)[[APPDFViewController alloc] initWithPDF:pdfFile];
    pdfView.delegate = self;

    /* ...and load it into the view heirarchy */
    pdfView.view.frame = hostView.bounds;
    pdfView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [hostView addSubview:pdfView.view];

    /* release resources */
    [pdfFile release];
    [info release];

    [pdfView fitToWidth];

    /* example of how to add custom gesture handling */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [[pdfView gestureView] addGestureRecognizer:tap];
    [tap release];

    /* update UI appropriately */
    [self updateInterface];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        /* auto-process on iphone since we have no button for it */
        if (!pdfView.pdf.information.isProcessed)
            [self process];
    }
}

- (void)viewDidUnload
{
    pdfView.delegate = nil;
    [pdfView release];
    pdfView = nil;

    self.hostView = nil;
    self.spinnerView = nil;
    self.processButton = nil;
    self.noteButton = nil;
    self.highlightButton = nil;
    self.underlineButton = nil;
    self.photoButton = nil;
    self.inkButton = nil;
    self.straightLineButton = nil;
    self.bookmarkButton = nil;
    self.cancelButton = nil;
    self.finishButton = nil;
    self.selectButton = nil;
    self.outlineButton = nil;
    self.goToPageButton = nil;
    self.annotationsButton = nil;
    self.bookmarksButton = nil;
    self.syncButton = nil;
    self.flattenButton = nil;
    self.searchButton = nil;
    self.nextPageButton = nil;
    self.prevPageButton = nil;
    self.annotationToolbar = nil;
    self.navigationToolbar = nil;
}

- (void)dealloc
{
    [self viewDidUnload];
    [super dealloc];
}


#pragma mark -
#pragma mark passing view notifications


-(void)viewWillAppear:(BOOL)animated
{
    [pdfView viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [pdfView viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [pdfView viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [pdfView viewWillDisappear:animated];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (nil == pdfView ? YES : [pdfView shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pdfView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [pdfView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [pdfView fitToWidth];
}


#pragma mark -
#pragma mark touch handling


-(void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if (UIGestureRecognizerStateRecognized != recognizer.state)
        return;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"User Tap"
                                           message:@"Tap detected"
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [av show];
    [av release];
}


#pragma mark -
#pragma mark action handling


-(void)notifyNoText
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Text"
                                           message:@"This PDF does not have any selectable text"
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [av show];
    [av release];
}

-(IBAction)note
{
    [pdfView addAnnotationOfType:kAPAnnotationTypeNote];
    [self updateButtonsAnnotating:YES withType:kAPAnnotationTypeNote];
}

-(IBAction)highlight
{
    if (![pdfView hasText]) {
        [self notifyNoText];
        return;
    }
    [pdfView addAnnotationOfType:kAPAnnotationTypeHighlight];
    [self updateButtonsAnnotating:YES withType:kAPAnnotationTypeHighlight];
}

-(IBAction)underline
{
    if (![pdfView hasText]) {
        [self notifyNoText];
        return;
    }
    [pdfView addAnnotationOfType:kAPAnnotationTypeUnderline];
    [self updateButtonsAnnotating:YES withType:kAPAnnotationTypeUnderline];
}

-(IBAction)photo
{
    [pdfView addAnnotationOfType:kAPAnnotationTypePhoto];
    [self updateButtonsAnnotating:YES withType:kAPAnnotationTypePhoto];
}

-(IBAction)ink
{
    [pdfView addAnnotationOfType:kAPAnnotationTypeInk];
    [self updateButtonsAnnotating:YES withType:kAPAnnotationTypeInk];
}

-(IBAction)straightLine
{
    [pdfView addAnnotationOfType:kAPAnnotationTypeStraightLine];
    [self updateButtonsAnnotating:YES withType:kAPAnnotationTypeStraightLine];
}

-(IBAction)bookmark
{
    [pdfView addAnnotationOfType:kAPAnnotationTypeBookmark];
    [self updateButtonsAnnotating:YES withType:kAPAnnotationTypeBookmark];
}

-(IBAction)finishCurrentAnnotation
{
    [pdfView finishCurrentAnnotation];
    [self updateButtonsAnnotating:NO];
}

-(IBAction)cancelCurrentAnnotation
{
    [pdfView cancelAddAnnotation];
    [self updateButtonsAnnotating:NO];
}

-(IBAction)toggleSelectMode
{
    if (![pdfView hasText]) {
        [self notifyNoText];
        return;
    }
    if ([pdfView isSelectionMode])
        [pdfView endSelectionMode];
    else
        [pdfView enterSelectionMode];
}

-(IBAction)outline
{
    [pdfView showPDFOutlineFromBarButtonItem:outlineButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(IBAction)goToPage
{
    [pdfView showGoToPageFromBarButtonItem:goToPageButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(IBAction)annotations
{
    [pdfView showAnnotationListFromBarButtonItem:annotationsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(IBAction)bookmarks
{
    [pdfView showBookmarksFromBarButtonItem:bookmarksButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(IBAction)nextPage
{
    [pdfView nextPageAnimated:YES];
}

-(IBAction)prevPage
{
    [pdfView previousPageAnimated:YES];
}

-(void)doProcessing
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    {
        APPDFProcessor *processor = [[APPDFProcessor alloc] init];
        processor.delegate = self;
        [processor processPDF:pdfView.pdf];
        [processor release];
    }
    [pool drain];
}

-(IBAction)process
{
    if (pdfView.pdf.information.isProcessed) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Already Processed"
                                               message:@"This document has already been processed."
                                               delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    [spinnerView startAnimating];
    [self performSelectorInBackground:@selector(doProcessing) withObject:nil];
}

-(void)doWriting
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    {
        APPDFProcessor *processor = [[APPDFProcessor alloc] init];
        processor.delegate = self;
        [processor syncAnnotationsToPDF:pdfView.pdf];
        [processor release];
    }
    [pool drain];
}

-(IBAction)syncAnnotations
{
    if (!pdfView.pdf.information.isModified) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"PDF Up-to-date"
                                               message:@"This document is up-to-date."
                                               delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    [spinnerView startAnimating];
    [self performSelectorInBackground:@selector(doWriting) withObject:nil];
}

-(void)doFlatten
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    {
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *flattenPath = [[docPaths objectAtIndex:0] stringByAppendingPathComponent:@"flattened.pdf"];
        [[NSFileManager defaultManager] removeItemAtPath:flattenPath error:nil];

        APPDFProcessor *processor = [[APPDFProcessor alloc] init];
        processor.delegate = self;
        [processor writePDFWithAnnotations:pdfView.pdf toPath:flattenPath options:[APPDFProcessorWriteOptions optionsWithFlags:kAPPDFWriteOptionsFlatten]];
        [processor release];
    }
    [pool drain];
}

-(IBAction)flatten
{
    [spinnerView startAnimating];
    [self performSelectorInBackground:@selector(doFlatten) withObject:nil];
}

-(IBAction)search
{
    if ([pdfView isSearchVisible])
        [pdfView hideSearchAnimated:YES];
    else
        [pdfView showSearchAnimated:YES];
}


#pragma mark -
#pragma mark PDF View Delegate implementations


-(void)pdfController:(APPDFViewController *)controller didTapOnLinkToExternalURL:(NSURL *)url
{
    NSLog(@"URL tapped: %@", url);
    if ([[UIApplication sharedApplication] canOpenURL:url])
        [[UIApplication sharedApplication] openURL:url];
}

-(void)pdfControllerDidChangePage:(APPDFViewController *)controller
{
    [self updateInterface];
}


#pragma mark -
#pragma mark Annotating PDF View Delegate implementations


-(UIColor *)pdfController:(APAnnotatingPDFViewController *)controller colorForNewAnnotationOfType:(APAnnotationType)annotType
{
    switch (annotType) {

    case kAPAnnotationTypeNote:
        return [UIColor yellowColor];

    case kAPAnnotationTypeHighlight:
        return [UIColor yellowColor];

    case kAPAnnotationTypeUnderline:
        return [UIColor blueColor];

    case kAPAnnotationTypeBookmark:
        return [UIColor orangeColor];

    case kAPAnnotationTypeInk:
        return [UIColor redColor];

    case kAPAnnotationTypeStraightLine:
        return [UIColor greenColor];

    case kAPAnnotationTypePhoto:
        return nil;

    default:
        NSAssert1(NO, @"Invalid annotation type: %d", annotType);
        return [UIColor redColor];
    }
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didEndAnnotationMode:(APAnnotationType)type
{
    [self updateButtonsAnnotating:NO];
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didCreateAnnotation:(APAnnotation *)annotation
{
    [self updateButtonsAnnotating:NO];
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didModifyAnnotation:(APAnnotation *)annotation
{
    [self updateButtonsAnnotating:NO];
}

-(BOOL)pdfController:(APAnnotatingPDFViewController *)controller shouldDisplayConfirmationBeforeDeletingAnnotation:(APAnnotation *)annotation
{
    return YES;
}


#pragma mark -
#pragma mark PDF Processor delegate


-(void)pdfProcessor:(APPDFProcessor *)processor didProcessPDF:(APPDFDocument *)pdf
{
    [spinnerView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(updateInterface) withObject:nil waitUntilDone:NO];
}

-(void)pdfProcessor:(APPDFProcessor *)processor failedToProcessPDF:(APPDFDocument *)pdf withError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Processing Error"
                                           message:[NSString stringWithFormat:@"Error: %@", error]
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [av release];

    [spinnerView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(updateInterface) withObject:nil waitUntilDone:NO];
}

-(void)pdfProcessor:(APPDFProcessor *)pdfProcessor encounteredNonFatalError:(NSError *)error whileProcessingPDF:(APPDFDocument *)pdf
{
    NSLog(@"Warning: %@", error);
}

-(void)pdfProcessor:(APPDFProcessor *)processor didSyncAnnotationsToPDF:(APPDFDocument *)pdf
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Annotations Updated"
                                           message:@"The annotations were successfully updated to the PDF file."
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [av release];
    [spinnerView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
    NSLog(@"Updated PDF is at: %@", pdf.path);
}

-(void)pdfProcessor:(APPDFProcessor *)processor failedToSyncAnnotationsToPDF:(APPDFDocument *)pdf withError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sync Annotations Error"
                                           message:[NSString stringWithFormat:@"Error: %@", error]
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [av release];

    [spinnerView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
}

-(void)pdfProcessor:(APPDFProcessor *)processor reportProcessingLog:(NSString *)processingLog forPDF:(APPDFDocument *)pdf
{
    NSLog(@"***Processing Report for %@:\n\n%@\n\n", [[pdf path] lastPathComponent], processingLog);
}

-(void)pdfProcessor:(APPDFProcessor *)processor didWritePDFWithAnnotations:(APPDFDocument *)pdf toPath:(NSString *)path
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Annotations Flattened"
                                           message:@"The annotations were successfully flattened (in documents folder)."
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [av release];
    [spinnerView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
    NSLog(@"Flattend PDF is at: %@", path);
}

-(void)pdfProcessor:(APPDFProcessor *)processor failedToWritePDFWithAnnotations:(APPDFDocument *)pdf toPath:(NSString *)path withError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Flatten PDF Error"
                                           message:[NSString stringWithFormat:@"Error: %@", error]
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [av release];

    [spinnerView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
}


@end
