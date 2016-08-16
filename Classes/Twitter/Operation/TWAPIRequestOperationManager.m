//
//  TWAPIRequestOperationManager.m
//
//  Created by Yu Sugawara on 4/23/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIRequestOperationManager.h"
#import "TWUtil.h"
#import "TWConstants.h"

NS_ASSUME_NONNULL_BEGIN
@implementation TWAPIRequestOperationManager

- (instancetype)initWithBaseURL:(nullable NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        self.streamKeepAliveTime = 60.;
        
        [self.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error)
         {
             return [TWUtil percentEscapedURLQueryWithParameters:parameters];
         }];
    }
    return self;
}

- (TWAPIRequestOperation *)twitterAPIRequest:(NSURLRequest *)request
                              uploadProgress:(nullable void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                            downloadProgress:(nullable void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgress
                                      stream:(nullable void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                  completion:(void (^)(TWAPIRequestOperation *operation, id __nullable responseObject, NSError * __nullable error))completion
{
    __weak typeof(self) wself = self;
    TWAPIRequestOperation *operation = [[TWAPIRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    [operation setUploadProgressBlock:uploadProgress];
    [operation setDownloadProgressBlock:downloadProgress];
    [operation setStreamBlock:stream streamKeepAliveTime:self.streamKeepAliveTime];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion((id)operation, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion((id)operation, nil, error);
        
        if (wself.allowsPostErrorNotification && !operation.isCancelled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TWAPIErrorNotification
                                                                object:error
                                                              userInfo:operation ? @{@"operation" : operation} : nil];
        }
    }];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;
    
    [self.operationQueue addOperation:operation];
    return operation;
}

#pragma mark - NSSecureCoding

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    self.streamKeepAliveTime = [decoder decodeDoubleForKey:NSStringFromSelector(@selector(streamKeepAliveTime))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeDouble:self.streamKeepAliveTime forKey:NSStringFromSelector(@selector(streamKeepAliveTime))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone
{
    TWAPIRequestOperationManager *HTTPClient = [super copyWithZone:zone];
    
    HTTPClient.streamKeepAliveTime = self.streamKeepAliveTime;
    
    return HTTPClient;
}

@end
NS_ASSUME_NONNULL_END
