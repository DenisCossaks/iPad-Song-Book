//
//  HYServiceListViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/19/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYServiceListsViewController.h"
#import "HYServiceListViewController.h"
#import "SqliteWrapper.h"

#import "Models.h"

@implementation HYServiceListsViewController {
    NSIndexPath *selectedIndexPath;
    NSMutableArray *serviceLists; // array of ServiceList
}

#pragma mark - loading
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            self.contentSizeForViewInPopover = CGSizeMake(768, 500);
        }
        else {
            self.contentSizeForViewInPopover = CGSizeMake(576, 500);
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Service Lists - Viewed"];
    
    self.navigationItem.title = @"Service Lists";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouched:)];
    
    serviceLists = [[HYServiceList arrayOfServiceLists2] mutableCopy];
    if(!serviceLists.count) {
        [self insertEmptyLabel:NO];
    }
    
    self.tableView.allowsSelectionDuringEditing = YES;
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        self.contentSizeForViewInPopover = CGSizeMake(768, 500);
    }
    else {
        self.contentSizeForViewInPopover = CGSizeMake(576, 500);
    }
}

#pragma mark - actions
- (void)addButtonTouched:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Name Service List" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

#pragma mark - tableview
- (void)insertEmptyLabel:(BOOL)animated {
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.frame];
    emptyLabel.numberOfLines = 10;
    emptyLabel.textAlignment = UITextAlignmentCenter;
    emptyLabel.text = @"Click the '+' button above to add a service list. The 'edit' button enables you delete and/or rearrange service lists.";
    emptyLabel.textColor = UIColor.darkGrayColor;
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if(animated) {
        emptyLabel.alpha = 0;
        [UIView animateWithDuration:kAnimationDuration animations:^ {
            emptyLabel.alpha = 1;
        }];
    }
    
    self.tableView.backgroundView = emptyLabel;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return serviceLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYServiceListsViewController"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HYServiceListsViewController"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.showsReorderControl = YES;
    }
    
    HYServiceList *serviceList = serviceLists[indexPath.row];
    cell.textLabel.text = [serviceList name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.editing) {
        HYServiceList *serviceList = serviceLists[indexPath.row];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename Service List" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = serviceList.idAsNumber.integerValue;
        [[alertView textFieldAtIndex:0] setText:serviceList.name];
        [alertView show];
        selectedIndexPath = indexPath;
    }
    else {
        [Flurry logEvent:@"Service Lists - List Selected"];
        HYServiceList *serviceList = serviceLists[indexPath.row];
        [self.navigationController pushViewController:[[HYServiceListViewController alloc] initWithServiceList:serviceList] animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    [Flurry logEvent:@"Service Lists - List Deleted"];
    
    HYServiceList *serviceList = serviceLists[indexPath.row];
    [[HYDatabase sharedDatabase] executeNonQuery:@"DELETE FROM servicelists WHERE id = %@", serviceList.idAsNumber];
    [[HYDatabase sharedDatabase] executeNonQuery:@"DELETE FROM servicelist_hymnals WHERE servicelist_id = %@", serviceList.idAsNumber];
    [serviceLists removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if(!serviceLists.count) {
        [self insertEmptyLabel:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableview moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [Flurry logEvent:@"Service Lists - List Moved"];
    NSDictionary *row = [serviceLists objectAtIndex:fromIndexPath.row];
    [serviceLists removeObjectAtIndex:fromIndexPath.row];
    [serviceLists insertObject:row atIndex:toIndexPath.row];
    
    NSInteger lcv = 0;
    for(HYServiceList *serviceList in serviceLists) {
        [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE servicelists SET display_order = %i WHERE id = %@", lcv, [serviceList idAsNumber]];
        lcv++;
    }
}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex) {
        if([alertView.title isEqualToString:@"Name Service List"]) {
            [Flurry logEvent:@"Service Lists - New List Added"];
            
            HYServiceList *newServiceList = [HYServiceList serviceListWithName:[[alertView textFieldAtIndex:0] text] andDisplayOrder:serviceLists.count];
            [serviceLists addObject:newServiceList];
                    
            [UIView animateWithDuration:kAnimationDuration animations:^ {
                self.tableView.backgroundView.alpha = 0;
            } completion:^(BOOL finished) {
                self.tableView.backgroundView = nil;
            }];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            if([[[alertView textFieldAtIndex:0] text] length]) {
                [Flurry logEvent:@"Service Lists - List Renamed"];
                [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE servicelists SET name = %@ WHERE id = %i", SQLEscapeAndQuote([[alertView textFieldAtIndex:0] text]), alertView.tag];
                NSDictionary *serviceListAsDictionary = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM servicelists WHERE id = %i", alertView.tag][0];
                [serviceLists replaceObjectAtIndex:selectedIndexPath.row withObject:[[HYServiceList alloc] initWithDictionary:serviceListAsDictionary]];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    serviceLists = nil;
}

@end
