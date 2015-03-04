//
//  HYPurchaseViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 5/10/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPurchaseCell.h"
#import "HYDownloadProgressViewController.h"
#import "HYHymnalInfoWebOperation.h"

@interface HYPurchaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SKBSWebOperationDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UITableView *contentTableView;

@property (nonatomic, weak) UIPopoverController *popoverController;

@property (nonatomic, strong) HYDownloadProgressViewController *progressController;

@property (nonatomic, strong) NSArray *collectionArray;

@property (nonatomic, strong) NSMutableArray *downloadArray;
@property (nonatomic, strong) NSMutableArray *productsArray;

@property (nonatomic, strong) NSString *previousCode;

@property (nonatomic, assign) NSInteger startCount;

@end
