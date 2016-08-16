//
//  TWAPIRequestOperationManager.h
//
//  Created by Yu Sugawara on 4/23/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "TWAPIRequestOperation.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWAPIRequestOperationManager : AFHTTPRequestOperationManager

@property (nonatomic) NSTimeInterval streamKeepAliveTime; // Defualt: 60.

- (TWAPIRequestOperation *)twitterAPIRequest:(NSURLRequest *)request
                              uploadProgress:(nullable void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                            downloadProgress:(nullable void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgress
                                      stream:(nullable void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                  completion:(void (^)(TWAPIRequestOperation *operation, id __nullable responseObject, NSError * __nullable error))completion;

+ (void)setAllowsPostErrorNotification:(BOOL)yesNo;
+ (BOOL)allowsPostErrorNotification;  // Default: NO

@end
NS_ASSUME_NONNULL_END