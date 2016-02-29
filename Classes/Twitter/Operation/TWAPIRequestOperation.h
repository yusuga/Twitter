//
//  TWAPIRequestOperation.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperation.h>
#import "TWStreamParser.h"
#import "TWAPIRequestOperationProtocol.h"

/**
 *  Blank lines
 *  https://dev.twitter.com/streaming/overview/messages-types#blank_lines
 */

NS_ASSUME_NONNULL_BEGIN
@interface TWAPIRequestOperation : AFHTTPRequestOperation <TWAPIRequestOperationProtocol>

- (void)setStreamBlock:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))block
   streamKeepAliveTime:(NSTimeInterval)streamKeepAliveTime;
@property (nonatomic, readonly) NSTimeInterval streamKeepAliveTime;

@end
NS_ASSUME_NONNULL_END
