//
//  TWAuthObject.h
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TWAuthObject : NSObject <NSSecureCoding, NSCopying>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, readonly) NSDictionary *dictionary;

@end
NS_ASSUME_NONNULL_END