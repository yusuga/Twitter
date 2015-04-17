//
//  TWOAuth.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWOAuth1.h"
#import "TWAuthModels.h"
#import "TWConstants.h"
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"
#import <OAuthCore/OAuthCore.h>
#import <OAuthCore/OAuth+Additions.h>

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuth1 ()

@property (copy, nonatomic) NSString *oauthCallback;
@property (copy, nonatomic) void(^serviceProviderRequestHandler)(NSURL *url);

@property (copy, nonatomic) NSString *consumerKey;
@property (copy, nonatomic) NSString *consumerSecret;

@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *accessTokenSecret;
@property (copy, nonatomic) NSString *password;

@property (nonatomic) TWOAuth1Token *authToken;

@property (nonatomic, nullable) id applicationLaunchNotificationObserver;

@end

@implementation TWOAuth1

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                  accessTokenSecret:(NSString *)accessTokenSecret
{
    return [self initWithConsumerKey:consumerKey
                      consumerSecret:consumerSecret
                         accessToken:accessToken
                   accessTokenSecret:accessTokenSecret
                          screenName:nil
                            password:nil];
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                      oauthCallback:(NSString *)oauthCallback
{
    TWOAuth1 *auth = [self initWithConsumerKey:consumerKey
                                consumerSecret:consumerSecret
                                   accessToken:nil
                             accessTokenSecret:nil
                                    screenName:nil
                                      password:nil];
    auth.oauthCallback = oauthCallback;
    return auth;
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                      oauthCallback:(NSString *)oauthCallback
      serviceProviderRequestHandler:(void (^ __nullable)(NSURL *url))requestHandler
{
    TWOAuth1 *auth = [self initWithConsumerKey:consumerKey
                                consumerSecret:consumerSecret
                                 oauthCallback:oauthCallback];
    auth.serviceProviderRequestHandler = requestHandler;
    return auth;
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                         screenName:(NSString *)screenName
                           password:(NSString *)password
{
    return [self initWithConsumerKey:consumerKey
                      consumerSecret:consumerSecret
                         accessToken:nil
                   accessTokenSecret:nil
                          screenName:screenName
                            password:password];
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
{
    return [self initWithConsumerKey:consumerKey
                      consumerSecret:consumerSecret
                         accessToken:nil
                   accessTokenSecret:nil
                          screenName:nil
                            password:nil];
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(nullable NSString *)accessToken
                  accessTokenSecret:(nullable NSString *)accessTokenSecret
                         screenName:(nullable NSString *)screenName
                           password:(nullable NSString *)password
{
    if (self = [super init]) {
        self.consumerKey = consumerKey;
        self.consumerSecret = consumerSecret;
        self.accessToken = accessToken;
        self.accessTokenSecret = accessTokenSecret;
        self.screenName = screenName;
        self.password = password;
    }
    return self;
}

- (void)dealloc
{
    self.applicationLaunchNotificationObserver = nil;
}

- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSMutableString *desc = [super descriptionWithIndent:level].mutableCopy;
    
    NSString *indent = tw_indent(level + 1);
    
    [desc appendFormat:@"%@userID = %@;\n", indent, [self userID]];
    [desc appendFormat:@"%@screenName = %@;\n", indent, [self screenName]];
    [desc appendFormat:@"%@oauth1Token = %@;\n", indent, [[self oauth1Token] descriptionWithIndent:level + 1]];
    
    [desc appendFormat:@"%@}", tw_indent(level)];
    
    return [NSString stringWithString:desc];
}

#pragma mark - TwitterAuthProtocol
#pragma mark @required

- (BOOL)authorized
{
    return self.accessToken && self.accessTokenSecret;
}

- (void)authorizeWithCompletion:(void (^)(TWAuth *auth, NSError * __nullable error))completion
{
    self.applicationLaunchNotificationObserver = nil;
    
    if (self.accessToken && self.accessTokenSecret) {
        [self getAccountVerifyCredentialsWithIncludeEntites:YES
                                                 skipStatus:YES
                                                 completion:^(TWAPIRequestOperation *operation, NSDictionary *user, NSError *error)
         {
             completion(self, error);
         }];
    } else if (self.screenName && self.password) {
        [self acquireXAuthAccessTokenWithCompletion:completion];
    } else {
        [self acquireOAuthRequestTokenWithOAuthCallback:self.oauthCallback
                                             forceLogin:YES
                                             screenName:nil
                                             completion:^(TWAuth *auth, NSURL *url, NSError *error)
         {
             if (error) {
                 completion(self, error);
                 return ;
             }
             
             self.applicationLaunchNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:TWApplicationLaunchedWithURLNotification
                                                                                                            object:nil
                                                                                                             queue:[NSOperationQueue mainQueue]
                                                                                                        usingBlock:^(NSNotification *note)
                                                           {
                                                               self.applicationLaunchNotificationObserver = nil;
                                                               NSURL *url = note.object;
                                                               NSParameterAssert([url isKindOfClass:[NSURL class]]);
                                                               [self acquireOAuthAccessTokenWithRequestTokenCallbackURL:url
                                                                                                             completion:completion];
                                                           }];
             
             if (self.serviceProviderRequestHandler) {
                 self.serviceProviderRequestHandler(url);
             } else {
                 [[UIApplication sharedApplication] openURL:url];
             }
         }];
    }
}

- (TWAPIRequestOperation * __nullable)sendRequestWithHTTPClient:(TWAPIRequestOperationManager *)httpClient
                                                     HTTPMethod:(NSString *)HTTPMethod
                                                            url:(NSURL *)url
                                                     parameters:(NSDictionary * __nullable)parameters
                                                    willRequest:(void (^ __nullable)(NSMutableURLRequest *request) )willRequest
                                                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                               downloadProgress:(void (^ __nullable)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) downloadProgress
                                                         stream:(void (^ __nullable)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type)) stream
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    TWPostData *postData = parameters[kTWPostData];
    NSDictionary *requestParams;
    if (postData) {
        NSMutableDictionary *mParams = [parameters mutableCopy];
        [mParams removeObjectForKey:kTWPostData];
        requestParams = [NSDictionary dictionaryWithDictionary:mParams];
    } else {
        requestParams = parameters;
    }
    
    /*---*/
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request;
    
    if (postData) {
        request = [httpClient.requestSerializer multipartFormRequestWithMethod:HTTPMethod
                                                                     URLString:[url absoluteString]
                                                                    parameters:requestParams
                                                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                         [formData appendPartWithFileData:postData.data
                                                                                     name:postData.name
                                                                                 fileName:postData.fileName
                                                                                 mimeType:postData.mimeType];
                                                     } error:&serializationError];
    } else {
        request =[[httpClient.requestSerializer requestWithMethod:HTTPMethod
                                                        URLString:[url absoluteString]
                                                       parameters:requestParams
                                                            error:&serializationError] mutableCopy];
    }
    
    if (serializationError) {
        if (completion) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(httpClient.completionQueue ?: dispatch_get_main_queue(), ^{
                completion(nil, nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        return nil;
    }
    
    /**
     *  Note: When a accessToken/Secret does not exist, it becomes the AppAuth.
     */
    if (self.accessToken && self.accessTokenSecret) {
        [request setValue:OAuthorizationHeaderWithCallback(request.URL,
                                                           request.HTTPMethod,
                                                           request.HTTPBody,
                                                           self.consumerKey,
                                                           self.consumerSecret,
                                                           self.accessToken,
                                                           self.accessTokenSecret,
                                                           nil)
       forHTTPHeaderField:@"Authorization"];
    }
    
    if (willRequest) willRequest(request);
    
    return [httpClient twitterAPIRequest:[request copy]
                          uploadProgress:uploadProgress
                        downloadProgress:downloadProgress
                                  stream:stream
                              completion:completion];
}

#pragma mark @optional

- (NSString * __nonnull)authName
{
    return @"UserAuth-OAuth1.0";
}

- (TWOAuth1Token * __nullable)oauth1Token
{
    TWOAuth1Token *token = [[TWOAuth1Token alloc] initWithConsumerKey:self.consumerKey
                                                       consumerSecret:self.consumerSecret
                                                          accessToken:self.accessToken
                                                    accessTokenSecret:self.accessTokenSecret
                                                               userID:self.userID
                                                           screenName:self.screenName];
    return token.isValid ? token : nil;
}

#pragma mark - Auth
#pragma mark OAuth - Requet token

- (void)acquireOAuthRequestTokenWithOAuthCallback:(nullable NSString *)oauthCallback
                                       forceLogin:(BOOL)forceLogin
                                       screenName:(nullable NSString *)screenName
                                       completion:(void(^)(TWAuth *auth, NSURL * __nullable url, NSError * __nullable error))completion
{
    /**
     *  https://dev.twitter.com/oauth/reference/post/oauth/request_token
     */
    
    [self postRequestTokenWithParameters:nil
                           oauthCallback:oauthCallback ?: @"oob" // out of band
                              completion:^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error)
     {
         if (error) {
             completion(self, nil, error);
             return ;
         }
         
         /**
          *  oauth_token=REQUEST_TOKEN&oauth_token_secret=REQUEST_TOKEN_SECRET&oauth_callback_confirmed=true
          */
         
         NSMutableDictionary *queries = [NSURL ab_parseURLQueryString:operation.responseString].mutableCopy;
         if(forceLogin) queries[@"force_login"] = @"1";
         if(screenName) queries[@"screen_name"] = screenName;
         
         NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[queries count]];
         [queries enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
             [parameters addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
         }];
         
         NSString *parameterString = [parameters componentsJoinedByString:@"&"];
         NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authenticate?%@", parameterString];
         
         completion(self, [NSURL URLWithString:urlString], nil);
     }];
}

#pragma mark OAuth - Access token

- (void)acquireOAuthAccessTokenWithRequestTokenCallbackURL:(NSURL *)callbackURL
                                                completion:(void (^)(TWAuth *auth, NSError * __nullable error))completion
{
    NSError *initError = nil;
    TWRequestToken *requestToken = [TWRequestToken tokenWithAmpersandSeparatedRequestTokenString:callbackURL.query
                                                                                           error:&initError];
    if (initError) {
        completion(self, initError);
        return ;
    }
    
    [self acquireOAuthAccessTokenWithRequestToken:requestToken
                                       completion:completion];
}

- (void)acquireOAuthAccessTokenWithRequestToken:(TWRequestToken *)requestToken
                                     completion:(void (^)(TWAuth *auth, NSError * __nullable error))completion
{
    [self postAccessTokenWithParameters:@{@"oauth_verifier" : requestToken.oauthVerifier}
                           requestToken:requestToken.requestToken
                             completion:^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error) {
                                 completion(self, error);
                             }];
}

