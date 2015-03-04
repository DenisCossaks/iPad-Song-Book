//
//  HYImportedMusicViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 12/12/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYImportedMusicViewController : UITableViewController {
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic, strong) NSMutableArray *musicArray;

@end
