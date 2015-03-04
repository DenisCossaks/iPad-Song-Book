//  Created by Stephen Bradley on 4/21/11.
//  Copyright 2011 SKB Software. All rights reserved.

@class SKBSWebOperation, SKBSWebOperationQueue;
@protocol SKBSWebOperationDelegate<NSObject>
- (void)webOperationCompleted:(SKBSWebOperation*)webOp;
- (void)webOperationFailed:(SKBSWebOperation*)webOp withError:(NSError *)error;
@end

@interface SKBSWebOperation : NSOperation {
    NSThread *threadOnWhichToCallDelegateMethods;
    
    BOOL useFakeResponse;
    
    id __weak delegate;
    id userInfo;
}

@property (strong) NSThread *threadOnWhichToCallDelegateMethods;

@property (assign) BOOL useFakeResponse;

@property (weak) id<SKBSWebOperationDelegate> delegate;
@property (strong) id userInfo;

@property (copy) void (^successBlock)(void);
@property (copy) void (^failureBlock)(NSError * error);

- (void)networkThreadMain;
- (void)createConnection;
- (void)setupRequest:(NSMutableURLRequest * __autoreleasing *)request;
- (void)receivedResponse:(NSURLResponse *)theResponse withData:(NSMutableData *)theResponseData andError:(out NSError **)outError;

@end
