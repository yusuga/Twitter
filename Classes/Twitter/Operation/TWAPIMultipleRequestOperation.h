//
//  TWAPIMultipleOperation.h
//
//  Created by Yu Sugawara on 4/20/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "TWCancellableProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWAPIMultipleRequestOperation : NSObject <TWCancellableProtocol>

- (void)addOperation:(id<TWCancellableProtocol>)operation;

- (void)cancel;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

@end
NS_ASSUME_NONNULL_END