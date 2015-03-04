//
//  HYSearchViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYSearchViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *hymnSearchBar;

@property (nonatomic, strong) NSArray *resultsArray;

@end
