//
//  HYHymnPDF.m
//  Hymnals
//
//  Created by christopher ngo on 11/20/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYHymnPDF.h"

@implementation HYHymnPDF

- (id)initWithFilename:(NSString *)filename hymnalCode:(NSString *)hymnalCode {
    if (self = [super init]) {
        self.filename = filename;
        self.hymnalCode = hymnalCode;
    }
    return self;
}

@end
