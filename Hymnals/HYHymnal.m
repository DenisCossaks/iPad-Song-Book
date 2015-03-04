//
//  HYHymnal.m
//  Hymnals
//
//  Created by christopher ngo on 7/18/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYHymnal.h"

#import "HYDatabase.h"
#import "NSArray+AllTheThings.h"

@implementation HYHymnal

static NSString * const kHymnalGroupKey = @"hymnal_group";
static NSString * const kCoverURLKey = @"cover_url";
static NSString * const kDescriptionKey = @"description";
static NSString * const kProductIdentiferKey = @"product_identifier";
static NSString * const kHymnalCodeKey = @"hymnal_code";
static NSString * const kUpdatedKey = @"updated";

+ (NSArray *)arrayOfUnownedHymnalsAsDictionaries {
    return [[[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM books WHERE isOwned = 0"] arrayByRemovingNSNulls];
}
+ (void)updateHymnalWithHymnalDictionary:(NSDictionary *)hymnalDict {
    if (!hymnalDict) {
        return;
    }
    NSLog2(hymnalDict)
    [[HYDatabase sharedDatabase] executeNonQuery:@"UPDATE books SET hymnal_group = %@, cover_url = %@, description = %@, product_identifier = %@, updated = %@ WHERE hymnal_code = %@",
        SQLEscapeAndQuote(hymnalDict[kHymnalGroupKey]),
        SQLEscapeAndQuote(hymnalDict[kCoverURLKey]),
        SQLEscapeAndQuote(hymnalDict[kDescriptionKey]),
        SQLEscapeAndQuote(hymnalDict[kProductIdentiferKey]),
        SQLEscapeAndQuote(hymnalDict[kUpdatedKey]),
        SQLEscapeAndQuote(hymnalDict[kHymnalCodeKey])];
}
@end
