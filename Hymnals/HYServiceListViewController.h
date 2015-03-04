//
//  HYListDetailViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/19/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@class HYServiceList;

@interface HYServiceListViewController : UITableViewController <UITableViewDelegate, MFMailComposeViewControllerDelegate>

- (id)initWithServiceList:(HYServiceList *)serviceList;

@end
