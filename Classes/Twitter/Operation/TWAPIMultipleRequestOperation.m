//
//  TWAPIMultipleOperation.m
//
//  Created by Yu Sugawara on 4/20/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIMultipleRequestOperation.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWAPIMultipleRequestOperation ()

@property (nonatomic) NSMapTable *operations;
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;

@end

@implementation TWAPIMultipleRequestOperation

- (instancetype)init
{
    if (self = [super init]) {
        self.operations = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (void)addOperation:(AFHTTPRequestOperation * __nonnull)operation
{
    @synchronized(self.operations) {
        [self.operations setObject:operation forKey:operation];
    }
}

- (void)cancel
{
    self.cancelled = YES;
    
    @synchronized(self.operations) {
        for (AFHTTPRequestOperation *ope in self.operations) {
            [ope cancel];
        }
    }
}

@end
NS_ASSUME_NONNULL_END