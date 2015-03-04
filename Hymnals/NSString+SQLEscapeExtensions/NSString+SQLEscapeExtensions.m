//
//  NSString+SQLEscapeExtensions.m
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//
#import "NSString+SQLEscapeExtensions.h"

@implementation NSString(SQLEscapeExtensions)

- (NSString *)stringBySQLEscaping {
    NSMutableString *escapedString = [NSMutableString string];
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar character = [self characterAtIndex:i];
        if (character == '\'') {
            [escapedString appendString:@"''"];
        }
        else {
            [escapedString appendFormat:@"%C", character];
        }
    }
    return escapedString;
}

@end
