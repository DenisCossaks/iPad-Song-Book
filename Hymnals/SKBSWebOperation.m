//  Created by Stephen Bradley on 4/21/11.
//  Copyright 2011 SKB Software. All rights reserved.

#import "SKBSWebOperation.h"
#import "SKBSWebOperationQueue.h"


@interface SKBSWebOperation ()
- (void)signalNetworkThreadCompleted;
- (void)sendCompletionMessageToDelegateOnAppropriateThreadWithError:(NSError *)error;
- (void)sendCompletionMessageToDelegateWithError:(NSError *)error;
@end

@implementation SKBSWebOperation {
    NSURLConnection *connection;
    NSMutableURLRequest *request;
    NSURLResponse *response;
    NSThread *networkThread;
    NSRunLoop *networkRunLoop;
    NSCondition *networkRunLoopCreatedCondition;
    NSCondition *networkThreadCompletedCondition;
    NSMutableData *responseData;
    BOOL networkThreadShouldDie;
}

@synthesize delegate;
@synthesize userInfo;
@synthesize threadOnWhichToCallDelegateMethods;
@synthesize useFakeResponse;
@synthesize successBlock;
@synthesize failureBlock;

#pragma mark - Loading
- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)networkThreadMain {
    @autoreleasepool {
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture] interval:0 target:nil selector:NULL userInfo:nil repeats:NO];
        [networkRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        
        [networkRunLoopCreatedCondition lock];
        [networkRunLoopCreatedCondition signal];
        [networkRunLoopCreatedCondition unlock];
        
        do {
            NSDate *nowPlusTwo = [[NSDate alloc] initWithTimeIntervalSinceNow:2];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nowPlusTwo];
        }
        while (![NSThread currentThread].isCancelled && !networkThreadShouldDie);
        
        [timer invalidate];
    }
}

- (void)createConnection {
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)setupRequest:(NSMutableURLRequest * __autoreleasing *)theRequest {
    if (theRequest) {
        *theRequest = [[NSMutableURLRequest alloc] init];
        (*theRequest).cachePolicy = NSURLRequestUseProtocolCachePolicy;
        (*theRequest).timeoutInterval = 60;
        [*theRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    }
}

#pragma mark - Operation Methods
- (void)main {
    @autoreleasepool {
        if ([self isCancelled]) {
            return;
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        networkRunLoopCreatedCondition = [[NSCondition alloc] init];
        [networkRunLoopCreatedCondition lock];
        
        networkThreadShouldDie = NO;
        networkThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkThreadMain) object:nil];
        [networkThread start];
        
        networkThreadCompletedCondition = [[NSCondition alloc] init];
        responseData = [[NSMutableData alloc] init];
        response = nil;
        request = nil;
        
        NSMutableURLRequest *mutableRequest = nil;
        [self setupRequest:&mutableRequest];
        request = [mutableRequest copy];
        
        // Block until network thread's run loop has been created
        [networkRunLoopCreatedCondition wait];
        [networkRunLoopCreatedCondition unlock];
        
        [networkThreadCompletedCondition lock];
        
        if (useFakeResponse) {
            [self performSelector:@selector(generateFakeResponseData) onThread:networkThread withObject:nil waitUntilDone:NO];
        }
        else {
            [self performSelector:@selector(createConnection) onThread:networkThread withObject:nil waitUntilDone:YES];
            [connection start];
        }
        
        // Block until network thread completed
        [networkThreadCompletedCondition wait];
        [networkThreadCompletedCondition unlock];
        
        networkThreadShouldDie = YES;
        networkThread = nil;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}
#pragma mark - URL Connection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError {
    @autoreleasepool {
        [self sendCompletionMessageToDelegateOnAppropriateThreadWithError:theError];
        
        [self signalNetworkThreadCompleted];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)theResponse {
    responseData.length = 0;
    response = theResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @autoreleasepool {
        if ([self isCancelled]) {
            [self signalNetworkThreadCompleted];
            return;
        }
        
        NSError *error = nil;
        [self receivedResponse:response withData:responseData andError:&error];
        
        [self sendCompletionMessageToDelegateOnAppropriateThreadWithError:error];
        
        [self signalNetworkThreadCompleted];
    }
}

- (void)receivedResponse:(NSURLResponse *)theResponse withData:(NSMutableData *)theResponseData andError:(out NSError **)outError {
}

#pragma mark - Private Instance Methods
- (void)signalNetworkThreadCompleted {
    [networkThreadCompletedCondition lock];
    [networkThreadCompletedCondition signal];
    [networkThreadCompletedCondition unlock];
}

- (void)sendCompletionMessageToDelegateOnAppropriateThreadWithError:(NSError *)error {
    if (threadOnWhichToCallDelegateMethods) {
        [self performSelector:@selector(sendCompletionMessageToDelegateWithError:) onThread:threadOnWhichToCallDelegateMethods withObject:error waitUntilDone:NO];
    }
    else {
        [self performSelectorOnMainThread:@selector(sendCompletionMessageToDelegateWithError:) withObject:error waitUntilDone:NO];
    }
}

- (void)sendCompletionMessageToDelegateWithError:(NSError *)error {
    if (error) {
        if (failureBlock) {
            failureBlock(error);
        }
        [self.delegate webOperationFailed:self withError:error];
    }
    else {
        if (successBlock) {
            successBlock();
        }
        [self.delegate webOperationCompleted:self];
    }
}

@end
