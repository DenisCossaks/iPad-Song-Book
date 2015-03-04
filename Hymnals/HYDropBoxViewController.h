//
//  HYDropBoxViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 8/14/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "HYDownloadProgressViewController.h"

@interface HYDropBoxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate, DBSessionDelegate>

@property (nonatomic, weak) IBOutlet UITableView *contentTableView;

@property (nonatomic, strong) HYDownloadProgressViewController *progressController;

@property (nonatomic, strong) DBRestClient *restClient;

@property (nonatomic, strong) DBMetadata *currentDirectoryMeta;

@property (nonatomic, strong) NSString *currentDropBoxPath;

- (void)logOutButtonTouched;

@end
