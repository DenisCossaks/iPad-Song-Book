//
//  NSArray+AllTheThings.m
//
//
//  Created by  on .
//  Copyright (c) . All rights reserved.
//

#import "NSArray+AllTheThings.h"
#import "NSDictionary+AllTheThings.h"

@implementation NSArray (AllTheThings)
- (NSArray *)arrayByRemovingNSNulls {
    
	NSMutableArray *mutableSelf = [NSMutableArray arrayWithCapacity:[self count]];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSArray class]]) {
			[mutableSelf addObject:[obj arrayByRemovingNSNulls]];
		}
		else if ([obj isKindOfClass:[NSDictionary class]]) {
			[mutableSelf addObject:[obj dictionaryByRemovingNSNulls]];
		}
		else if ([obj isKindOfClass:[NSNull class]]) {
			// ignored
		}
		else {
			[mutableSelf addObject:obj];
		}
	}];
	
	return [[NSArray alloc] initWithArray:mutableSelf copyItems:NO];
}	
@end
