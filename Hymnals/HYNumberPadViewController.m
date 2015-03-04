//
//  HYNumberPadViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/18/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYNumberPadViewController.h"

@implementation HYNumberPadViewController

@synthesize titleLabel;

@synthesize codeString;
@synthesize resultsArray;

#pragma mark - loading
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.contentSizeForViewInPopover = self.view.frame.size;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Dialer - Viewed"];
    
    codeString = [[NSMutableString alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    titleLabel.backgroundColor = UIColor.clearColor;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = IsIOS7OrNewer ? [UIColor blackColor] : [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor darkGrayColor];
    titleLabel.shadowOffset = CGSizeMake(0, -1);
    titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.navigationController.navigationBar.topItem setTitleView:titleLabel];
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - actions
- (IBAction)dialButtonTouched:(UIButton*)sender {
    [codeString appendFormat:@"%i", sender.tag];
    titleLabel.text = codeString;
}

- (IBAction)backspaceButtonTouched {
    if(codeString.length) {
        codeString = [[codeString substringToIndex:codeString.length - 1] mutableCopy];
        titleLabel.text = codeString;
    }
}

- (IBAction)goButtonTouched {
    resultsArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_number = %@", codeString];
    
    if(resultsArray.count == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHymnSelected object:[resultsArray objectAtIndex:0]];
    }
    else if(resultsArray.count > 1) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You have multiple hymns with that number, which one would you like?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        for (NSDictionary *dict in resultsArray) {
            if([[dict objectForKey:@"version"] isKindOfClass:[NSNull class]]) {
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ - %@", [dict objectForKey:@"hymnal_code"], [dict objectForKey:@"title"]]];
            }
            else {
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ %@ - %@", [dict objectForKey:@"hymnal_code"], [dict objectForKey:@"version"], [dict objectForKey:@"title"]]];
            }
        }
        [actionSheet showInView:self.view];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Hymn #%@ can not be found.", codeString] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    }
}

#pragma mark - actionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        [Flurry logEvent:@"Dialer - Selected" withParameters:[resultsArray objectAtIndex:buttonIndex - 1]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHymnSelected object:[resultsArray objectAtIndex:buttonIndex - 1]];
    }
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.codeString = nil;
    self.resultsArray = nil;
}

@end
