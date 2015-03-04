
//
//  SKBSStoreObserver.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/27/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "SKBSStoreManager.h"
#import "HYHymn.h"
#import "HYHymnPDF.h"

@implementation SKBSStoreManager

@synthesize productsArray;

static SKBSStoreManager *sharedStoreManager;

#pragma mark - loading
+ (SKBSStoreManager *)sharedStoreManager {
	@synchronized(self) {
		if (!sharedStoreManager) {
			SKBSStoreManager *storeManager = [[SKBSStoreManager alloc] init];
            storeManager = nil;
        }
	}
	return sharedStoreManager;
}

+ (id)alloc {
	@synchronized(self) {
		NSAssert(sharedStoreManager == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedStoreManager = [super alloc];
	}
	return sharedStoreManager;
}

- (id)init {
	self = [super init];
	if (self != nil) {
        
    }
    return self;
}

- (void)loadStore {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)requestProductsWithIds:(NSSet*)productIds {
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers: productIds]; 
	request.delegate = self;
	[request start];
}

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

- (BOOL)makePurchaseWithProductId:(NSString*)productId {
    [Flurry logEvent:@"Store Manager - Purchased Item" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:productId, @"Product ID", nil]];
    for (SKProduct *product in productsArray) {
        if ([product.productIdentifier isEqualToString:productId]) {
            [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
            return YES;
        }
    }
    return NO;
}

#pragma mark - request methods
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {	
    self.productsArray = response.products;
    _productsLoaded = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSKBSStoreManagerProductsDownloaded object:self userInfo:[NSDictionary dictionaryWithObject:response.products forKey:@"Products"]];
}

- (void)requestDidFinish:(SKRequest *)request {
    if (request) {
        
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

#pragma mark - transaction & payment methods
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    if(queue) {
        
    }

}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if(queue) {
        
    }

}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if(queue) {
        
    }
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction:transaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction:transaction.originalTransaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSKBSStoreManagerTransactionFailed object:self userInfo:userInfo];
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSKBSStoreManagerTransactionSucceeded object:self userInfo:userInfo];
    }
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
//    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId]) {
//        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}
#pragma mark - Missing purchases
- (void)checkForMissingPurchases {

    NSArray *hymnPDFs = [HYHymn arrayOfHymnPDFsThatShouldBeDownloaded];
    //NSLog(@"%d\n%@\n\n", filenamesThatShouldBeDownloaded.count, filenamesThatShouldBeDownloaded);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL foundMissingPDF = NO;
    for (HYHymnPDF *hymnPDF in hymnPDFs) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, hymnPDF.filename];
        //NSLog2(filePath)
        if ([fileManager fileExistsAtPath:filePath]) {
            continue;
        }
        foundMissingPDF = YES;
        break;
    }
    
    if (!foundMissingPDF) {
        return;
    }
    ShowAlert(@"Restore Library", @"Please select 'Restore Purchases' from the hymnal list.")
}
- (void)updateDatabaseForMissingPurchases {
    @autoreleasepool {
        NSArray *hymnPDFs = [HYHymn arrayOfHymnPDFsThatShouldBeDownloaded];
        NSMutableArray *missingHymnPDFs = [NSMutableArray array];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (HYHymnPDF *hymnPDF in hymnPDFs) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, hymnPDF.filename];
            if ([fileManager fileExistsAtPath:filePath]) {
                continue;
            }
            [missingHymnPDFs addObject:hymnPDF];
        }
        
        if (!missingHymnPDFs.count) {
            return;
        }
        
        HYDatabase *database = [HYDatabase sharedDatabase];
//        for (HYHymnPDF *hymnPDF in missingHymnPDFs) {
//            [database executeSimpleQuery:@"UPDATE hymnals SET isDownloaded = 0 WHERE pdf_file = %@", hymnPDF.filename];
//        }
        
        NSMutableArray *missingValues = [NSMutableArray arrayWithCapacity:missingHymnPDFs.count];
        for (HYHymnPDF *hymnPDF in missingHymnPDFs) {
            [missingValues addObject:SQLEscapeAndQuote(hymnPDF.filename)];
        }
        NSString *valuesAsString = [missingValues componentsJoinedByString:@","];
        //NSLog2(valuesAsString)
        [database executeSimpleQuery:@"UPDATE hymnals SET isDownloaded = 0 WHERE pdf_file in (%@) and hymnal_code != 'SH' and hymnal_code != 'IM'", valuesAsString];
        
        NSArray *hymnalCodes = [hymnPDFs valueForKeyPath:@"@distinctUnionOfObjects.hymnalCode"];
        [missingValues removeAllObjects];
        for (NSString *hymnalCode in hymnalCodes) {
            [missingValues addObject:SQLEscapeAndQuote(hymnalCode)];
        }
        valuesAsString = [missingValues componentsJoinedByString:@","];
        //NSLog2(valuesAsString);
        [database executeSimpleQuery:@"UPDATE books SET isComplete = 0 WHERE hymnal_code in (%@)", valuesAsString];
        
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}
@end
