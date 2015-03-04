//
//  HYIndividualPageViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYIndividualPageViewController.h"
#import "HYRootViewController.h"

@implementation HYIndividualPageViewController

@synthesize pageUpButton;
@synthesize pageDownButton;
@synthesize firstPageButton;
@synthesize backgroundImageView;
@synthesize largePageUpButton;
@synthesize largePageDownButton;
@synthesize annotationToolbar;
@synthesize rootViewController;

@synthesize pageInfoDict;
@synthesize pageIndex;
@synthesize currentPage;
@synthesize pageHeight;
@synthesize pageOffset;
@synthesize isPageTurn;
@synthesize isAnnotating;

#pragma mark - loading
- (id)initWithPageInfo:(NSDictionary*)info index:(NSInteger)index isPageTurn:(BOOL)pageTurn rootViewController:(HYRootViewController*)viewController {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *infoPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info", [info objectForKey:@"pdf_file"]]];
    NSString *pdfPath = nil;
    if ([[[NSBundle mainBundle] pathForResource:[[[info objectForKey:@"pdf_file"] componentsSeparatedByString:@"."] objectAtIndex:0] ofType:@"pdf"] length]) {
        pdfPath = [[NSBundle mainBundle] pathForResource:[[[info objectForKey:@"pdf_file"] componentsSeparatedByString:@"."] objectAtIndex:0] ofType:@"pdf"];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, [info objectForKey:@"pdf_file"]]])  {
        pdfPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [info objectForKey:@"pdf_file"]];
    }
    
    APPDFInformation *pdfInfo = [[APPDFInformation alloc] initWithPath:infoPath];
    APPDFDocument *pdfFile = [[APPDFDocument alloc] initWithPath:pdfPath information:pdfInfo];
    //NSAssert(nil != pdfFile, @"error creating APPDFDocument?");
    if (!pdfFile) {
        return nil;
    }
    if (self = [super initWithPDF:pdfFile]) {
        self.pageInfoDict = info;
        self.pageIndex = index;
        self.isPageTurn = pageTurn;
        self.rootViewController = viewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationModeChanged:) name:kAnnotationModeChanged object:nil];
    
    self.viewOptions.showPageLocator = NO;
    self.viewOptions.disableLongTapSelection = YES;    

    if (!self.pdf.information.isProcessed) {
        NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{
            APPDFProcessor *processor = [[APPDFProcessor alloc] init];
            processor.delegate = self;
            [processor syncAnnotationsToPDF:self.pdf];
        }];
        [blockop performSelectorInBackground:@selector(start) withObject:nil];
    }

    largePageUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    largePageUpButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 250);
    largePageUpButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    largePageUpButton.hidden = YES;
    [largePageUpButton addTarget:self action:@selector(pageUpButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:largePageUpButton];
    
    largePageDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    largePageDownButton.frame = CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200);
    largePageDownButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    largePageDownButton.hidden = YES;
    [largePageDownButton addTarget:self action:@selector(pageDownButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:largePageDownButton];
    
    firstPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstPageButton.frame = CGRectMake(self.view.frame.size.width - 92, self.view.frame.size.height - 183, 64, 39);
    firstPageButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    firstPageButton.hidden = YES;
    [firstPageButton setImage:[UIImage imageNamed:@"button-first"] forState:UIControlStateNormal];
    [firstPageButton addTarget:self action:@selector(firstPageButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstPageButton];
    
    pageUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pageUpButton.frame = CGRectMake(self.view.frame.size.width - 92, self.view.frame.size.height - 131, 64, 52);
    pageUpButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    pageUpButton.hidden = YES;
    [pageUpButton setImage:[UIImage imageNamed:@"button-up"] forState:UIControlStateNormal];
    [pageUpButton addTarget:self action:@selector(pageUpButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pageUpButton];
    
    pageDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pageDownButton.frame = CGRectMake(self.view.frame.size.width - 92, self.view.frame.size.height - 62, 64, 52);
    pageDownButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    pageDownButton.hidden = self.pdf.pageCount > 1 ? NO : YES;
    [pageDownButton setImage:[UIImage imageNamed:@"button-down"] forState:UIControlStateNormal];
    [pageDownButton addTarget:self action:@selector(pageDownButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pageDownButton];
    
    currentPage = 1;
    
    pageCountView = [[[self.view.subviews objectAtIndex:0] subviews] objectAtIndex:1];
    pageCountView.frame = CGRectMake(40, -20, pageCountView.frame.size.width, pageCountView.frame.size.height);
    pageCountView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    pageCountView.hidden = YES;
    
    annotationToolbar = [[HYAnnotationToolbarView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 48, 100, 48, 400)];
    annotationToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    annotationToolbar.hidden = YES;
    [annotationToolbar.highlightButton addTarget:self action:@selector(highlightButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [annotationToolbar.underlineButton addTarget:self action:@selector(underlineButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [annotationToolbar.strikeoutButton addTarget:self action:@selector(strikeoutButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [annotationToolbar.noteButton addTarget:self action:@selector(noteButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [annotationToolbar.freeformButton addTarget:self action:@selector(freeformButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [annotationToolbar.typeButton addTarget:self action:@selector(typeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:annotationToolbar];
    
    self.delegate = self;
    
//    pageHeight = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? kPDFLandscapePageHeight : kPDFPortraitPageHeight;
    pageOffset = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? kPDFLandscapePageOffset : kPDFPortraitPageOffset;
//    backgroundImageView.image = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? [UIImage imageNamed:@"placeholder-landscape"] : [UIImage imageNamed:@"placeholder-portrait"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewOptions.minZoomScale = .1;
    [self fitToWidth];
    self.viewOptions.minZoomScale = self.pageToViewScale;
    
    [self performSelector:@selector(unhidePageCounter) withObject:nil afterDelay:.5];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!isPageTurn) {
        self.viewOptions.minZoomScale = .1;
        [self fitToWidth];
        self.viewOptions.minZoomScale = self.pageToViewScale;
    }
}

- (void)unhidePageCounter {
    pageCountView.alpha = 0;
    pageCountView.hidden = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^ {
        pageCountView.alpha = 1;
    }];
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.viewOptions.minZoomScale = .1;
    [self fitToWidth];
    self.viewOptions.minZoomScale = self.pageToViewScale;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    pageHeight = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? kPDFLandscapePageHeight : kPDFPortraitPageHeight;
    pageOffset = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? kPDFLandscapePageOffset : kPDFPortraitPageOffset;
}

#pragma mark - notifications
- (void)annotationModeChanged:(NSNotification*)notification {
    if ([notification.object boolValue]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kAnnotationAlertNeverShowAgain]) {
            [[[UIAlertView alloc] initWithTitle:@"Annotation Mode" message:@"The navigation is disabled while annotation mode is enabled. Toggle the pencil icon to disable annotation mode." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Never Show Again", nil] show];
        }
        isAnnotating = YES;
        annotationToolbar.hidden = NO;
        largePageUpButton.hidden = YES;
        [UIView animateWithDuration:kAnimationDuration animations:^ {
            annotationToolbar.center = CGPointMake(self.view.frame.size.width - (annotationToolbar.frame.size.width / 2), annotationToolbar.center.y);
        }];
    }
    else {
        isAnnotating = NO;
        largePageUpButton.hidden = ![self hasPreviousPage];
        [self cancelAddAnnotation];
        [self hideRibbon];
        [UIView animateWithDuration:kAnimationDuration animations:^ {
            annotationToolbar.center = CGPointMake(self.view.frame.size.width + (annotationToolbar.frame.size.width / 2), annotationToolbar.center.y);
        } completion:^(BOOL finished) {
            annotationToolbar.hidden = YES;
        }];
    }
}

#pragma mark - actions 
- (IBAction)pageDownButtonTouched {
    [Flurry logEvent:@"Reader - Page Down Touched"];
    
    if ([self hasNextPage]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsFullscreen]) {
            [self setPage:currentPage contentOffsetInPageSpace:CGPointMake(0, .05) animated:YES];
        }
        else {
            [self nextPageAnimated:YES];
        }
    }
}

- (IBAction)pageUpButtonTouched {
    [Flurry logEvent:@"Reader - Page Up Touched"];
    
    if ([self hasPreviousPage]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsFullscreen]) {
            [self setPage:currentPage - 2 contentOffsetInPageSpace:CGPointMake(0, .05) animated:YES];
        }
        else {
            [self previousPageAnimated:YES];
        }
    }
}

- (IBAction)firstPageButtonTouched {
    [Flurry logEvent:@"Reader - 1st Page Touched"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsFullscreen]) {
        [self setPage:0 contentOffsetInPageSpace:CGPointMake(0, .05) animated:YES];
    }
    else {
        [self firstPageAnimated:YES];
    }
    currentPage = 1;
}

- (void)enterFullscreen:(NSNumber*)animated {
    //check if we are at the top of a page
    if ([self pageSpaceContentOffset].y > .95 || [self pageSpaceContentOffset].y < .1) {
        [self setPage:currentPage - 1 contentOffsetInPageSpace:CGPointMake(0, .05) animated:YES];
    }
}

- (void)highlightButtonTouched {
    if (![self.pdf.information hasText]) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"There is no text to select on this page!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    [self addAnnotationOfType:kAPAnnotationTypeHighlight];
}

- (void)underlineButtonTouched {
    if (![self.pdf.information hasText]) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"There is no text to select on this page!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    [self addAnnotationOfType:kAPAnnotationTypeUnderline];
}

- (void)strikeoutButtonTouched {
    if (![self.pdf.information hasText]) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"There is no text to select on this page!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    [self addAnnotationOfType:kAPAnnotationTypeStrikeout];
}

- (void)noteButtonTouched {
    [self addAnnotationOfType:kAPAnnotationTypeNote];
}

- (void)freeformButtonTouched {
    [self addAnnotationOfType:kAPAnnotationTypeInk];
}

- (void)typeButtonTouched {
    [self addAnnotationOfType:kAPAnnotationTypeFreeText];
}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAnnotationAlertNeverShowAgain];
    }
}

#pragma mark - pdf view
- (void)pdfControllerDidChangePage:(APPDFViewController *)controller {
    currentPage = [self pageIndexAtMidscreen] + 1;
    pageUpButton.hidden = ![self hasPreviousPage];
    pageDownButton.hidden = ![self hasNextPage];
    largePageDownButton.hidden = ![self hasNextPage];
    firstPageButton.hidden = self.pdf.pageCount > 2 && currentPage > 2 ? NO : YES;
    if (isAnnotating) {
        largePageUpButton.hidden = YES;
    }
    else {
        largePageUpButton.hidden = ![self hasPreviousPage];
    }
}

- (void)pdfController:(APPDFViewController *)controller didTapOnAnnotation:(APAnnotation *)annotation inRect:(CGRect)rect {
    if (!isAnnotating) {
        [rootViewController annotationButtonTouched];
    }
}

#pragma mark - pdf annotation
- (void)pdfController:(APAnnotatingPDFViewController *)controller didEnterAnnotationMode:(APAnnotationType)type {
}

- (void)pdfController:(APAnnotatingPDFViewController *)controller didEndAnnotationMode:(APAnnotationType)type {
}

#pragma mark - pdf processor
- (void)pdfProcessor:(APPDFProcessor *)processor didProcessPDF:(APPDFDocument *)pdf {
}

- (void)pdfProcessor:(APPDFProcessor *)processor failedToProcessPDF:(APPDFDocument *)pdf withError:(NSError *)error {
    NSLog(@"Processing Error: %@", error);
}

- (void)pdfProcessor:(APPDFProcessor *)pdfProcessor encounteredNonFatalError:(NSError *)error whileProcessingPDF:(APPDFDocument *)pdf {
    NSLog(@"Warning: %@", error);
}

- (void)pdfProcessor:(APPDFProcessor *)processor didSyncAnnotationsToPDF:(APPDFDocument *)pdf {
    NSLog(@"Updated PDF is at: %@", pdf.path);
}

- (void)pdfProcessor:(APPDFProcessor *)processor failedToSyncAnnotationsToPDF:(APPDFDocument *)pdf withError:(NSError *)error {
    NSLog(@"Sync Annotations Error: %@", error);
}

- (void)pdfProcessor:(APPDFProcessor *)processor reportProcessingLog:(NSString *)processingLog forPDF:(APPDFDocument *)pdf {
    NSLog(@"***Processing Report for %@:\n\n%@\n\n", [[pdf path] lastPathComponent], processingLog);
}

- (void)pdfProcessor:(APPDFProcessor *)processor didWritePDFWithAnnotations:(APPDFDocument *)pdf toPath:(NSString *)path {
    NSLog(@"Flattend PDF is at: %@", path);
}

- (void)pdfProcessor:(APPDFProcessor *)processor failedToWritePDFWithAnnotations:(APPDFDocument *)pdf toPath:(NSString *)path withError:(NSError *)error {
    NSLog(@"Flatten PDF Error: %@", error);
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.pageInfoDict = nil;
}

@end
