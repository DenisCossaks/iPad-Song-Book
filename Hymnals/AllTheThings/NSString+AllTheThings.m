//
//  NSString+AllTheThings.m
//  commons
//
//  Created by  on 2/20/13.
//  Copyright (c) 2013  All rights reserved.
//

#import "NSString+AllTheThings.h"

@implementation NSString (AllTheThings)

#pragma mark -  All The Things

+ (NSString *)stringByGeneratingUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);

    return uuidString;
}

- (NSString *)stringByRemovingNonDigits {
    return [[self componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

- (NSString *)stringByTrimmingWhitespaces {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isNumeric {
    return [[[NSNumberFormatter alloc] init] numberFromString:self] ? YES : NO;
}

- (NSComparisonResult)numericCompare:(NSString *)aString {
    return [self compare:aString options:NSNumericSearch];
}

#pragma mark - FullUrlEncodingExtensions

- (NSString *)stringByUrlEncoding {
    // Encode ANY non-alphanumeric character
    NSUInteger length = self.length;
    NSMutableString *encodedString = [NSMutableString stringWithCapacity:length * 3];
    const unsigned char *utf8CString = (const unsigned char *)[self cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; utf8CString[i]; i++) {
        unsigned char theChar = utf8CString[i];
        if ( (theChar < 48 || theChar > 57) && (theChar < 65 || theChar > 90) && (theChar < 97 || theChar > 122) ) {
            NSMutableString *encodedChar = [[NSMutableString alloc] initWithFormat:@"%x", theChar];
            if (encodedChar.length == 1) {
                [encodedChar insertString:@"0" atIndex:0];
            }

            [encodedChar insertString:@"%" atIndex:0];
            [encodedString appendString:encodedChar];
        }
        else {
            [encodedString appendFormat:@"%c", theChar];
        }
    }
    return encodedString;
}

- (NSString *)stringByUrlEncodingButReplacingPercent20sWithPluses {
    return [[self stringByUrlEncoding] stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
}
- (BOOL)isEqualToStringIgnoreCase:(NSString *)aString {
    return [self compare:aString options:NSCaseInsensitiveSearch] == NSOrderedSame;
}
#pragma mark - IsAcceptableExtensions

- (BOOL)isAcceptableAsNumericWhileEntering:(NSInteger)maxLength allowMinus:(BOOL)allowMinus allowDecimal:(BOOL)allowDecimal {
    NSInteger selfLength = [self length];
    if (selfLength > maxLength) {
        return NO;
    }

    if (selfLength == 0) {
        return YES;
    }

    if (selfLength == 1) {
        if (allowDecimal && [self isEqualToString:@"."]) {
            return YES;
        }

        if (allowMinus && [self isEqualToString:@"-"]) {
            return YES;
        }
    }

    if (!allowMinus && [self rangeOfString:@"-"].location != NSNotFound) {
        return NO;
    }

    if (!allowDecimal && [self rangeOfString:@"."].location != NSNotFound) {
        return NO;
    }

    return [self isNumeric];
}

@end