#pragma mark xAuth - Access token

- (void)acquireXAuthAccessTokenWithCompletion:(void (^)(TWOAuth1 *auth, NSError * __nullable error))completion
{
    if (!self.screenName || !self.password) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self, [NSError tw_badArgumentErrorWithFailureReason:@"screenName or userID is nil."]);
        });
        return ;
    }
    
    [self postAccessTokenWithParameters:@{@"x_auth_username" : self.screenName,
                                          @"x_auth_password" : self.password,
                                          @"x_auth_mode"     : @"client_auth"}
                           requestToken:nil
                             completion:^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error) {
                                 completion(self, error);
                             }];
}

#pragma mark ReverseAuth - Request token

- (void)acquireReverseAuthRequestTokenWithCompletion:(void(^)(TWAuth *auth, NSString * __nullable reverseAuthParametersString, NSError * __nullable error))completion
{
    [self postRequestTokenWithParameters:@{@"x_auth_mode" : @"reverse_auth"}
                           oauthCallback:nil
                              completion:^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error)
     {
         completion(self, error ? nil : operation.responseString, error);
     }];
}

#pragma mark - Request

- (TWAPIRequestOperation *)postRequestTokenWithParameters:(nullable NSDictionary *)parameters
                                            oauthCallback:(nullable NSString *)oauthCallback
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    return [self sendRequestWithHTTPMethod:kTWHTTPMethodPOST
                             baseURLString:kTWBaseURLString_API
                         relativeURLString:@"oauth/request_token"
                                parameters:parameters
                               willRequest:^(NSMutableURLRequest * __nonnull request) {
                                   [request setValue:OAuthorizationHeaderWithCallback(request.URL,
                                                                                      request.HTTPMethod,
                                                                                      request.HTTPBody,
                                                                                      self.consumerKey,
                                                                                      self.consumerSecret,
                                                                                      self.accessToken,
                                                                                      self.accessTokenSecret,
                                                                                      oauthCallback)
                                  forHTTPHeaderField:@"Authorization"];
                               }
                            uploadProgress:nil
                          downloadProgress:nil
                                    stream:nil
                                completion:completion];
}

