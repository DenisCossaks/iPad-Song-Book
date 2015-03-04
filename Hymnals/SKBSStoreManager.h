//
//  SKBSStoreObserver.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/27/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kSKBSStoreManagerTransactionFailed              @"SKBSStoreManagerTransactionFailedNotification"
#define kSKBSStoreManagerTransactionSucceeded           @"SKBSStoreManagerTransactionSucceededNotification"
#define kSKBSStoreManagerProductsDownloaded             @"SKBSStoreManagerProductsDownloadedNotification"

@interface SKBSStoreManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *productsArray;

@property (nonatomic, assign) BOOL productsLoaded;

+ (SKBSStoreManager *)sharedStoreManager;

- (void)loadStore;
- (void)restorePurchases;
- (void)requestProductsWithIds:(NSSet*)productIds;

- (BOOL)canMakePurchases;
- (BOOL)makePurchaseWithProductId:(NSString*)productId;

- (void)checkForMissingPurchases;
- (void)updateDatabaseForMissingPurchases;

@end
