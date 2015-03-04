//  Created by Stephen Bradley on 4/21/11.
//  Copyright 2011 SKB Software. All rights reserved.

#import "SKBSWebOperationQueue.h"

@implementation SKBSWebOperationQueue

static SKBSWebOperationQueue *sharedWebOperationQueue;

+ (SKBSWebOperationQueue *)sharedWebOperationQueue {
	@synchronized(self)
	{
		if (!sharedWebOperationQueue) {
			sharedWebOperationQueue = [[SKBSWebOperationQueue alloc] init];
        }
	}
	return sharedWebOperationQueue;
}

- (id)init {
	if (self = [super init]) {
		[self setMaxConcurrentOperationCount:1];
	}
	return self;
}


@end