- (TWAPIRequestOperation *)postAccessTokenWithParameters:(NSDictionary *)parameters
                                            requestToken:(nullable NSString *)requestToken
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    return [self sendRequestWithHTTPMethod:kTWHTTPMethodPOST
                             baseURLString:kTWBaseURLString_API
                         relativeURLString:@"oauth/access_token"
                                parameters:parameters
                               willRequest:^(NSMutableURLRequest * __nonnull request) {
                                   [request setValue:OAuthorizationHeaderWithCallback(request.URL,
                                                                                      request.HTTPMethod,
                                                                                      request.HTTPBody,
                                                                                      self.consumerKey,
                                                                                      self.consumerSecret,
                                                                                      requestToken,
                                                                                      nil,
                                                                                      nil)
                                  forHTTPHeaderField:@"Authorization"];
                               }
                            uploadProgress:nil
                          downloadProgress:nil
                                    stream:nil
                                completion:^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error) {
                                    if (error) {
                                        completion(operation, nil, error);
                                        return ;
                                    }
                                    
                                    NSError *initError = nil;
                                    TWOAuth1Token *authToken = [TWOAuth1Token tokenWithAmpersandSeparatedAuthenticationString:operation.responseString
                                                                                                                  consumerKey:self.consumerKey
                                                                                                               consumerSecret:self.consumerSecret
                                                                                                                        error:&initError];
                                    if (initError) {
                                        completion(operation, nil, initError);
                                        return ;
                                    }
                                    
                                    self.userID = authToken.userID;
                                    self.screenName = authToken.screenName;
                                    self.accessToken = authToken.accessToken;
                                    self.accessTokenSecret = authToken.accessTokenSecret;
                                    
                                    completion(operation, self, initError);
                                }];
}

#pragma mark - Property

- (void)setApplicationLaunchNotificationObserver:(id __nullable)applicationLaunchNotificationObserver
{
    if (_applicationLaunchNotificationObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_applicationLaunchNotificationObserver];
    }
    _applicationLaunchNotificationObserver = applicationLaunchNotificationObserver;
}

@end
NS_ASSUME_NONNULL_END