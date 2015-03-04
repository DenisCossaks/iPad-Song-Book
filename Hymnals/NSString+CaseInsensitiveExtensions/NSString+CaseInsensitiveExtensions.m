//
//  NSString+CaseInsensitiveExtensions.m
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//
#import "NSString+CaseInsensitiveExtensions.h"

@implementation NSString(CaseInsensitiveExtensions)

- (BOOL)caseInsensitiveHasPrefix:(NSString *)prefix {
	NSRange range = [self rangeOfString:prefix options:NSCaseInsensitiveSearch];
	return range.location == 0;
}

- (BOOL)caseInsensitiveIsEqualToString:(NSString *)aString {
	return [self caseInsensitiveCompare:aString] == NSOrderedSame;
}
@end
