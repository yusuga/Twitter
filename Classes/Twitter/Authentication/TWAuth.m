//
//  TWAuth.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuth.h"
#import "TWOAuth1.h"
#import "TWAuthOS.h"
#import "TWOAuth2.h"
#import "TWAuthProtocol.h"
#import "TWAPIResponseSerializer.h"
#import "TWConstants.h"
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"
#import <OAuthCore/OAuth+Additions.h>

NS_ASSUME_NONNULL_BEGIN

NSString * const TWApplicationLaunchedWithURLNotification = @"TWApplicationLaunchedWithURLNotification";
NSString * const TWAuthAuthenticationFailedErrorNotification = @"TWAuthAuthenticationFailedErrorNotification";

@interface TWAuth () <TWAuthProtocol>

@property (nonatomic, readwrite) TWAPIRequestOperationManager *httpClient;

@end

@implementation TWAuth

#pragma mark - Initial
#pragma mark TWOAuth1

+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                            accessToken:(NSString *)accessToken
                      accessTokenSecret:(NSString *)accessTokenSecret
{
    return [[TWOAuth1 alloc] initWithConsumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                     accessToken:accessToken
                               accessTokenSecret:accessTokenSecret];
}

+ (instancetype)userAuthWithOAuth1Token:(TWOAuth1Token *)oauth1Token
{
    TWOAuth1 *auth = [[TWOAuth1 alloc] initWithConsumerKey:oauth1Token.consumerKey
                                            consumerSecret:oauth1Token.consumerSecret
                                               accessToken:oauth1Token.accessToken
                                         accessTokenSecret:oauth1Token.accessTokenSecret];
    auth.userID = oauth1Token.userID;
    auth.screenName = oauth1Token.screenName;
    return auth;
}


+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                          oauthCallback:(NSString *)oauthCallback
{
    return [[TWOAuth1 alloc] initWithConsumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                   oauthCallback:oauthCallback];
}

+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                          oauthCallback:(NSString *)oauthCallback
          serviceProviderRequestHandler:(void (^ __nullable)(NSURL *url))requestHandler
{
    return [[TWOAuth1 alloc] initWithConsumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                   oauthCallback:oauthCallback
                   serviceProviderRequestHandler:requestHandler];
}

+ (instancetype)userAuthWithConsumerKey:(NSString *)consumerKey
                         consumerSecret:(NSString *)consumerSecret
                             screenName:(NSString *)screenName
                               password:(NSString *)password
{
    return [[TWOAuth1 alloc] initWithConsumerKey:consumerKey
                                  consumerSecret:consumerSecret
                                      screenName:screenName
                                        password:password];
}

#pragma mark TWAuthOS

+ (instancetype)userAuthWithAccount:(ACAccount *)account
{
    return [[TWAuthOS alloc] initWithAccount:account];
}

#pragma mark TWOAuth2

+ (instancetype)appAuthWithConsumerKey:(NSString *)consumerKey
                        consumerSecret:(NSString *)consumerSecret
                     bearerAccessToken:(NSString *)bearerAccessToken
{
    return [[TWOAuth2 alloc] initWithConsumerKey:consumerKey
                                  consumerSecret:consumerSecret
                               bearerAccessToken:bearerAccessToken];
}

+ (instancetype)appAuthWithOAuth2Token:(TWOAuth2Token *)oauth2Token
{
    return [self appAuthWithConsumerKey:oauth2Token.consumerKey
                         consumerSecret:oauth2Token.consumerSecret
                      bearerAccessToken:oauth2Token.bearerAccessToken];
}

+ (instancetype)appAuthWithConsumerKey:(NSString *)consumerKey
                        consumerSecret:(NSString *)consumerSecret
{
    return [[TWOAuth2 alloc] initWithConsumerKey:consumerKey
                                  consumerSecret:consumerSecret];
}

#pragma mark - Life cycle

- (instancetype)init
{
    if (self = [super init]) {
        TWAPIRequestOperationManager *client = [TWAPIRequestOperationManager manager];
        client.operationQueue = [[self class] twitterOerationQueue];
        
        client.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        TWAPIResponseSerializer *responseSerializer = [TWAPIResponseSerializer serializer];
        responseSerializer.removesKeysWithNullValues = YES;
        client.responseSerializer = responseSerializer;
        
        self.httpClient = client;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
}

#pragma mark - Operation

+ (NSOperationQueue*)twitterOerationQueue
{
    static NSOperationQueue *__operationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __operationQueue = [[NSOperationQueue alloc] init];
        [__operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    return __operationQueue;
}

#pragma mark - Auth

+ (void)postAuthorizeNotificationWithCallbackURL:(NSURL * __nonnull)url
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TWApplicationLaunchedWithURLNotification
                                                        object:url
                                                      userInfo:nil];
}

#pragma mark - API Request

- (TWAPIRequestOperation * __nullable)sendRequestWithHTTPMethod:(NSString *)HTTPMethod
                                                  baseURLString:(NSString *)baseURLString
                                              relativeURLString:(NSString *)relativeURLString
                                                     parameters:(NSDictionary * __nullable)parameters
                                                    willRequest:(void (^ __nullable)(NSMutableURLRequest *request) )willRequest
                                                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                               downloadProgress:(void (^ __nullable)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) downloadProgress
                                                         stream:(void (^ __nullable)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type)) stream
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    return [self sendRequestWithHTTPClient:[self httpClient]
                                HTTPMethod:HTTPMethod
                                       url:[NSURL URLWithString:relativeURLString relativeToURL:[NSURL URLWithString:baseURLString]]
                                parameters:parameters
                               willRequest:willRequest
                            uploadProgress:uploadProgress
                          downloadProgress:downloadProgress
                                    stream:stream
                                completion:^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error) {
                                    NSError *twitterError = [NSError tw_localizedAPIErrorWithHTTPOperation:operation
                                                                                           underlyingError:error
                                                                                                screenName:self.screenName];
                                    
                                    if ([twitterError.domain isEqualToString:TWAPIErrorDomain] &&
                                        [[NSError tw_authenticationFailedErrorCodes] containsObject:@(twitterError.code)])
                                    {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:TWAuthAuthenticationFailedErrorNotification
                                                                                            object:self
                                                                                          userInfo:@{@"error" : twitterError}];
                                    }
                                    
                                    completion(operation, responseObject, twitterError);
                                }];
}

