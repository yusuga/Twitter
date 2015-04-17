//
//  TWOAuthToken.h
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuthObject.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuthToken : TWAuthObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                       consumerKey:(NSString *)consumerKey
                    consumerSecret:(NSString *)consumerSecret;

@property (copy, nonatomic, readonly) NSString *consumerKey;
@property (copy, nonatomic, readonly) NSString *consumerSecret;

- (BOOL)isValid;

- (NSString *)descriptionWithIndent:(NSUInteger)level;

@end
NS_ASSUME_NONNULL_END