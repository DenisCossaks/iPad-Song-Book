//
//  HYHymnalInfoWebOperation.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/20/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "SKBSWebOperation.h"

@interface HYHymnalInfoWebOperation : SKBSWebOperation

@property (nonatomic, strong) NSArray *resultArray;

@property (nonatomic, strong) NSString *codeString;

- (id)initWithCode:(NSString*)code;

@end
