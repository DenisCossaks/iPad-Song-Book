//
//  HYDatabase.m
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYDatabase.h"
#import "SqliteWrapperProtectedMethods.h"

@implementation HYDatabase

static HYDatabase *sharedDatabase;

#pragma mark - loading
+ (HYDatabase *)sharedDatabase {
	@synchronized(self) {
		if (!sharedDatabase) {
			HYDatabase *database = [[HYDatabase alloc] init];
            database = nil;
        }
	}
	return sharedDatabase;
}

+ (id)alloc {
	@synchronized(self) {
		NSAssert(sharedDatabase == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedDatabase = [super alloc];
	}
	return sharedDatabase;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		databasePath = [documentsDirectory stringByAppendingPathComponent:@"HYDatabase.db"];
		
		[databaseLock lock];
        BOOL addNewTables = NO;
		if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
            addNewTables = YES;            
		}
		[self openDatabase];
		[databaseLock unlock];
        if (addNewTables) {
            //Version 1.0
            [self executeNonQuery:@"CREATE TABLE books (id INTEGER PRIMARY KEY, hymnal_name TEXT, hymnal_code TEXT, isOwned BOOL DEFAULT 0, isComplete BOOL DEFAULT 0)"];
            [self executeNonQuery:@"INSERT INTO books (hymnal_name, hymnal_code, isOwned, isComplete) VALUES ('Sample Hymns', 'SH', 1, 1)"];
            [self executeNonQuery:@"INSERT INTO books (hymnal_name, hymnal_code) VALUES ('Gather Third Edition', 'G3')"];
            [self executeNonQuery:@"INSERT INTO books (hymnal_name, hymnal_code) VALUES ('Gather Third Edition Choir', 'G3C')"];
            
            [self executeNonQuery:@"CREATE TABLE hymnals (id INTEGER PRIMARY KEY, hymnal_number INTEGER, hymnal_name TEXT, hymnal_shortname TEXT, hymnal_code TEXT, title TEXT, pdf_file TEXT, audio_file TEXT, version TEXT, isDownloaded BOOL DEFAULT 0)"];
            [self executeNonQuery:@"INSERT INTO hymnals (hymnal_number, hymnal_name, hymnal_shortname, hymnal_code, title, pdf_file, audio_file) VALUES (441, 'Sample Hymns', 'Sample Hymns', 'SH', 'Silent Night', 'G3_441-1.pdf', 'G3_441-1.mp3')"];
            [self executeNonQuery:@"INSERT INTO hymnals (hymnal_number, hymnal_name, hymnal_shortname, hymnal_code, title, pdf_file, audio_file) VALUES (645, 'Sample Hymns', 'Sample Hymns', 'SH', 'Amazing Grace', 'G3_645-1.pdf', 'G3_645-1.mp3')"];
            [self executeNonQuery:@"INSERT INTO hymnals (hymnal_number, hymnal_name, hymnal_shortname, hymnal_code, title, pdf_file, audio_file) VALUES (694, 'Sample Hymns', 'Sample Hymns', 'SH', 'How Firm a Foundation', 'G3_694-1.pdf', 'G3_694-1.mp3')"];
            
            [self executeNonQuery:@"CREATE TABLE servicelists (id INTEGER PRIMARY KEY, name TEXT, display_order INTEGER)"];
            
            [self executeNonQuery:@"CREATE TABLE servicelist_hymnals (id INTEGER PRIMARY KEY, hymnal_id INTEGER, servicelist_id INTEGER, display_order INTEGER)"];
        }
        if (![[self executeSimpleQuery:@"SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'version'"] count]) {
            //Version 1.1
            [self executeNonQuery:@"CREATE TABLE version (id INTEGER PRIMARY KEY, version TEXT)"];
            [self executeNonQuery:@"INSERT INTO version (version) VALUES ('1.1')"];
            
            [self executeNonQuery:@"ALTER TABLE servicelist_hymnals ADD COLUMN name TEXT"];
            
            [self executeNonQuery:@"ALTER TABLE hymnals ADD COLUMN sort INTEGER DEFAULT 0"];
            [self executeNonQuery:@"ALTER TABLE hymnals ADD COLUMN modified TEXT DEFAULT '0000-00-00 00:00:00'"];
            [self executeNonQuery:@"ALTER TABLE hymnals ADD COLUMN file_version INTEGER DEFAULT 1"];
        }
        if ([[[[self executeSimpleQuery:@"SELECT * FROM version"] objectAtIndex:0] objectForKey:@"version"] isEqualToString:@"1.1"]) {
            //Version 1.2
            [self executeNonQuery:@"UPDATE version SET version = '1.2' WHERE id = 1"];
    
            [self executeNonQuery:@"ALTER TABLE books ADD COLUMN updated TEXT DEFAULT '0000-00-00 00:00:00'"];
            
            [self executeNonQuery:@"INSERT INTO books (id, hymnal_name, hymnal_code, isOwned, isComplete) VALUES (100, 'Imported Music', 'IM', 1, 1)"];
        }
        if ([[[[self executeSimpleQuery:@"SELECT * FROM version"] objectAtIndex:0] objectForKey:@"version"] isEqualToString:@"1.2"]) {
            //Version 1.5
            [self executeNonQuery:@"UPDATE version SET version = '1.5' WHERE id = 1"];
            
            [self executeNonQuery:@"ALTER TABLE books ADD COLUMN cover_url TEXT"];
            [self executeNonQuery:@"ALTER TABLE books ADD COLUMN hymnal_group TEXT"];
            [self executeNonQuery:@"ALTER TABLE books ADD COLUMN product_identifier TEXT"];
            [self executeNonQuery:@"ALTER TABLE books ADD COLUMN description TEXT"];
            
            [self executeNonQuery:@"UPDATE books SET cover_url = 'http://services.giamusic.com/hymnal-covers/sample-hymns-retna.png' WHERE hymnal_code = 'SH'"];
            [self executeNonQuery:@"UPDATE books SET cover_url = 'http://services.giamusic.com/hymnal-covers/imported-hymns-retna.png' WHERE hymnal_code = 'IM'"];
        }
        if ([[[[self executeSimpleQuery:@"SELECT * FROM version"] objectAtIndex:0] objectForKey:@"version"] isEqualToString:@"1.5"]) {
            //Version 1.5.2
            [self executeNonQuery:@"UPDATE version SET version = '1.5.2' WHERE id = 1"];
            
            [self executeNonQuery:@"ALTER TABLE hymnals ADD COLUMN itunes TEXT"];
            
            [self executeNonQuery:@"UPDATE hymnals SET itunes = 'https://itunes.apple.com/us/album/silent-night-noche-paz-gather/id804002641?i=804002768' WHERE hymnal_number = 441"];
            [self executeNonQuery:@"UPDATE hymnals SET itunes = 'https://itunes.apple.com/us/album/amazing-grace-gather-3-hymnal/id798027265?i=798027363' WHERE hymnal_number = 645"];
            [self executeNonQuery:@"UPDATE hymnals SET itunes = 'https://itunes.apple.com/us/album/how-firm-foundation-gather/id797913973?i=797914043' WHERE hymnal_number = 694"];
        
        }
	}
	return self;
}

@end