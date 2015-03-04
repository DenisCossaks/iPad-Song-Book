//
//  NSString+SQLEscapeExtensions.h
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//
#define SQLEscape(x) x ? ((NSNull *)x == [NSNull null] ? @"NULL" : [x stringBySQLEscaping]) : @"NULL"
#define SQLEscapeAndQuote(x) x ? ((NSNull *)x == [NSNull null] ? @"NULL" : [NSString stringWithFormat:@"'%@'", [x stringBySQLEscaping]]) : @"NULL"
@interface NSString(SQLEscapeExtensions)

- (NSString *)stringBySQLEscaping;

@end
