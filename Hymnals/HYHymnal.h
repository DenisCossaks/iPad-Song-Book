//
//  HYHymnal.h
//  Hymnals
//
//  Created by christopher ngo on 7/18/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYEntity.h"

@interface HYHymnal : HYEntity

// note: not implemented...just the start of moving Hymnal related things in here

+ (NSArray *)arrayOfUnownedHymnalsAsDictionaries;
+ (void)updateHymnalWithHymnalDictionary:(NSDictionary *)hymnalDictionary;

@end
