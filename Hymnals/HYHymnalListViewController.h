//
//  HYHymnalListViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/19/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKBSWebOperationQueue.h"
#import "HYHymnalInfoWebOperation.h"
#import "HYDownloadProgressViewController.h"

@interface HYHymnalListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, SKBSWebOperationDelegate>

@property (nonatomic, strong) HYDownloadProgressViewController *progressController;

@property (nonatomic, strong) NSArray *ownedArray;
@property (nonatomic, strong) NSArray *availableArray;

@property (nonatomic, strong) NSMutableArray *downloadArray;

@property (nonatomic, strong) NSString *previousCode;

@property (nonatomic, assign) NSInteger startCount;
@property (nonatomic, assign) BOOL shouldRedownloadPurchasesOnLoad;
@property (nonatomic, assign) NSDictionary *hymnalToRedownload;

- (void)downloadHymnalWithInfo:(NSDictionary*)hymnalInfoDict includeAllMissingHymnals:(BOOL)includeAllMissingHymnals;
- (void)purchaseHymnalWithInfo:(NSDictionary*)hymnalInfoDict;

@end
