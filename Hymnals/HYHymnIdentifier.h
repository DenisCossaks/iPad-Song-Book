//
//  HYHymnIdentifier.h
//  Hymnals
//
//  Created by christopher ngo on 7/14/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYEntity.h"

@interface HYHymnIdentifier : HYEntity

// these two properties uniquely identifies a hymn (composite primary key) across all app installs
@property (nonatomic, readonly) NSString *hymnalCode;
@property (nonatomic, readonly) NSNumber *number;

// this property is the id assign by the database when inserted so is probably different on whichever machine
@property (nonatomic, readonly) NSNumber *idNumber;

- (id)initWithHymnalCode:(NSString *)hymnalCode number:(NSNumber *)number idNumber:(NSNumber *)idNumber;
- (BOOL)isEqual:(id)object;

@end
