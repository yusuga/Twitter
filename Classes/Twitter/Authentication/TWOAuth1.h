//
//  TWOAuth.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuth.h"
#import "TWAuthProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuth1 : TWAuth <TWAuthProtocol>

/**
 *  Authorized OAuth
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                  accessTokenSecret:(NSString *)accessTokenSecret;

/**
 *  3-legged OAuth
 *
 *  https://dev.twitter.com/oauth/3-legged
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                      oauthCallback:(NSString *)oauthCallback;

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                      oauthCallback:(NSString *)oauthCallback
      serviceProviderRequestHandler:(void (^ __nullable)(NSURL *url))requestHandler;

/**
 *  xAuth
 *
 *  https://dev.twitter.com/oauth/xauth
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                         screenName:(NSString *)screenName
                           password:(NSString *)password;

/**
 *  TODO: Not working
 *
 *  PIN-Based OAuth
 *
 *  https://dev.twitter.com/oauth/pin-based
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret;

#pragma mark -

- (NSString *)oauthCallback;

#pragma mark - Auth

- (void)acquireReverseAuthRequestTokenWithCompletion:(void(^)(TWAuth *auth, NSString * __nullable reverseAuthParametersString, NSError * __nullable error))completion;

@end
NS_ASSUME_NONNULL_END