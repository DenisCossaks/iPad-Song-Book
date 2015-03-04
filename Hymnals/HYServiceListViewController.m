	//
//  HYListDetailViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/19/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYServiceListViewController.h"

#import "Models.h"
#import "UIApplication+Things.h"

@interface HYServiceListViewController ()

@property (nonatomic, strong) HYServiceList *serviceList;

@end

@implementation HYServiceListViewController {
    NSIndexPath *selectedIndexPath;
}

#pragma mark - loading
- (id)initWithServiceList:(HYServiceList *)serviceList  {
    if (self = [super initWithNibName:nil bundle:nil]) {
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            self.contentSizeForViewInPopover = CGSizeMake(768, 500);
        }
        else {
            self.contentSizeForViewInPopover = CGSizeMake(576, 500);
        }
        self.serviceList = serviceList;
        
        if (!serviceList) {
            ShowFixMeAlert(@"got nil service list")
        }

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"List Detail - Viewed"];
    
    self.navigationItem.title = self.serviceList.name;
    
    if(self.serviceList.hymns.count) {
        UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonTouched:)];
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, shareBarButtonItem];
    }
    else {
        [self insertEmptyLabel:NO];
    }
    self.tableView.allowsSelectionDuringEditing = YES;
}
#pragma mark - UI Events
- (void)shareButtonTouched:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        ShowAlert(@"Cannot Share", @"Please setup an email account.")
        return;
    }
    
    NSString *serviceListAsString = [self.serviceList toJSONString];

    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setMailComposeDelegate:self];
    [mailComposeViewController setSubject:@"Sharing hymnal service list"];
    [mailComposeViewController setMessageBody:self.serviceList.name isHTML:NO];
    [mailComposeViewController addAttachmentData:[serviceListAsString dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"application/hymnals" fileName:[NSString stringWithFormat:@"ServiceList.%@", [HYServiceList fileExtension]]];
    
    [self presentViewController:mailComposeViewController animated:YES completion:NULL];
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

#pragma mark - tableview
- (void)insertEmptyLabel:(BOOL)animated {
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.frame];
    emptyLabel.numberOfLines = 10;
    emptyLabel.textAlignment = UITextAlignmentCenter;
    emptyLabel.text = @"This service list is empty. To add a hymn to the service list, navigate to a hymn and select the '+' icon in the navigation next to the left of the search field.";
    emptyLabel.textColor = UIColor.darkGrayColor;
    
    if(animated) {
        emptyLabel.alpha = 0;
        [UIView animateWithDuration:kAnimationDuration animations:^ {
            emptyLabel.alpha = 1;
        }];
    }
    
    self.tableView.backgroundView = emptyLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.serviceList.hymns.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYServiceListsViewController"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HYServiceListsViewController"];
        cell.showsReorderControl = YES;
    }
    HYHymn *hymnal = self.serviceList.hymns[indexPath.row];
    cell.textLabel.text = [hymnal displayText];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.editing) {
        
        HYHymn *hymnal = self.serviceList.hymns[indexPath.row];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename Service List Item" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = hymnal.idAsNumber.integerValue;
        [[alertView textFieldAtIndex:0] setText:[hymnal displayText]];
        [alertView show];
        selectedIndexPath = indexPath;
    }
    else {
        [Flurry logEvent:@"List Detail - Item Selected"];
        NSDictionary *dict = @{ @"servicelistId" : self.serviceList.idAsNumber,
                                @"currentPage" : [NSNumber numberWithInt:indexPath.row],
                                @"listName" : self.serviceList.name};
        [[NSNotificationCenter defaultCenter] postNotificationName:kServiceListSelected object:dict];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    [Flurry logEvent:@"List Detail - Item Deleted"];
    
    [self.serviceList deleteHymnalAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    if(!self.serviceList.hymns.count) {
        [self insertEmptyLabel:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableview moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

    [Flurry logEvent:@"List Detail - Item Moved"];
    
    [[self serviceList] moveHymnalFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex) {
        if([[[alertView textFieldAtIndex:0] text] length]) {

            [Flurry logEvent:@"List Detail - Item Renamed"];
            
            [self.serviceList renameHymnalAtIndex:selectedIndexPath.row withName:[[alertView textFieldAtIndex:0] text]];

            [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error) {
        NSLog2(error)
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
}

@end