//
//  HYPurchaseCell.m
//  Hymnals
//
//  Created by Stephen Bradley on 5/10/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYPurchaseCell.h"

@implementation HYPurchaseCell

@synthesize nameLabel;
@synthesize priceLabel;

@synthesize hymnalDict;
@synthesize delegate;

#pragma mark - loading
- (void)reloadCell {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[[hymnalDict objectForKey:@"product"] priceLocale]];

    priceLabel.text = [formatter stringFromNumber:[[hymnalDict objectForKey:@"product"] price]];
    nameLabel.text = [hymnalDict objectForKey:@"hymnal_name"];
}

#pragma mark - actions
- (IBAction)buyButtonTouched {
    if ([delegate respondsToSelector:@selector(purchaseCell:buyProductTouched:)]) {
        [delegate purchaseCell:self buyProductTouched:[hymnalDict objectForKey:@"product"]];
    }
}

@end
