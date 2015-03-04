//
//  HYHymnal.h
//  Hymnals
//
//  Created by christopher ngo on 6/17/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYEntity.h"

@class HYHymnIdentifier;

@protocol HYHymn @end // needed for JSONModel

@interface HYHymn : HYEntity

+ (NSArray *)arrayOfHymnsWithServiceListID:(NSNumber *)serviceID;
+ (NSArray *)arrayOfHymnsWithServiceListID2:(NSNumber *)serviceID;
+ (NSArray *)arrayOfHymnPDFsThatShouldBeDownloaded; // array of NSStrings
+ (NSArray *)arrayOfAvailableHymnIdentifiers; // array of HYHymnIdentifier; hymn IDs that're saved in the database (either included with the app or purchased)
+ (NSString *)importedMusicName;
+ (NSString *)importedMusicCode;

/*
 * warning: changing propery name(s) or adding non-optional properties will
 *          break JSONModel dicts created with previous name or missing property
 */
// properties pertaining the hymnal (book table in db) that this hymn belongs in
@property (nonatomic, strong) NSString *hymnalCode;
@property (nonatomic, strong) NSString *hymnalName;

// properties pertaining to the hymn
@property (nonatomic, strong) NSNumber *idAsNumber;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *displayOrder;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;


- (BOOL)isImportedMusic;
- (NSString *)displayText;
- (NSString *)version2;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (HYHymnIdentifier *)hymnIdentifier;

@end
