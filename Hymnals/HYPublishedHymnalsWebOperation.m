//
//  HYPublishedHymnalsWebOperation.m
//  Hymnals
//
//  Created by Stephen Bradley on 5/11/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYPublishedHymnalsWebOperation.h"

@implementation HYPublishedHymnalsWebOperation

@synthesize resultArray;

- (void)setupRequest:(NSMutableURLRequest * __autoreleasing *)request {
    [super setupRequest:request];
    
    if (request && *request) {
        NSString *urlString = [NSString stringWithFormat:@"%@/HymnalsInfo.php?pubHymnals=1", kBaseURL];
        
        [(*request) setURL:[NSURL URLWithString:urlString]];
    }
}

- (void)receivedResponse:(NSURLResponse *)theResponse withData:(NSMutableData *)theResponseData andError:(out NSError **)outError {
    
	id responseObject = [NSJSONSerialization JSONObjectWithData:theResponseData options:NSJSONReadingMutableContainers error:outError];
	if (*outError) {
		return;
	}
	else if ([responseObject isKindOfClass:[NSArray class]]) {
		self.resultArray = responseObject;
	}
	else {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObject:@"'Result' matched 'Success', but 'Data' was not a array." forKey:@"NSLocalizedDescription"];
		*outError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:0 userInfo:errorDict];
	}
}

@end
