//
//  TWAuth.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "TWAPIRequestOperationManager.h"
#import "TWAPIRequestOperation.h"
#import "TWAuthModels.h"

@import Accounts;
@class TWAuth;

/**
 *  OAuth overview https://dev.twitter.com/oauth/overview
 *  OAuth FAQ https://dev.twitter.com/oauth/overview/faq
 *
 *  OAuth Authentication Flow v1.0a http://oauth.net/core/1.0/#anchor9
 */

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TWApplicationLaunchedWithURLNotification;
extern NSString * const TWAuthAuthenticationFailedErrorNotification;

@interface TWAuth : NSObject

#pragma mark - Auth
#pragma mark User Auth

/**
 *  Authorized User Auth
 */
+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                            accessToken:(NSString *)accessToken
                      accessTokenSecret:(NSString *)accessTokenSecret;

+ (instancetype)userAuthWithOAuth1Token:(TWOAuth1Token *)oauth1Token;

/**
 *  3-legged OAuth
 *
 *  https://dev.twitter.com/oauth/3-legged
 */
+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                          oauthCallback:(NSString *)oauthCallback;

+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                          oauthCallback:(NSString *)oauthCallback
          serviceProviderRequestHandler:(void (^ __nullable)(NSURL *url))requestHandler;

/**
 *  xAuth
 *
 *  https://dev.twitter.com/oauth/xauth
 */
+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                             screenName:(NSString *)screenName
                               password:(NSString *)password;

/**
 *  Twitter account in iOS
 *
 *  https://support.apple.com/en-us/HT202605
 */
+ (instancetype)userAuthWithAccount:(ACAccount *)account;

#pragma mark App Auth

/**
 *  Authorized App Auth
 */
+ (instancetype)appAuthWithConsumerKey:(NSString *)consumerKey
                        consumerSecret:(NSString *)consumerSecret
                     bearerAccessToken:(NSString *)bearerAccessToken;

+ (instancetype)appAuthWithOAuth2Token:(TWOAuth2Token *)oauth2Token;

/**
 *  Application-only authentication
 *
 *  https://dev.twitter.com/oauth/application-only
 */
+ (instancetype)appAuthWithConsumerKey:(NSString *)consumerKey
                        consumerSecret:(NSString *)consumerSecret;

#pragma mark - Authorize

- (BOOL)authorized;
- (void)authorizeWithCompletion:(void (^)(TWAuth *auth, NSError * __nullable error))completion;

+ (void)postAuthorizeNotificationWithCallbackURL:(NSURL *)url;

#pragma mark -

- (NSString *)authName;     // e.g. UserAuth-OAuth1.0, UserAuth-iOS, AppAuth-OAuth2.0

- (NSString * __nullable)consumerKey;
- (NSString * __nullable)consumerSecret;

- (NSString * __nullable)accessToken;
- (NSString * __nullable)accessTokenSecret;
- (TWOAuth1Token * __nullable)oauth1Token;

- (NSString * __nullable)bearerAccessToken;
- (TWOAuth2Token * __nullable)oauth2Token;

- (ACAccount * __nullable)account;

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *screenName;

- (NSString * __nullable)oauthCallback;

#pragma mark - API Request

@property (nonatomic, readonly) TWAPIRequestOperationManager *httpClient;

- (TWAPIRequestOperation * __nullable)sendRequestWithHTTPMethod:(NSString *)HTTPMethod
                                                  baseURLString:(NSString *)baseURLString
                                              relativeURLString:(NSString *)relativeURLString
                                                     parameters:(NSDictionary * __nullable)parameters
                                                    willRequest:(void (^ __nullable)(NSMutableURLRequest *request) )willRequest
                                                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                               downloadProgress:(void (^ __nullable)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) downloadProgress
                                                         stream:(void (^ __nullable)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type)) stream
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

/**
 *  https://dev.twitter.com/rest/reference/get/account/verify_credentials
 */
- (TWAPIRequestOperation *)getAccountVerifyCredentialsWithIncludeEntites:(BOOL)includeEntities
                                                              skipStatus:(BOOL)skipStatus
                                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

#pragma mark - Other Authorize

// Available only if initialized by the `+ userAuthWithAccount:`
- (void)reverseAuthWithConsumerKey:(NSString *)consumerKey
                    consumerSecret:(NSString *)consumerSecret
                        completion:(void (^)(TWAuth *auth, TWOAuth1Token * __nullable authToken, NSError * __nullable error))completion;

// Available only in the AppAuth
- (void)invalidateBearerAccessTokenWithCompletion:(void(^)(TWAuth *auth, NSString * __nullable invalidatedBearerAccessToken, NSError * __nullable error))completion;

#pragma mark -

- (NSString *)descriptionWithIndent:(NSUInteger)level;

@end
NS_ASSUME_NONNULL_END