//
//  HYServiceList.h
//  Hymnals
//
//  Created by christopher ngo on 6/17/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYEntity.h"

@protocol HYHymn;

@interface HYServiceList : HYEntity

+ (NSArray *)arrayOfServiceLists;
+ (NSArray *)arrayOfServiceLists2;
+ (NSString *)fileExtension;
+ (HYServiceList *)serviceListWithName:(NSString *)name andDisplayOrder:(NSInteger)displayOrder;
+ (NSString *)version;

@property (nonatomic, strong) NSNumber *idAsNumber;
@property (nonatomic, strong) NSNumber *displayOrder;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<HYHymn> *hymns; // array of HYHymnals and expected to be in proper order

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)deleteHymnalAtIndex:(NSInteger)index;
- (void)renameHymnalAtIndex:(NSInteger)index withName:(NSString *)name;
- (void)moveHymnalFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)addHymnWithID:(NSNumber *)hymnID;

- (BOOL)containsSameHymnalsAsServiceList:(HYServiceList *)serviceList ignoreOrder:(BOOL)ignoreOrder;

@end
