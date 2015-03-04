//
//  HYPDFDownloadWebOperation.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/20/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYPDFDownloadWebOperation.h"
#import <sys/xattr.h>

@implementation HYPDFDownloadWebOperation

@synthesize infoDict;

- (id)initWithHymnInfo:(NSDictionary*)info {
	if(self = [super init]) {
		self.infoDict = info;
	}
	return self;
}

- (void)setupRequest:(NSMutableURLRequest * __autoreleasing *)request {
    [super setupRequest:request];
    
    if (request && *request) {
        NSString *urlString = [NSString stringWithFormat:@"http://services.giamusic.com/hymnals_pdfs/%@", [infoDict objectForKey:@"pdf_file"]];
        (*request).URL = [NSURL URLWithString:urlString];
    }
}

- (void)receivedResponse:(NSURLResponse *)theResponse withData:(NSMutableData *)theResponseData andError:(out NSError **)outError {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [infoDict objectForKey:@"pdf_file"]];
    
	if (*outError) {
		return;
	}
	else if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:theResponseData attributes:nil]){
        NSError *error;
        [[NSURL fileURLWithPath:filePath] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if(error) {
            NSLog(@"NSURLIsExcludedFromBackupKey error: %@", [error description]);
        }
    }
	else {
        NSLog(@"Error saving file: %@", [infoDict objectForKey:@"pdf_file"]);
		//???
        NSDictionary *errorDict = [NSDictionary dictionaryWithObject:@"'Result' matched 'Success', but 'Data' was not a array." forKey:@"NSLocalizedDescription"];
		*outError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:0 userInfo:errorDict];
	}
}

@end
