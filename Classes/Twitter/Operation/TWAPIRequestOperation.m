//
//  TWAPIOperation.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIRequestOperation.h"

NS_ASSUME_NONNULL_BEGIN

static inline void tw_dispatch_main_sync_safe(void(^block)(void))
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

typedef void(^STTwitterOperationStreamBlock)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type);

@interface TWAPIRequestOperation ()

@property (copy, nonatomic) STTwitterOperationStreamBlock stream;
@property (nonatomic) TWStreamParser *streamParser;
@property (nonatomic, readwrite) NSTimeInterval streamKeepAliveTime;

@end

@implementation TWAPIRequestOperation

- (void)setStreamBlock:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))block
   streamKeepAliveTime:(NSTimeInterval)streamKeepAliveTime
{
    if (block) {
        self.stream = block;
        self.streamKeepAliveTime = streamKeepAliveTime;
        self.streamParser = [[TWStreamParser alloc] init];
        
        [self resetKeepAlive];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [super connection:connection didReceiveData:data];
    
    if (self.streamParser) {
        [self resetKeepAlive];
        
        [self.streamParser parseWithStreamData:data parsed:^(NSDictionary * json, TWStreamJSONType type) {
            tw_dispatch_main_sync_safe(^{
                if (self.stream) {
                    self.stream(self, json, type);
                }
            });
        }];
    }
}

#pragma mark - Stream keep-alive

- (void)timeout
{
    tw_dispatch_main_sync_safe(^{
        if (self.stream) {
            self.stream(self, @{@"timeout" : [NSString stringWithFormat:@"streamKeepAliveTime = %.1f", self.streamKeepAliveTime]}, TWStreamJSONTypeTimeout);
        }
        if (!self.isCancelled) {
            [self resetKeepAlive];
        }
    });
}

- (void)resetKeepAlive
{
    tw_dispatch_main_sync_safe(^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
        [self performSelector:@selector(timeout) withObject:nil afterDelay:self.streamKeepAliveTime];
    });
}

#pragma mark -

- (void)cancel
{
    [super cancel];
    
    tw_dispatch_main_sync_safe(^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    });
}

#pragma mark - NSSecureCoding

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    self.streamParser = [NSKeyedUnarchiver unarchiveObjectWithData:[decoder decodeObjectOfClass:[TWStreamParser class] forKey:NSStringFromSelector(@selector(streamParser))]];
    self.streamKeepAliveTime = [decoder decodeDoubleForKey:NSStringFromSelector(@selector(streamKeepAliveTime))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.streamParser] forKey:NSStringFromSelector(@selector(streamParser))];
    [coder encodeDouble:self.streamKeepAliveTime forKey:NSStringFromSelector(@selector(streamKeepAliveTime))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone
{
    TWAPIRequestOperation *operation = [super copyWithZone:zone];
    
    operation.stream = self.stream;
    operation.streamParser = [self.streamParser copyWithZone:zone];
    operation.streamKeepAliveTime = self.streamKeepAliveTime;
    
    return operation;
}

@end
NS_ASSUME_NONNULL_END
