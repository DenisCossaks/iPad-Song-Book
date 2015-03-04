//
//  HYHymnPDF.h
//  Hymnals
//
//  Created by christopher ngo on 11/20/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYHymnPDF : NSObject

@property (nonatomic, strong) NSString *filename; // PDF filename
@property (nonatomic, strong) NSString *hymnalCode;

- (id)initWithFilename:(NSString *)filename hymnalCode:(NSString *)hymnalCode;

@end
