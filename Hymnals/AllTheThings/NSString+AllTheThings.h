//
//  NSString+AllTheThings.h
//  commons
//
//  Created by  on 2/20/13.
//  Copyright (c) . All rights reserved.
//


@interface NSString (AllTheThings)
/**
   All The Things
 */
+ (NSString *)stringByGeneratingUUID;
- (NSString *)stringByRemovingNonDigits;
- (NSString *)stringByTrimmingWhitespaces;
- (BOOL)isNumeric;
- (NSComparisonResult)numericCompare:(NSString *)aString;
- (BOOL)isEqualToStringIgnoreCase:(NSString *)aString;
/**
   FullUrlEncodingExtensions
 */
- (NSString *)stringByUrlEncoding;
- (NSString *)stringByUrlEncodingButReplacingPercent20sWithPluses;

/**
   IsAcceptableExtensions
 */
- (BOOL)isAcceptableAsNumericWhileEntering:(NSInteger)maxLength allowMinus:(BOOL)allowMinus allowDecimal:(BOOL)allowDecimal;

@end
