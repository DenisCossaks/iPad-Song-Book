//
//  HYStoreViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 5/7/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBPopoverController.h"

@interface HYStoreViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *storeTableView;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) NBPopoverController *contentPopoverController;

@property (nonatomic, strong) NSMutableArray *collectionArray;

- (IBAction)LibraryButtonTouched;

@end
