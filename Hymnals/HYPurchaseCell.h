//
//  HYPurchaseCell.h
//  Hymnals
//
//  Created by Stephen Bradley on 5/10/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class HYPurchaseCell;
@protocol HYPurchaseCellDelegate <NSObject>

- (void)purchaseCell:(HYPurchaseCell *)purchaseCell buyProductTouched:(SKProduct *)product;

@end

@interface HYPurchaseCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;

@property (nonatomic, strong) NSDictionary *hymnalDict;

@property (nonatomic, weak) id delegate;

- (IBAction)buyButtonTouched;

- (void)reloadCell;

@end
