//
//  HYAddToListViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/19/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYAddHymnToServiceListViewController.h"

#import "Models.h"

@implementation HYAddHymnToServiceListViewController {
    UIAlertView *alertView;
    
    NSArray *servicelists; // array of HYServiceList
    NSNumber *hymnalId;
}
#pragma mark - loading
- (id)initWithHymnalId:(NSNumber*)hId {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.contentSizeForViewInPopover = CGSizeMake(300, 300);
        hymnalId = hId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Add To List - Viewed"];
    
    self.navigationItem.title = @"Add To Service List";
    
    servicelists = [HYServiceList arrayOfServiceLists2];
    
    if(!servicelists.count) {
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.frame];
        emptyLabel.numberOfLines = 10;
        emptyLabel.textAlignment = UITextAlignmentCenter;
        emptyLabel.text = @"Create a service list in which to add hymns by clicking the service list icon to the left.";
        emptyLabel.textColor = UIColor.darkGrayColor;
        
        self.tableView.backgroundView = emptyLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;        
    }

    alertView = [[UIAlertView alloc] initWithTitle:@"Hymn Added to Service List" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-check"]];
    imageView.frame = CGRectMake(125, 50, 40, 37);
    [alertView addSubview:imageView];
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return servicelists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYAddHymnToServiceListViewController"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HYAddHymnToServiceListViewController"];
    }
    
    HYServiceList *serviceList = servicelists[indexPath.row];
    cell.textLabel.text = serviceList.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [Flurry logEvent:@"Add To List - Added"];
    
    HYServiceList *serviceList = servicelists[indexPath.row];
    [serviceList addHymnWithID:hymnalId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHymnAdded object:nil];
    [alertView show];
    [self performSelector:@selector(dismissAlert) withObject:nil afterDelay:1.5];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - misc
- (void)dismissAlert {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    servicelists = nil;
}

@end
