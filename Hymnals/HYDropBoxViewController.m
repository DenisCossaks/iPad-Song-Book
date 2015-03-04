//
//  HYDropBoxViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 8/14/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYDropBoxViewController.h"

@implementation HYDropBoxViewController

@synthesize contentTableView;
@synthesize progressController;

@synthesize restClient;
@synthesize currentDirectoryMeta;
@synthesize currentDropBoxPath;

#pragma mark - loading
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.contentSizeForViewInPopover = CGSizeMake(400, 462);
    }
    return self;
}

- (void)viewDidLoad {
//    [Flurry logEvent:@"Hymnals List - Viewed"];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Dropbox";
    
    if(currentDropBoxPath) {
        self.title = [currentDropBoxPath lastPathComponent];
    }
    else {
        self.title = @"Dropbox";
        currentDropBoxPath = @"";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxSignedIn:) name:kDropBoxSignedIn object:nil];
    
    DBSession *session = [[DBSession alloc] initWithAppKey:kDropBoxConsumerKey appSecret:kDropBoxConsumerSecret root:kDBRootDropbox];
	session.delegate = self;
	[DBSession setSharedSession:session];
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    else if(!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
        [self.restClient loadMetadata:currentDropBoxPath];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out of Dropbox" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonTouched)];
    }
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - actions
- (void)logOutButtonTouched {
    [[DBSession sharedSession] unlinkAll];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentDirectoryMeta.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBDropBoxViewController"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PBDropBoxViewController"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    cell.textLabel.text = [[[currentDirectoryMeta.contents objectAtIndex:indexPath.row] path] lastPathComponent];
    cell.textLabel.textColor = UIColor.blackColor;
    
    if([[currentDirectoryMeta.contents objectAtIndex:indexPath.row] isDirectory]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"icon-folder"];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if([[NSArray arrayWithObjects:@"pdf", nil] indexOfObject:[[[[currentDirectoryMeta.contents objectAtIndex:indexPath.row] path] pathExtension] lowercaseString]] != NSNotFound) {
            cell.imageView.image = [UIImage imageNamed:@"icon-pdf"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"icon-unsupported"];
            cell.textLabel.textColor = UIColor.darkGrayColor;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[currentDirectoryMeta.contents objectAtIndex:indexPath.row] isDirectory]) {
        HYDropBoxViewController *viewController = [[HYDropBoxViewController alloc] initWithNibName:nil bundle:nil];
        viewController.currentDropBoxPath = [[currentDirectoryMeta.contents objectAtIndex:indexPath.row] path];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if([[NSArray arrayWithObjects:@"pdf", nil] indexOfObject:[[[[currentDirectoryMeta.contents objectAtIndex:indexPath.row] path] pathExtension] lowercaseString]] != NSNotFound) {
        [restClient loadFile:[[currentDirectoryMeta.contents objectAtIndex:indexPath.row] path] intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[[currentDirectoryMeta.contents objectAtIndex:indexPath.row] path] lastPathComponent]]];
        progressController = [[HYDownloadProgressViewController alloc] init];
        [progressController show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - dropbox
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    self.currentDirectoryMeta = metadata;
    [contentTableView reloadData];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Listing this directory from Dropbox failed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    NSLog(@"%@", error);
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath {
    [progressController hide];
    
    NSError *error;
    if([[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", [destPath lastPathComponent]]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", [destPath lastPathComponent]] error:nil];
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:destPath toPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", [destPath lastPathComponent]] error:&error];
    
    if(!error) {
        NSInteger count = [[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE hymnal_code = 'IM'"] count] + 1;
        [[HYDatabase sharedDatabase] executeNonQuery:@"INSERT INTO hymnals (hymnal_number, hymnal_name, hymnal_shortname, hymnal_code, title, pdf_file, version) VALUES (%i, 'Imported Music', 'Imported Music', 'IM', %@, %@, '')", count, SQLEscapeAndQuote([[destPath lastPathComponent] stringByDeletingPathExtension]) , SQLEscapeAndQuote([destPath lastPathComponent])];
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

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
    [progressController updateProgress:progress];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    [progressController hide];
    
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Downloading this file from Dropbox failed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    NSLog(@"%@", error);
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error signing into Dropbox." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)dropBoxSignedIn:(NSNotification*)notification {
    if(!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    [self.restClient loadMetadata:currentDropBoxPath];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out of Dropbox" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonTouched)];
}

@end
