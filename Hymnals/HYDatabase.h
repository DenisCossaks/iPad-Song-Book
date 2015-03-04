//
//  HYDatabase.h
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "SqliteWrapper.h"
#define DBNULLIfNilOrNSNull(x) ((!x || (NSNull *)x == [NSNull null]) ? @"NULL" : x)

@interface HYDatabase : SqliteWrapper {
	
}

+ (HYDatabase *)sharedDatabase;

@end
