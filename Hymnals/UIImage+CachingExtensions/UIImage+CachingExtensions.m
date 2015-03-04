//
//  Created by Stephen Bradley on 1/29/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "UIImage+CachingExtensions.h"

@implementation UIImage(CachingExtensions)

+ (UIImage *)cachedImageNamed:(NSString*)name atURL:(NSURL*)url {
    NSString *docDirectoryPathString = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    NSError *theError;
    UIImage *image;
    
    if ([fileManger fileExistsAtPath:[docDirectoryPathString stringByAppendingString:[NSString stringWithFormat:@"/%@", name]]]) {
        image = [UIImage imageWithContentsOfFile:[docDirectoryPathString stringByAppendingString:[NSString stringWithFormat:@"/%@", name]]];
    }
    else {
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:imageData];
        
        if(image) {
            BOOL isComplete = [imageData writeToFile:[docDirectoryPathString stringByAppendingFormat:@"/%@", name] options:NSDataWritingAtomic  error:&theError];
            
            if (!isComplete && theError) {
                NSLog(@"Image save error: %@", theError);
            }
        }
        else {
            NSLog(@"Image download error from URL: %@", url);
        }
    }
    
    return image;
}

@end