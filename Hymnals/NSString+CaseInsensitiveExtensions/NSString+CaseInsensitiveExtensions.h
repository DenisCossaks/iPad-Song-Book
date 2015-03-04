//
//  NSString+CaseInsensitiveExtensions.h
//
//  Created by Stephen Bradley on 4/9/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//
@interface NSString(CaseInsensitiveExtensions)

- (BOOL)caseInsensitiveHasPrefix:(NSString *)prefix;
- (BOOL)caseInsensitiveIsEqualToString:(NSString *)aString;

@end
