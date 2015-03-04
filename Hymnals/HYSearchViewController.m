//
//  HYSearchViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYSearchViewController.h"
#import "SqliteWrapper.h"
#import <AirTurnInterface/AirTurnInterface.h>

@implementation HYSearchViewController

@synthesize hymnSearchBar;

@synthesize resultsArray;

#pragma mark - loading
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.contentSizeForViewInPopover = CGSizeMake(500, 600);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Search - Viewed"];
    
    // Fix for this being nil on iPad 1
    if (!hymnSearchBar) {
        hymnSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        hymnSearchBar.barStyle = UIBarStyleBlackOpaque;
        hymnSearchBar.delegate = self;
        self.tableView.tableHeaderView = hymnSearchBar;
    }
    
    for (UIView *subview in hymnSearchBar.subviews) {
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subview setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    
    self.navigationItem.title = @"Search";
    self.resultsArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [hymnSearchBar becomeFirstResponder];
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYSearchViewController"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HYSearchViewController"];
    }
    
    NSDictionary *hymnDict = [resultsArray objectAtIndex:indexPath.row];
    
    if([[hymnDict objectForKey:@"version"] isKindOfClass:[NSNull class]]) { 
        cell.textLabel.text = [NSString stringWithFormat:@"%@ #%@ - %@", [hymnDict objectForKey:@"hymnal_code"], [hymnDict objectForKey:@"hymnal_number"], [hymnDict objectForKey:@"title"]];
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ #%@ %@ - %@", [hymnDict objectForKey:@"hymnal_code"], [hymnDict objectForKey:@"hymnal_number"], [hymnDict objectForKey:@"version"], [hymnDict objectForKey:@"title"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [Flurry logEvent:@"Search - Selected" withParameters:[resultsArray objectAtIndex:indexPath.row]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHymnSelected object:[resultsArray objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - searchbar
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [[AirTurnInterface sharedInterface] setKeyboardVisible:YES animate:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultsArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE title LIKE '%%%@%%'", searchText];
    [self.tableView reloadData];
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.resultsArray = nil;
}

@end