- (TWAPIRequestOperation *)getAccountVerifyCredentialsWithIncludeEntites:(BOOL)includeEntities
                                                              skipStatus:(BOOL)skipStatus
                                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if(includeEntities) params[@"include_entities"] = includeEntities ? @"1" : @"0";
    if(skipStatus) params[@"skip_status"] = skipStatus ? @"1" : @"0";
    
    return [self sendRequestWithHTTPMethod:kTWHTTPMethodGET
                             baseURLString:kTWBaseURLString_API_1_1
                         relativeURLString:@"account/verify_credentials.json"
                                parameters:[NSDictionary dictionaryWithDictionary:params]
                               willRequest:nil
                            uploadProgress:nil
                          downloadProgress:nil
                                    stream:nil
                                completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable json, NSError * __nullable error) {
                                    if (error) {
                                        completion(operation, nil, error);
                                        return ;
                                    }
                                    
                                    NSString *idStr = json[@"id_str"];
                                    NSString *screenName = json[@"screen_name"];
                                    
                                    if (!idStr || !screenName) {
                                        completion(operation, nil, [NSError tw_parseFailedErrorWithUnderlyingString:[NSString stringWithFormat:@"json = %@", json]]);
                                        return ;
                                    }
                                    
                                    self.userID = idStr;
                                    self.screenName = screenName;
                                    
                                    completion(operation, json, nil);
                                }];
}

#pragma mark - TwitterAuthProtocol
#pragma mark @required

- (BOOL)authorized { abort(); }
- (void)authorizeWithCompletion:(void (^)(TWAuth *auth, NSError * __nullable error))completion { abort(); }

- (TWAPIRequestOperation * __nullable)sendRequestWithHTTPClient:(TWAPIRequestOperationManager *)httpClient
                                                     HTTPMethod:(NSString *)HTTPMethod
                                                            url:(NSURL *)url
                                                     parameters:(NSDictionary * __nullable)parameters
                                                    willRequest:(void (^ __nullable)(NSMutableURLRequest *request) )willRequest
                                                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                               downloadProgress:(void (^ __nullable)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) downloadProgress
                                                         stream:(void (^ __nullable)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type)) stream
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion { abort(); }

#pragma mark @optional

- (NSString * __nonnull)authName
{
    return nil;
}

- (NSString * __nullable)consumerKey
{
    return nil;
}

- (NSString * __nullable)consumerSecret
{
    return nil;
}

- (NSString * __nullable)accessToken
{
    return nil;
}

- (NSString * __nullable)accessTokenSecret
{
    return nil;
}

- (TWOAuth1Token * __nullable)oauth1Token
{
    return nil;
}

- (NSString * __nullable)bearerAccessToken
{
    return nil;
}

- (TWOAuth2Token * __nullable)oauth2Token
{
    return nil;
}

- (ACAccount * __nullable)account
{
    return nil;
}

- (NSString * __nullable)oauthCallback
{
    return nil;
}

- (void)reverseAuthWithConsumerKey:(NSString *)consumerKey
                    consumerSecret:(NSString *)consumerSecret
                        completion:(void (^)(TWAuth *auth, TWOAuth1Token * __nullable authToken, NSError * __nullable error))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(self, nil, [NSError tw_unsupportedAuthenticationErrorWithDescription:@"Reverse Auth is not supported"
                                                                          failureReason:@"Not initialized in an account."]);
    });
}

- (void)invalidateBearerAccessTokenWithCompletion:(void (^)(TWAuth *auth, NSString * __nullable invalidatedBearerAccessToken, NSError * __nullable error))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(self, nil, [NSError tw_unsupportedAuthenticationErrorWithDescription:@"Invalidate bearer access token is not supported"
                                                                          failureReason:@"Not initialized in an appAuth."]);
    });
}

#pragma mark - Override

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    TWAuth *auth = object;
    if (![auth isKindOfClass:[TWAuth class]]) {
        return NO;
    }
    
    return self.authName.hash == auth.authName.hash &&
    self.consumerKey.hash == auth.consumerKey.hash &&
    self.consumerSecret.hash == auth.consumerSecret.hash &&
    self.accessToken.hash == auth.accessToken.hash &&
    self.accessTokenSecret.hash == auth.accessTokenSecret.hash &&
    self.bearerAccessToken.hash == auth.bearerAccessToken.hash &&
    self.account.hash == auth.account.hash;
}

- (NSUInteger)hash
{
    return self.authName.hash ^
    self.consumerKey.hash ^
    self.consumerSecret.hash ^
    self.accessToken.hash ^
    self.accessTokenSecret.hash ^
    self.bearerAccessToken.hash ^
    self.account.hash;
}

- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ {\n", [super description]];
    NSString *indent = tw_indent(level + 1);
    
    [desc appendFormat:@"%@authName = %@;\n", indent, [self authName]];
    
    if ([self isMemberOfClass:[TWAuth class]]) {
        [desc appendFormat:@"%@}", tw_indent(level)];
    }
    
    return [NSString stringWithString:desc];
}

@end
NS_ASSUME_NONNULL_END