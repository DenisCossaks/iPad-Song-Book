//
//  HYHymnIdentifier.m
//  Hymnals
//
//  Created by christopher ngo on 7/14/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYHymnIdentifier.h"

#import "NSString+AllTheThings.h"

@implementation HYHymnIdentifier

- (id)initWithHymnalCode:(NSString *)hymnalCode number:(NSNumber *)number idNumber:(NSNumber *)idNumber {
    if (self = [super init]) {
        _hymnalCode = hymnalCode;
        _number = number;
        _idNumber = idNumber;
    }
    return self;
}
- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[HYHymnIdentifier class]]) {
        return NO;
    }
    return [self isEqualToHymnIdentifier:(HYHymnIdentifier *)object];
}
- (BOOL)isEqualToHymnIdentifier:(HYHymnIdentifier *)aHymnIdentifier {
    if (self == aHymnIdentifier) {
        return YES;
    }
    if (![aHymnIdentifier isKindOfClass:[HYHymnIdentifier class]]) {
        return NO;
    }
    
    // note: intentionally omitting idNumber bc it's a local value
    
    return [self.hymnalCode isEqual:aHymnIdentifier.hymnalCode] && [self.number isEqual:aHymnIdentifier.number];
}
@end
