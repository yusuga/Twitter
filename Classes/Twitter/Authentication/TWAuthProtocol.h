//
//  TWAuthProtocol.h
//
//  Created by Yu Sugawara on 4/13/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TWAPIRequestOperationManager;

NS_ASSUME_NONNULL_BEGIN
@protocol TWAuthProtocol <NSObject>

- (BOOL)authorized;
- (void)authorizeWithCompletion:(void (^)(TWAuth *auth, NSError * __nullable error))completion;

- (TWAPIRequestOperation * __nullable)sendRequestWithHTTPClient:(TWAPIRequestOperationManager *)httpClient
                                                     HTTPMethod:(NSString *)HTTPMethod
                                                            url:(NSURL *)url
                                                     parameters:(NSDictionary * __nullable)parameters
                                                    willRequest:(void (^ __nullable)(NSMutableURLRequest *request) )willRequest
                                                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                               downloadProgress:(void (^ __nullable)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) downloadProgress
                                                         stream:(void (^ __nullable)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type)) stream
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

@optional
- (NSString *)authName;

- (NSString * __nullable)consumerKey;
- (NSString * __nullable)consumerSecret;

- (NSString * __nullable)accessToken;
- (NSString * __nullable)accessTokenSecret;

- (TWOAuth1Token * __nullable)oauth1Token;

- (NSString * __nullable)bearerAccessToken;
- (TWOAuth2Token * __nullable)oauth2Token;

- (ACAccount * __nullable)account;

// Available only if initialized by the `+ authWithAccount:`
- (void)reverseAuthWithConsumerKey:(NSString *)consumerKey
                    consumerSecret:(NSString *)consumerSecret
                        completion:(void (^)(TWAuth *auth, TWOAuth1Token * __nullable authToken, NSError * __nullable error))completion;

// Available only in the AppAuth
- (void)invalidateOAuth2AccessTokenWithCompletion:(void(^)(TWAuth *auth, NSString * __nullable invalidatedBearerAccessToken, NSError * __nullable error))completion;

@end
NS_ASSUME_NONNULL_END