//
//  HYHymnalInfoWebOperation.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/20/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYHymnalInfoWebOperation.h"

@implementation HYHymnalInfoWebOperation

@synthesize resultArray;
@synthesize codeString;

- (id)initWithCode:(NSString*)code {
	if(self = [super init]) {
		self.codeString = code;
	}
	return self;
}

- (void)setupRequest:(NSMutableURLRequest * __autoreleasing *)request {
    [super setupRequest:request];
    
    if (request && *request) {
        NSString *urlString = [NSString stringWithFormat:@"%@/HymnalsInfo.php?hymnal_code=%@", kBaseURL, codeString];
        //NSDictionary *postParamDict = [NSDictionary dictionaryWithObjectsAndKeys:codeString, @"hymnal_code", nil];
        
        [(*request) setURL:[NSURL URLWithString:urlString]];
        //[(*request) setHTTPMethod:@"POST"];
        //[(*request) setHTTPBody: [NSJSONSerialization dataWithJSONObject:postParamDict options:NSJSONWritingPrettyPrinted error:nil]];
        //[(*request) setValue:@"application/json" forHTTPHeaderField:@"content-type"];
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
