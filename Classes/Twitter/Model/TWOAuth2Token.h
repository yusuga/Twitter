//
//  TWOAuth2Token.h
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWOAuthToken.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuth2Token : TWOAuthToken

+ (TWOAuth2Token * __nullable)tokenWithDictionary:(NSDictionary *)dictionary
                                            error:(NSError ** __nullable)errorPtr;

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                  bearerAccessToken:(NSString *)bearerAccessToken;

- (NSString *)bearerAccessToken;
- (NSString *)tokenType;

- (BOOL)isValid;

@end
NS_ASSUME_NONNULL_END