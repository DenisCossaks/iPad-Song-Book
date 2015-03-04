//
//  HYImportedMusicViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 12/12/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYImportedMusicViewController.h"

@implementation HYImportedMusicViewController

@synthesize musicArray;

#pragma mark - loading
- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.contentSizeForViewInPopover = CGSizeMake(400, 462);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Imported Music - Viewed"];
    
    self.navigationItem.title = @"Imported Music";
    
    musicArray = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT hymnals.* FROM hymnals WHERE hymnal_code = 'IM' ORDER BY hymnal_number, sort"];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
}

#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return musicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HYImportedMusicViewController"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HYImportedMusicViewController"];
    }
    NSDictionary *hymnDict = [musicArray objectAtIndex:indexPath.row];
    
    if (![[hymnDict objectForKey:@"title"] isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = [hymnDict objectForKey:@"title"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename Music" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = [[[musicArray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
        if (![[[musicArray objectAtIndex:indexPath.row] objectForKey:@"title"] isKindOfClass:[NSNull class]]) {
            [[alertView textFieldAtIndex:0] setText:[[musicArray objectAtIndex:indexPath.row] objectForKey:@"title"]];
        }

        [alertView show];
        selectedIndexPath = indexPath;
    }
    else {
        [Flurry logEvent:@"Imported Music - Item Selected"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHymnSelected object:[musicArray objectAtIndex:indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [Flurry logEvent:@"Imported Music - Item Deleted"];
    [[HYDatabase sharedDatabase] executeNonQuery:@"DELETE FROM hymnals WHERE id = %@", [[musicArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
    [musicArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if (!musicArray.count) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        if([[[alertView textFieldAtIndex:0] text] length]) {
            [Flurry logEvent:@"Imported Music - Item Renamed"];
            [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE hymnals SET title = %@ WHERE id = %i", SQLEscapeAndQuote([[alertView textFieldAtIndex:0] text]), alertView.tag];
            [musicArray replaceObjectAtIndex:selectedIndexPath.row withObject:[[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM hymnals WHERE id = %i", alertView.tag] objectAtIndex:0]];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - cleanup
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.musicArray = nil;
}

@end