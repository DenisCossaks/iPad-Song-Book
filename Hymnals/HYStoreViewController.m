//
//  HYStoreViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 5/7/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYStoreViewController.h"
#import "HYHymnalCollectionCell.h"
#import "HYPurchaseViewController.h"
#import "Models.h"

@implementation HYStoreViewController

@synthesize storeTableView;
@synthesize backgroundImageView;
@synthesize contentPopoverController;

@synthesize collectionArray;

#pragma mark - loading
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    collectionArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *collectionHash = [[NSMutableDictionary alloc] init];
    
    NSArray *availableArray = [HYHymnal arrayOfUnownedHymnalsAsDictionaries];
    for (NSDictionary *hymnalDict in availableArray) {
        if ([collectionHash objectForKey:[hymnalDict objectForKey:@"hymnal_group"]]) {
            [[collectionHash objectForKey:[hymnalDict objectForKey:@"hymnal_group"]] addObject:hymnalDict];
        }
        else {
            [collectionHash setObject:[[NSMutableArray alloc] initWithObjects:hymnalDict, nil] forKey:[hymnalDict objectForKey:@"hymnal_group"]];
        }
    }
    
    for (NSString *key in collectionHash.allKeys) {
        [collectionArray addObject:[collectionHash objectForKey:key]];
    }
    
    [storeTableView reloadData];
}

#pragma mark - status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        backgroundImageView.image = [UIImage imageNamed:@"background-landscape"];
    }
    else {
        backgroundImageView.image = [UIImage imageNamed:@"background-portrait"];
    }
    
    [contentPopoverController.contentViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  ceilf(collectionArray.count / 4.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYHymnalCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYHymnalCollectionCell"];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.collectionArray = collectionArray;
    [cell reloadCell];
    return cell;
}

#pragma mark - hymnalcollectioncell
- (void)hymnalCollectionCell:(HYHymnalCollectionCell *)hymnalCollectionCell selectedCollection:(NSArray *)collection {
    HYPurchaseViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HYPurchaseViewController"];
    viewController.collectionArray = collection;
    
    contentPopoverController = [[NBPopoverController alloc] initWithContentViewController:viewController];
    viewController.popoverController = contentPopoverController;
    [contentPopoverController presentPopoverFromRect:CGRectMake(self.view.center.x, self.view.center.y, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
}


#pragma mark - actions
- (IBAction)LibraryButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
