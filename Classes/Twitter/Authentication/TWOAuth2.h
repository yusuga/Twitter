//
//  TWOAuthAppOnly.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuth.h"
#import "TWAuthProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuth2 : TWAuth <TWAuthProtocol>

/**
 *  Authorized App Auth(Application-only)
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                  bearerAccessToken:(NSString *)bearerAccessToken;

/**
 *  Application-only Authentication
 *
 *  https://dev.twitter.com/oauth/application-only
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret;

@end
NS_ASSUME_NONNULL_END