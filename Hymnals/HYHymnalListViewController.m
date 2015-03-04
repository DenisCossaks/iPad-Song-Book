//
//  HYHymnalListViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/19/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYHymnalListViewController.h"
#import "HYPDFDownloadWebOperation.h"
#import "SKBSStoreManager.h"
#import "HYRootViewController.h"
#import "HYIndividualPageViewController.h"
#import "HYDropBoxViewController.h"
#import "HYImportedMusicViewController.h"

@implementation HYHymnalListViewController

@synthesize progressController;

@synthesize ownedArray;
@synthesize availableArray;
@synthesize downloadArray;
@synthesize previousCode;
@synthesize startCount;

#pragma mark - loading
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.contentSizeForViewInPopover = CGSizeMake(400, 462);
    }
    return self;
}

- (void)viewDidLoad {
    [Flurry logEvent:@"Hymnals List - Viewed"];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Hymnals";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeManagerTransactionFailed:) name:kSKBSStoreManagerTransactionFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeManagerTransactionSucceeded:) name:kSKBSStoreManagerTransactionSucceeded object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    previousCode = nil;
    
    NSMutableArray *allOwnedArray = [[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE isOwned = 1"] mutableCopy];
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    for(NSDictionary *ownedDict in allOwnedArray) {
        if(![[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_code = '%@'", [ownedDict objectForKey:@"hymnal_code"]] count]) {
            [removeArray addObject:ownedDict];
        }
    }
    [allOwnedArray removeObjectsInArray:removeArray];
    
    self.ownedArray = allOwnedArray;
    self.availableArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE isOwned = 0"];
    
    [self.tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldRedownloadPurchasesOnLoad) {
        [[SKBSStoreManager sharedStoreManager] updateDatabaseForMissingPurchases];
        if (self.hymnalToRedownload) {
            [self downloadHymnalWithInfo:self.hymnalToRedownload includeAllMissingHymnals:YES];
        }
    }
}
#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - notifications
- (void)storeManagerTransactionFailed:(NSNotification*)notification {
    [progressController hide];
    //TODO: error message;
}

- (void)storeManagerTransactionSucceeded:(NSNotification*)notification {
    NSString *productId = [[(SKPaymentTransaction*)[notification.userInfo objectForKey:@"transaction"] payment] productIdentifier];
    NSLog(@"%@",productId);
    NSArray *bookArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE hymnal_code = %@ AND isOwned = 1", SQLEscapeAndQuote([[productId componentsSeparatedByString:@"."] lastObject])];
    if(!bookArray.count) {
        if(!progressController) {
            progressController = [[HYDownloadProgressViewController alloc] init];
        }
        if(!progressController.isVisible) {
            [progressController show];
        }
        if(!downloadArray) {
            downloadArray = [[NSMutableArray alloc] init];
        }
        
        HYHymnalInfoWebOperation *webop = [[HYHymnalInfoWebOperation alloc] initWithCode:[[productId componentsSeparatedByString:@"."] lastObject]];
        webop.delegate = self;
        [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
    }
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return ownedArray.count;
            break;
        case 1:
            return availableArray.count;
            break;
        default:
            return 2;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Your Hymnals";
            break;
        case 1:
            return @"Buy Additional Hymnals";
            break;
        default:
            return @"Misc";
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYHymnalListViewController"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HYHymnalListViewController"];
    }
    
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buyButton.userInteractionEnabled = NO;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [[ownedArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_name"];
        cell.detailTextLabel.text = nil;
        
        if ([[[ownedArray objectAtIndex:indexPath.row] objectForKey:@"isComplete"] boolValue]) {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSArray *viewControllers = [[(HYRootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] contentPageViewController] viewControllers];
            if (viewControllers.count) {
                NSString *currentCode = [[(HYIndividualPageViewController*)[viewControllers lastObject] pageInfoDict] objectForKey:@"hymnal_code"];
                if ([currentCode isEqualToString:[[ownedArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_code"]]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
        }
        else {
            [buyButton setTitle:@"Download" forState:UIControlStateNormal];
            buyButton.frame = CGRectMake(0, 0, 90, 26);
            cell.accessoryView = buyButton;
        }
        
        if ([[[ownedArray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue] == 100) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        else if ([[[(HYRootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] contentPageViewController] viewControllers] count] && ownedArray.count) {
            if ([[[(HYIndividualPageViewController*)[[[(HYRootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] contentPageViewController] viewControllers] objectAtIndex:0] pageInfoDict] objectForKey:@"hymnal_code"] isEqual:[[ownedArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_code"]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    else if(indexPath.section == 1) {
        cell.textLabel.text = [[availableArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_name"];
        for (SKProduct *product in [[SKBSStoreManager sharedStoreManager] productsArray]) {
            if ([product.productIdentifier isEqualToString:[NSString stringWithFormat:@"com.gia.%@", [[availableArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_code"]]]) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [formatter setLocale:product.priceLocale];
                
                cell.detailTextLabel.text = [formatter stringFromNumber:product.price];
                break;
            }
        }
        
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.frame = CGRectMake(0, 0, 50, 26);
        cell.accessoryView = buyButton;

    }
    else if (indexPath.section == 2) {
        cell.accessoryView = nil;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Restore Purchases";
            cell.detailTextLabel.text = @"Hymals previously bought on your iTunes account";
        }
        else {
            cell.textLabel.text = @"Import From Dropbox";
            cell.detailTextLabel.text = @"Import PDFs to your user created Hymnal";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [Flurry logEvent:@"Hymnals List - Owned Selected" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[ownedArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_name"], @"Name", nil]];
        if ([[[ownedArray objectAtIndex:indexPath.row] objectForKey:@"isComplete"] boolValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHymnalSelected object:[NSDictionary dictionaryWithObjectsAndKeys:[[ownedArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_code"] , @"hymnal_code", nil]];
        }
        else {
            NSDictionary *hymnal = ownedArray[indexPath.row];
            [self downloadHymnalWithInfo:hymnal includeAllMissingHymnals:NO];
        }
    }
    else if (indexPath.section == 1) {
        [Flurry logEvent:@"Hymnals List - Buy Selected" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[availableArray objectAtIndex:indexPath.row] objectForKey:@"hymnal_name"], @"Name", nil]];
        [self purchaseHymnalWithInfo:[availableArray objectAtIndex:indexPath.row]];
    }
    else {
        if (indexPath.row == 0) {
            [[SKBSStoreManager sharedStoreManager] restorePurchases];
        }
        else {
            [self.navigationController pushViewController:[[HYDropBoxViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[HYImportedMusicViewController alloc] initWithStyle:UITableViewStylePlain] animated:YES];
}

#pragma mark - download/purchase
- (void)downloadHymnalWithInfo:(NSDictionary*)hymnalInfoDict includeAllMissingHymnals:(BOOL)includeAllMissingHymnals {
    progressController = [[HYDownloadProgressViewController alloc] init];
    [progressController show];
    
    HYDatabase *database = [HYDatabase sharedDatabase];
    NSString *hymnalCode = SQLEscapeAndQuote([hymnalInfoDict objectForKey:@"hymnal_code"]);
    NSMutableArray *hymnsToDownload = [[database executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_code = %@ AND isDownloaded = 0", hymnalCode]  mutableCopy];
    if (includeAllMissingHymnals) { // may take a long time
        // need to put the included hymnal at the end so when d/l is done, the selected hymnal is shown
        NSMutableArray *otherHymnsToDownload = [[database executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_code != %@ AND isDownloaded = 0", hymnalCode] mutableCopy];
        [otherHymnsToDownload addObjectsFromArray:hymnsToDownload];
        downloadArray = otherHymnsToDownload;
    }
    else {
         downloadArray = hymnsToDownload;
    }
    startCount = downloadArray.count;
    
    HYPDFDownloadWebOperation *webop = [[HYPDFDownloadWebOperation alloc] initWithHymnInfo:downloadArray[0]];
    webop.delegate = self;
    [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
}

- (void)purchaseHymnalWithInfo:(NSDictionary*)hymnalInfoDict {
    if ([[SKBSStoreManager sharedStoreManager] canMakePurchases]) {
        if(![[SKBSStoreManager sharedStoreManager] makePurchaseWithProductId:[NSString stringWithFormat:@"com.gia.%@", [hymnalInfoDict objectForKey:@"hymnal_code"]]]) {
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
        //NSLog2(((HYHymnalInfoWebOperation*)webOp).resultArray)
        for(NSDictionary *dict in ((HYHymnalInfoWebOperation*)webOp).resultArray) {
            NSString *modified = @"0000-00-00 00:00:00";
            if([dict objectForKey:@"modified"]) {
                modified = [dict objectForKey:@"modified"];
            }
            
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
            [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE books SET isComplete = 1 WHERE hymnal_code = %@", SQLEscapeAndQuote([((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"hymnal_code"])];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHymnAdded object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHymnalSelected object:[NSDictionary dictionaryWithObjectsAndKeys:[((HYPDFDownloadWebOperation*)webOp).infoDict objectForKey:@"hymnal_code"] , @"hymnal_code", nil]];
        }
    }
}

- (void)webOperationFailed:(SKBSWebOperation*)webOp withError:(NSError *)error {
    [progressController hide];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error downloading your purchase. Please check your network connection and try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHymnAdded object:nil];
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.ownedArray = nil;
    self.availableArray = nil;
    self.downloadArray = nil;
}

@end