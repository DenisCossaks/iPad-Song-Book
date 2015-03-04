//
//  HYPurchaseViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 5/10/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYPurchaseViewController.h"
#import "SKBSStoreManager.h"
#import "SKBSWebOperationQueue.h"
#import "HYPDFDownloadWebOperation.h"
#import "UIImage+CachingExtensions.h"

@implementation HYPurchaseViewController

@synthesize coverImageView;
@synthesize descriptionLabel;
@synthesize contentTableView;

@synthesize popoverController;
@synthesize progressController;
@synthesize collectionArray;
@synthesize productsArray;
@synthesize downloadArray;
@synthesize previousCode;
@synthesize startCount;

#pragma mark - loading
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeManagerTransactionFailed:) name:kSKBSStoreManagerTransactionFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeManagerTransactionSucceeded:) name:kSKBSStoreManagerTransactionSucceeded object:nil];
    
    productsArray = [[NSMutableArray alloc] init];
    NSMutableArray *filteredCollectionArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *collection in collectionArray) {
        for (SKProduct *product in [[SKBSStoreManager sharedStoreManager] productsArray]) {
            if ([product.productIdentifier isEqualToString:[collection objectForKey:@"product_identifier"]]) {
                NSMutableDictionary *collectionDict = [collection mutableCopy];
                [collectionDict setObject:product forKey:@"product"];
                [filteredCollectionArray addObject:collectionDict];
                break;
            }
        }
    }
    
    descriptionLabel.text = [filteredCollectionArray.lastObject objectForKey:@"description"];
    [descriptionLabel sizeToFit];
    
    coverImageView.image = nil;
    if ([[filteredCollectionArray.lastObject objectForKey:@"cover_url"] isKindOfClass:[NSString class]]) {
        NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *image = [UIImage cachedImageNamed:[[filteredCollectionArray.lastObject objectForKey:@"cover_url"] lastPathComponent] atURL:[NSURL URLWithString:[filteredCollectionArray.lastObject objectForKey:@"cover_url"]]];
            [coverImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        }];
        [blockop performSelectorInBackground:@selector(start) withObject:nil];
    }

    
    collectionArray = filteredCollectionArray;
}

#pragma mark - notifications
- (void)storeManagerTransactionFailed:(NSNotification*)notification {
    [progressController hide];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[[[notification.userInfo objectForKey:@"transaction"] error] localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

- (void)storeManagerTransactionSucceeded:(NSNotification*)notification {
    NSString *productId = [[(SKPaymentTransaction*)[notification.userInfo objectForKey:@"transaction"] payment] productIdentifier];
    
    NSArray *bookArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE hymnal_code = %@ AND isOwned = 1", SQLEscapeAndQuote([[productId componentsSeparatedByString:@"."] lastObject])];
    if(!bookArray.count) {
        if (!progressController) {
            progressController = [[HYDownloadProgressViewController alloc] init];
        }
        if (!progressController.isVisible) {
            [progressController show];
        }
        if (!downloadArray) {
            downloadArray = [[NSMutableArray alloc] init];
        }
        
        HYHymnalInfoWebOperation *webop = [[HYHymnalInfoWebOperation alloc] initWithCode:[[productId componentsSeparatedByString:@"."] lastObject]];
        webop.delegate = self;
        [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
    }
}


#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return collectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYPurchaseCell"];
    cell.hymnalDict = [collectionArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell reloadCell];
    
    return cell;
}

- (void)purchaseCell:(HYPurchaseCell *)purchaseCell buyProductTouched:(SKProduct *)product {
    if ([[SKBSStoreManager sharedStoreManager] canMakePurchases]) {
        if (![[SKBSStoreManager sharedStoreManager] makePurchaseWithProductId:product.productIdentifier]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"This hymnal is not available for purchase at the moment." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        }
        else {
            progressController = [[HYDownloadProgressViewController alloc] init];
            [progressController show];
        }
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Purchasing is unavailable at this time. Check your network connection and try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    }
}

#pragma mark - webop
- (void)webOperationCompleted:(SKBSWebOperation*)webOp {
    if([webOp isKindOfClass:[HYHymnalInfoWebOperation class]]) {
        [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE books SET isOwned = 1 WHERE hymnal_code = %@", SQLEscapeAndQuote(((HYHymnalInfoWebOperation*)webOp).codeString)];
        
        for(NSDictionary *dict in ((HYHymnalInfoWebOperation*)webOp).resultArray) {
            NSString *modified = @"0000-00-00 00:00:00";
            if([dict objectForKey:@"modified"]) {
                modified = [dict objectForKey:@"modified"];
            }

            // by Woo
            [[HYDatabase sharedDatabase] executeNonQuery:@"INSERT OR IGNORE INTO hymnals (hymnal_number, hymnal_name, hymnal_shortname, hymnal_code, title, pdf_file, audio_file, itunes, version, sort, modified, file_version) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)",  SQLEscapeAndQuote([dict objectForKey:@"hymnal_number"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_name"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_shortname"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_code"]), SQLEscapeAndQuote([dict objectForKey:@"title"]), SQLEscapeAndQuote([dict objectForKey:@"pdf_file"]), SQLEscapeAndQuote([dict objectForKey:@"audio_file"]), SQLEscapeAndQuote([dict objectForKey:@"itunes"]), SQLEscapeAndQuote([dict objectForKey:@"version"]), SQLEscapeAndQuote([dict objectForKey:@"sort"]), SQLEscapeAndQuote(modified), SQLEscapeAndQuote([dict objectForKey:@"file_version"])];
        }
        
        [downloadArray addObjectsFromArray:((HYHymnalInfoWebOperation*)webOp).resultArray];
        startCount = downloadArray.count;
        
        HYPDFDownloadWebOperation *webop = [[HYPDFDownloadWebOperation alloc] initWithHymnInfo:[downloadArray objectAtIndex:0]];
        webop.delegate = self;
        [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
        
    }
    else {
        NSLog(@"Downloaded: %@", [((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"pdf_file"]);
        
        [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE hymnals SET isDownloaded = 1 WHERE pdf_file = %@", SQLEscapeAndQuote([((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"pdf_file"])];
        [downloadArray removeObject:((HYPDFDownloadWebOperation*)webOp).infoDict];
        [progressController updateProgress:1 - ((CGFloat)downloadArray.count / startCount)];
        
        if(downloadArray.count) {
            HYPDFDownloadWebOperation *webop = [[HYPDFDownloadWebOperation alloc] initWithHymnInfo:[downloadArray objectAtIndex:0]];
            webop.delegate = self;
            [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
            
            if(previousCode) {
                if(![[((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"hymnal_code"] isEqualToString:previousCode]) {
                    [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE books SET isComplete = 1 WHERE hymnal_code = %@", SQLEscapeAndQuote(previousCode)];
                }
            }
            previousCode = [((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"hymnal_code"];
        }
        else {
            previousCode = nil;
            [progressController hide];
            
            if (popoverController) {
                [popoverController dismissPopoverAnimated:YES];
            }
            
            [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE books SET isComplete = 1 WHERE hymnal_code = %@", SQLEscapeAndQuote([((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"hymnal_code"])];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kHymnAdded object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kHymnalSelected object:[NSDictionary dictionaryWithObjectsAndKeys:[((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"hymnal_code"] , @"hymnal_code", nil]];
            });
        }
    }
}

- (void)webOperationFailed:(SKBSWebOperation*)webOp withError:(NSError *)error {
    [progressController hide];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error downloading your purchase. Please check your network connection and try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHymnAdded object:nil];
}


@end
