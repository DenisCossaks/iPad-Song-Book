//
//  HYServiceList.m
//  Hymnals
//
//  Created by christopher ngo on 6/17/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYServiceList.h"

#import "Models.h"

@implementation HYServiceList

@synthesize hymns = _hymnals;

+ (NSArray *)arrayOfServiceLists {
    return [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT * FROM servicelists ORDER BY display_order"];
}
+ (NSArray *)arrayOfServiceLists2 {
    NSArray *serviceLists = [HYServiceList arrayOfServiceLists];
    NSMutableArray *mutableTypedServiceLists = [NSMutableArray arrayWithCapacity:[serviceLists count]];
    for (NSDictionary *serviceListItemDict in serviceLists) {
        [mutableTypedServiceLists addObject:[[HYServiceList alloc] initWithDictionary:serviceListItemDict]];
    }
    return [[NSArray alloc] initWithArray:mutableTypedServiceLists copyItems:NO];
}
+ (NSString *)fileExtension {
    return @"hym";
}
+ (HYServiceList *)serviceListWithName:(NSString *)name andDisplayOrder:(NSInteger)displayOrder {
    
    HYDatabase *sharedDatabase = [HYDatabase sharedDatabase];
    [sharedDatabase executeNonQuery:@"INSERT INTO servicelists (name, display_order) VALUES (%@, %d)", SQLEscapeAndQuote(name), displayOrder];
    NSDictionary *serviceListAsDictionary = [sharedDatabase executeSimpleQuery:@"SELECT * FROM servicelists WHERE id = %i", [sharedDatabase lastInsertedRowId]][0];
    return [[HYServiceList alloc] initWithDictionary:serviceListAsDictionary];
}
+ (NSString *)version {
    return @"1.0";
}
#pragma mark -
- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self setIdAsNumber:dictionary[@"id"]];
        [self setDisplayOrder:dictionary[@"display_order"]];
        [self setName:dictionary[@"name"]];
    }
    return self;
}
- (NSArray *)hymns {
    if (!_hymnals) {
        _hymnals = (NSArray<HYHymn> *)[HYHymn arrayOfHymnsWithServiceListID2:self.idAsNumber];
    }
    return _hymnals;
}
- (void)deleteHymnalAtIndex:(NSInteger)index {
    if (index >= [[self hymns] count]) {
        return;
    }
    
    HYHymn *hymnal = self.hymns[index];
    [[HYDatabase sharedDatabase] executeNonQuery:@"DELETE FROM servicelist_hymnals WHERE id = %@", hymnal.idAsNumber];
    
    NSMutableArray *mutableHymnals = [[NSMutableArray alloc] initWithArray:self.hymns copyItems:NO];
    [mutableHymnals removeObjectAtIndex:index];
    _hymnals = (NSArray<HYHymn> *)[[NSArray alloc] initWithArray:mutableHymnals copyItems:NO];
}
- (void)renameHymnalAtIndex:(NSInteger)index withName:(NSString *)name {
    if (![name length]) {
        return;
    }
    
    HYHymn *hymnal = self.hymns[index];
    
    HYDatabase *sharedDatabase = [HYDatabase sharedDatabase];
    [sharedDatabase executeNonQuery:@"UPDATE servicelist_hymnals SET name = %@ WHERE id = %i", SQLEscapeAndQuote(name), hymnal.idAsNumber.integerValue];

    NSArray *hymnals = [sharedDatabase executeSimpleQuery:@"SELECT * FROM servicelist_hymnals WHERE id = %i", hymnal.idAsNumber.integerValue];
    if ([hymnals count] == 1) {
        NSMutableArray *mutableHymnals = [[NSMutableArray alloc] initWithArray:self.hymns copyItems:NO];
        [mutableHymnals replaceObjectAtIndex:index withObject:[[HYHymn alloc] initWithDictionary:hymnals[0]]];
        _hymnals = (NSArray<HYHymn> *)[[NSArray alloc] initWithArray:mutableHymnals copyItems:NO];
    }
}
- (void)moveHymnalFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    NSMutableArray *mutableHymnals = [[NSMutableArray alloc] initWithArray:self.hymns copyItems:NO];
    HYHymn *hymnal = mutableHymnals[fromIndex];
    [mutableHymnals removeObjectAtIndex:fromIndex];
    [mutableHymnals insertObject:hymnal atIndex:toIndex];
    _hymnals = (NSArray<HYHymn> *)[[NSArray alloc] initWithArray:mutableHymnals copyItems:NO];
    
    NSInteger displayOrder = 0;
    HYDatabase *sharedDatabase = [HYDatabase sharedDatabase];
    for(HYHymn *hymnal in mutableHymnals) {
        [sharedDatabase executeNonQuery:@"UPDATE servicelist_hymnals SET display_order = %i WHERE id = %@", displayOrder++, hymnal.idAsNumber];
    }
}
- (void)addHymnWithID:(NSNumber *)hymnID {
    [[HYDatabase sharedDatabase] executeNonQuery:@"INSERT INTO servicelist_hymnals (hymnal_id, servicelist_id, display_order) VALUES (%@, %@, %i)", hymnID, self.idAsNumber, [self hymns].count];
    _hymnals = nil; // to force another db call if needed
}
- (BOOL)containsSameHymnalsAsServiceList:(HYServiceList *)serviceList ignoreOrder:(BOOL)ignoreOrder {
    return YES;
}
@end
