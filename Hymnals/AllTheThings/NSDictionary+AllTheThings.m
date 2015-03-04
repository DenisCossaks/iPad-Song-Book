//
//  NSDictionary+NullRemoval.m
//  
//
//  Created by  on .
//  Copyright (c)  . All rights reserved.
//

#import "NSDictionary+AllTheThings.h"

#import "NSArray+AllTheThings.h"

@implementation NSDictionary (AllTheThings)
- (NSDictionary *)dictionaryByRemovingNSNulls {
    
	NSMutableDictionary *mutableSelf = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([obj isKindOfClass:[NSDictionary class]]) {
			[mutableSelf setObject:[obj dictionaryByRemovingNSNulls] forKey:key];
		}
		else if ([obj isKindOfClass:[NSArray class]]) {
			[mutableSelf setObject:[obj arrayByRemovingNSNulls] forKey:key];
		}
		else if ([obj isKindOfClass:[NSNull class]]) {
			// ignored
		}
		else {
			[mutableSelf setObject:obj forKey:key];
		}
	}];
	
	return [[NSDictionary alloc] initWithDictionary:mutableSelf copyItems:NO];
}
@end
