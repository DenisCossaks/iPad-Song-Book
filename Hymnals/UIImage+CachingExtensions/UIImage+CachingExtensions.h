//
//  Created by Stephen Bradley on 1/29/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

@interface UIImage(CachingExtensions)

+ (UIImage *)cachedImageNamed:(NSString*)name atURL:(NSURL*)url;

@end