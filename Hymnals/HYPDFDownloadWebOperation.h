//
//  HYPDFDownloadWebOperation.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/20/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "SKBSWebOperation.h"

@interface HYPDFDownloadWebOperation : SKBSWebOperation

@property (nonatomic, strong) NSDictionary *infoDict;

- (id)initWithHymnInfo:(NSDictionary*)info;

@end
