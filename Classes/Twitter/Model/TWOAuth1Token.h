//
//  TWOAuthToken.h
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWOAuthToken.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuth1Token : TWOAuthToken

+ (TWOAuth1Token * __nullable)tokenWithAmpersandSeparatedAuthenticationString:(NSString *)authenticationString
                                                                  consumerKey:(NSString *)consumerKey
                                                               consumerSecret:(NSString *)consumerSecret
                                                                        error:(NSError ** __nullable)errorPtr;

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                  accessTokenSecret:(NSString *)accessTokenSecret
                             userID:(NSString * __nullable)userID
                         screenName:(NSString * __nullable)screenName;

- (NSString *)accessToken;
- (NSString *)accessTokenSecret;
@property (copy, nonatomic, readonly) NSString *userID;
@property (copy, nonatomic, readonly) NSString *screenName;

@end
NS_ASSUME_NONNULL_END