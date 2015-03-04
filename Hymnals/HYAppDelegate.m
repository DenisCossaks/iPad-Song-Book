//
//  HYAppDelegate.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYAppDelegate.h"

#import "Reachability.h"
#import <DropboxSDK/DropboxSDK.h>
#import "NSString+AllTheThings.h"
#import "Models.h"
#import "HYAlertView.h"

@implementation HYAppDelegate

@synthesize window = _window;
@synthesize blockingWindow;
@synthesize updateViewController;

@synthesize storeManager;
@synthesize branchfireLibrary;
@synthesize needsUpdateArray;

static NSInteger TAG_CONFIRM_DUPLICATE_SERVICE_LIST = 10;

#pragma mark - lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Flurry startSession:kFlurryAPIKey];
    [Flurry logEvent:@"App Launched"];
    
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"325fd4b345b83bd3d85ffbac78e497f1"
                                                         liveIdentifier:@"325fd4b345b83bd3d85ffbac78e497f1"
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    branchfireLibrary = [[APLibrary alloc] initWithLicenseKey:@"BIPPE-KNPOU-ALMQT-KUQMK-FPLHS-UVSRO-EBIDQ-IKSOQ" dataFolder:nil];
    NSAssert(nil != branchfireLibrary, @"AjiPDFLib failed to initialize.");
    NSLog(@"Version: %@", [branchfireLibrary versionString]);
    
    UIViewController *vc = self.window.rootViewController;
    self.window = [[HYWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = vc;
    
    [[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
    
    if(![[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
        HYPublishedHymnalsWebOperation *webop = [[HYPublishedHymnalsWebOperation alloc] init];
        webop.delegate = self;
        [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
    }
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNetworkReachabilityChangedNotification" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - application delegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if([sourceApplication isEqualToStringIgnoreCase:@"com.getdropbox.Dropbox"]) {
        if ([[DBSession sharedSession] handleOpenURL:url]) {
            if ([[DBSession sharedSession] isLinked]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDropBoxSignedIn object:url];
            }
            return YES;
        }
    }
    else {
        NSString *pathExtension = [[[url absoluteURL] path] pathExtension];
        if ([pathExtension isEqualToStringIgnoreCase:@"pdf"]) {
            [self handlePDFEmailAttachment:url];
        }
        else if ([pathExtension isEqualToStringIgnoreCase:[HYServiceList fileExtension]]) {
            [self handleServiceListFile:url];
        }
        else {
            NSLog(@"\n\nwut?!? got: %@\n\n", url);
        }
    }
    return NO;
}

#pragma mark - webop
- (void)webOperationCompleted:(SKBSWebOperation*)webOp {
    if([webOp isKindOfClass:[HYPublishedHymnalsWebOperation class]]) {
        NSMutableSet *productSet = [[NSMutableSet alloc] init];
        needsUpdateArray = [[NSMutableArray alloc] init];
        for (NSDictionary *hymnal in ((HYPublishedHymnalsWebOperation*)webOp).resultArray) {
            NSArray *bookArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE hymnal_code = %@", SQLEscapeAndQuote([hymnal objectForKey:@"hymnal_code"])];
            if (!bookArray.count) {
                [[HYDatabase sharedDatabase] executeNonQuery:@"INSERT INTO books (hymnal_name, hymnal_code, updated, hymnal_group, cover_url, description, product_identifier) VALUES (%@, %@, %@, %@, %@, %@, %@)", SQLEscapeAndQuote([hymnal objectForKey:@"hymnal_name"]), SQLEscapeAndQuote([hymnal objectForKey:@"hymnal_code"]), SQLEscapeAndQuote([hymnal objectForKey:@"updated"]), SQLEscapeAndQuote([hymnal objectForKey:@"hymnal_group"]), SQLEscapeAndQuote([hymnal objectForKey:@"cover_url"]), SQLEscapeAndQuote([hymnal objectForKey:@"description"]), SQLEscapeAndQuote([hymnal objectForKey:@"product_identifier"])];
            }
            else {
                NSDictionary *originalHymnal = bookArray[0];
                if ([[originalHymnal objectForKey:@"cover_url"] isKindOfClass:[NSNull class]]) {
                    [HYHymnal updateHymnalWithHymnalDictionary:hymnal];
                }
                if (![hymnal[@"updated"] isEqualToString:originalHymnal[@"updated"]]) {
                    [HYHymnal updateHymnalWithHymnalDictionary:hymnal];
                    NSArray *hymnalsArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_code = %@", SQLEscapeAndQuote([hymnal objectForKey:@"hymnal_code"])];
                    if (hymnalsArray.count) {
                        [needsUpdateArray addObject:hymnal];
                    }
                }
            }
            
            [productSet addObject:[NSString stringWithFormat:@"com.gia.%@", [hymnal objectForKey:@"hymnal_code"]]];
        }
        
        [[SKBSStoreManager sharedStoreManager] loadStore];
        [[SKBSStoreManager sharedStoreManager] requestProductsWithIds:productSet];
        
        if (needsUpdateArray.count) {
            [[[UIAlertView alloc] initWithTitle:@"Update?" message:@"There is an update to one or more hymnals you have downloaded. Would you like to update now?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Update", nil] show];
        }
    }
    else if([webOp isKindOfClass:[HYHymnalInfoWebOperation class]]) {
        for(NSDictionary *dict in ((HYHymnalInfoWebOperation*)webOp).resultArray) {
            BOOL shouldDownload = NO;
            NSArray *hymnalArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE pdf_file = %@ AND hymnal_code = %@", SQLEscapeAndQuote([dict objectForKey:@"pdf_file"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_code"])];
            if(hymnalArray.count) {
                if(![[dict objectForKey:@"file_version"] isKindOfClass:[NSNull class]]) {
                    if([[[hymnalArray objectAtIndex:0] objectForKey:@"file_version"] integerValue] < [[dict objectForKey:@"file_version"] integerValue]) {
                        shouldDownload = YES;
                    }
                }
                if(![[dict objectForKey:@"modified"] isKindOfClass:[NSNull class]]) {
                    if(![[[hymnalArray objectAtIndex:0] objectForKey:@"modified"] isEqualToString:[dict objectForKey:@"modified"]]) {
                        [Flurry logEvent:@"Database Upgrade - Hymn Updated" withParameters:dict];
                        
                        // by Woo
                        [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE hymnals SET hymnal_name = %@, hymnal_shortname = %@, title = %@, audio_file = %@, itunes = %@, version = %@, sort = %@, modified = %@, file_version = %@ WHERE pdf_file = %@ AND hymnal_code = %@", SQLEscapeAndQuote([dict objectForKey:@"hymnal_name"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_shortname"]), SQLEscapeAndQuote([dict objectForKey:@"title"]), SQLEscapeAndQuote([dict objectForKey:@"audio_file"]), SQLEscapeAndQuote([dict objectForKey:@"itunes"]), SQLEscapeAndQuote([dict objectForKey:@"version"]), SQLEscapeAndQuote([dict objectForKey:@"sort"]), SQLEscapeAndQuote([dict objectForKey:@"modified"]), SQLEscapeAndQuote([dict objectForKey:@"file_version"]), SQLEscapeAndQuote([dict objectForKey:@"pdf_file"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_code"])];
                    }
                }
            }
            else {
                shouldDownload = YES;
                [Flurry logEvent:@"Database Upgrade - Hymn Added" withParameters:dict];
                
                // By Woo
                [[HYDatabase sharedDatabase] executeNonQuery:@"INSERT OR IGNORE INTO hymnals (hymnal_number, hymnal_name, hymnal_shortname, hymnal_code, title, pdf_file, audio_file, itunes = %@, version, sort, modified, file_version) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)",  SQLEscapeAndQuote([dict objectForKey:@"hymnal_number"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_name"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_shortname"]), SQLEscapeAndQuote([dict objectForKey:@"hymnal_code"]), SQLEscapeAndQuote([dict objectForKey:@"title"]), SQLEscapeAndQuote([dict objectForKey:@"pdf_file"]), SQLEscapeAndQuote([dict objectForKey:@"audio_file"]), SQLEscapeAndQuote([dict objectForKey:@"itunes"]), SQLEscapeAndQuote([dict objectForKey:@"version"]), SQLEscapeAndQuote([dict objectForKey:@"sort"]), SQLEscapeAndQuote([dict objectForKey:@"modified"]), SQLEscapeAndQuote([dict objectForKey:@"file_version"])];
            }
            if(shouldDownload) {
                HYPDFDownloadWebOperation *webop = [[HYPDFDownloadWebOperation alloc] initWithHymnInfo:dict];
                webop.delegate = self;
                [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
            }
        }
        
        for(NSDictionary *updatedHymnalDict in needsUpdateArray) {
            if ([[updatedHymnalDict objectForKey:@"hymnal_code"] isEqualToString:((HYHymnalInfoWebOperation*)webOp).codeString]) {
                [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE books SET updated = %@ WHERE hymnal_code = %@", SQLEscapeAndQuote([updatedHymnalDict objectForKey:@"updated"]), SQLEscapeAndQuote([updatedHymnalDict objectForKey:@"hymnal_code"])];
            }
        }
        
        if(![[SKBSWebOperationQueue sharedWebOperationQueue] operationCount]) {
            [updateViewController hide];
        }
    }
}

- (void)webOperationFailed:(SKBSWebOperation*)webOp withError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error connecting to our servers. You will not be able to purchase additional content right now." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    if (updateViewController) {
        [updateViewController hide];
        [[SKBSWebOperationQueue sharedWebOperationQueue] cancelAllOperations];
    }
}

#pragma mark - actionsheet
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_CONFIRM_DUPLICATE_SERVICE_LIST) {
        if (!buttonIndex)
            return;
        
        if (![alertView isKindOfClass:[HYAlertView class]]) {
            ShowFixMeAlert(@"weirdness");
            return;
        }
        
        id newServiceList = ((HYAlertView *)alertView).objectOfInterest1;
        id serviceLists = ((HYAlertView *)alertView).objectOfInterest2;
        
        if (![newServiceList isKindOfClass:[HYServiceList class]] || ![serviceLists isKindOfClass:[NSArray class]]) {
            ShowFixMeAlert(@"more weirdness")
            return;
        }
        
        [self saveServiceList:newServiceList inServiceLists:serviceLists];
    }
    else {
        if(buttonIndex) {
            if(!updateViewController) {
                updateViewController = [[HYUpdateViewController alloc] init];
            }
            if(!updateViewController.isVisible) {
                [updateViewController show];
            }
            for(NSDictionary *dict in needsUpdateArray) {
                HYHymnalInfoWebOperation *webop = [[HYHymnalInfoWebOperation alloc] initWithCode:[dict objectForKey:@"hymnal_code"]];
                webop.delegate = self;
                [[SKBSWebOperationQueue sharedWebOperationQueue] addOperation:webop];
            }
        }
    }
}
#pragma mark - Email Attachments
- (void)handlePDFEmailAttachment:(NSURL *)url {
    NSError *error;
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", [url lastPathComponent]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    [[NSFileManager defaultManager] moveItemAtURL:url toURL:[NSURL fileURLWithPath:filePath] error:&error];
    
    if(!error) {
        NSInteger count = [[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_code = 'IM'"] count] + 1;
        [[HYDatabase sharedDatabase] executeNonQuery:@"INSERT INTO hymnals (hymnal_number, hymnal_name, hymnal_shortname, hymnal_code, title, pdf_file) VALUES (%i, 'Imported Music', 'Imported Music', 'IM', %@, %@)", count, SQLEscapeAndQuote([[url lastPathComponent] stringByDeletingPathExtension]) , SQLEscapeAndQuote([url lastPathComponent])];
        NSArray *addedArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE id = %i", [[HYDatabase sharedDatabase] lastInsertedRowId]];
        
        if(addedArray.count) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHymnAdded object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHymnSelected object:[addedArray objectAtIndex:0]];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error saving this file to the database" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        }
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Error Moving File" message:[error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    }
}
- (void)handleServiceListFile:(NSURL *)url {
    NSError *error = nil;
    NSString *serviceListAsString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog2(error);
        ShowAlert(@"Error", Stringify(error))
        return;
    }
    
    JSONModelError *error2 = nil;
    HYServiceList *newServiceList = [[HYServiceList alloc] initWithString:serviceListAsString error:&error2];
    if (error2) {
        ShowAlert(@"Error", Stringify(error2));
        return;
    }
    
    BOOL foundDuplicate = NO;
    NSArray *serviceLists = [HYServiceList arrayOfServiceLists2];
    for (HYServiceList *serviceList in serviceLists){
        // TODO
        //        if ([serviceList containsSameHymnalsAsServiceList:newServiceList ignoreOrder:YES]) {
        //            foundDuplicate = YES;
        //            break;
        //        }
    }
    
    if (foundDuplicate) {
        HYAlertView *alertView = [[HYAlertView alloc] initWithTitle:@"Save?" message:@"Another service list exists with these hymnals." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alertView setObjectOfInterest1:newServiceList];
        [alertView setObjectOfInterest2:serviceLists];
        [alertView setTag:TAG_CONFIRM_DUPLICATE_SERVICE_LIST];
        [alertView show];
    }
    else {
        [self saveServiceList:newServiceList inServiceLists:serviceLists];
    }
}
- (void)saveServiceList:(HYServiceList *)serviceList inServiceLists:(NSArray *)serviceLists {
    if (!serviceList || !serviceLists) {
        ShowFixMeAlert(@"nils?")
        return;
    }
    
    // TODO: move this code into the model
    
    // part 1 - filter out imported music or ones not available in the local db
    NSArray *hymnsToSave = [serviceList hymns];
    NSArray *hymnsToSaveNoImportedMusic = [[serviceList hymns] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isImportedMusic = NO"]];
    
    NSArray *availableHymnIDs = [HYHymn arrayOfAvailableHymnIdentifiers];
    NSArray *hymnsToSaveFiltered = [hymnsToSaveNoImportedMusic filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [availableHymnIDs containsObject:((HYHymn *)evaluatedObject).hymnIdentifier];
    }]];
    
    
    
    // debug stuff
    BOOL showDebugEmail = NO;
    if (showDebugEmail) {
        
        NSMutableString *debugMessage = [NSMutableString stringWithCapacity:100];
        [debugMessage appendFormat:@"Service list to save:\n%@\n\n\n", serviceList.toJSONString];
        [debugMessage appendString:@"Available hymns:"];
        for (HYHymnIdentifier *hymnIdentifier in availableHymnIDs) {
            [debugMessage appendFormat:@"\n%@", [hymnIdentifier toJSONString]];
        }
        [debugMessage appendString:@"\n\n\nHymns that will be saved:"];
        for (HYHymn *hymn in hymnsToSaveFiltered) {
            [debugMessage appendFormat:@"\n%@", [hymn toJSONString]];
        }
        if (![hymnsToSaveFiltered count]) {
            [debugMessage appendString:@"\n\n\n*** skipping service list l**"];
        }
        
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setMailComposeDelegate:self];
        [mailComposeViewController setToRecipients:@[@"ngo.chr@gmail.com", @"stephen@skbsoftware.net"]];
        [mailComposeViewController setSubject:@"Service list debug info"];
        [mailComposeViewController setMessageBody:debugMessage isHTML:NO];
        [self.window.rootViewController presentViewController:mailComposeViewController animated:YES completion:NULL];
    }
    
    
    if (!hymnsToSaveFiltered.count) {
        ShowAlert(@"Service list not imported.", @"Your library does not contain any of the hymns in this service list. Please purchase the hymnal containing these titles and then reimport the service list.");
        return;
    }
    
    
    // part 2 - save
    HYServiceList *insertedServiceList = [HYServiceList serviceListWithName:serviceList.name andDisplayOrder:serviceLists.count];
    for (HYHymn *hymn in hymnsToSaveFiltered) {
        NSUInteger index = [availableHymnIDs indexOfObject:[hymn hymnIdentifier]]; // need to find local id for table
        if (index == NSNotFound) {
            ShowFixMeAlert(@"hymn id not found") // something is probably wrong with the above predicateWithBlock
            continue;
        }
        
        [insertedServiceList addHymnWithID:[(HYHymnIdentifier *)availableHymnIDs[index] idNumber]];
    }
    
    
    // part 3 - inform user of results
    BOOL skippedImportedMusic = hymnsToSave.count != hymnsToSaveNoImportedMusic.count;
    BOOL skippedUnavailableHymn = hymnsToSaveNoImportedMusic.count != hymnsToSaveFiltered.count;
    
    NSString *title = [NSString stringWithFormat:@"Saved service list: %@", serviceList.name];
    NSString *message = nil;
    if (skippedUnavailableHymn) {
        message = @"The service list you are importing contains titles that are not currently in your library.  They will not be imported.  Please purchase the hymnal containing these titles and then reimport the service list.";
    }
    else if (skippedImportedMusic) {
        message = @"Imported music could not be saved.";
    }
    ShowAlert(title, message);
}
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - BITHockeyManagerDelegate

@end
