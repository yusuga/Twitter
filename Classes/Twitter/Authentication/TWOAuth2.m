//
//  TWOAuthAppOnly.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWOAuth2.h"
#import "TWAuthModels.h"
#import "TWConstants.h"
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"
#import <OAuthCore/OAuth+Additions.h>

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuth2 ()

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy, nullable) NSString *bearerAccessToken;

@end

@implementation TWOAuth2

#pragma mark - Initial

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                  bearerAccessToken:(NSString *)bearerAccessToken
{
    TWOAuth2 *auth = [self initWithConsumerKey:consumerKey
                                consumerSecret:consumerSecret];
    auth.bearerAccessToken = bearerAccessToken;
    return auth;
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
{
    if (self = [super init]) {
        self.consumerKey = consumerKey;
        self.consumerSecret = consumerSecret;
    }
    return self;
}

- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSMutableString *desc = [super descriptionWithIndent:level].mutableCopy;
    
    NSString *indent = tw_indent(level + 1);
    
    [desc appendFormat:@"%@oauth2Token = %@;\n", indent, [[self oauth2Token] descriptionWithIndent:level + 1]];
    
    [desc appendFormat:@"%@}", tw_indent(level)];
    
    return [NSString stringWithString:desc];
}

#pragma mark - TwitterAuthProtocol
#pragma mark @required

- (BOOL)authorized
{
    return self.bearerAccessToken != nil;
}

- (void)authorizeWithCompletion:(void (^)(TWAuth *auth, NSError * __nullable error))completion
{
    /**
     *  AppAuth does not supported `account/verify_credentials`
     */
    [self acquireBearerAccessTokenWithCompletion:^(TWAuth *auth, TWOAuth2Token * __nullable token, NSError * __nullable error) {
        completion(auth, error);
    }];
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
    
    [request setValue:[self bearerAuthorization] forHTTPHeaderField:@"Authorization"];
    
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
    return @"AppAuth-OAuth2.0";
}

- (TWOAuth2Token * __nullable)oauth2Token
{
    TWOAuth2Token *token = [[TWOAuth2Token alloc] initWithConsumerKey:self.consumerKey
                                                       consumerSecret:self.consumerSecret
                                                    bearerAccessToken:self.bearerAccessToken];
    return token.isValid ? token : nil;
}

#pragma mark - Auth
#pragma mark OAuth 2.0 - Bearer Access Token

/**
 *  https://dev.twitter.com/oauth/reference/post/oauth2/token
 */

- (void)acquireBearerAccessTokenWithCompletion:(void(^)(TWAuth *auth, TWOAuth2Token * __nullable token, NSError * __nullable error))completion
{
    [self sendRequestWithHTTPMethod:kTWHTTPMethodPOST
                      baseURLString:kTWBaseURLString_API
                  relativeURLString:@"oauth2/token"
                         parameters:@{@"grant_type" : @"client_credentials"}
                        willRequest:^(NSMutableURLRequest * __nonnull request){
                            [request setValue:[self basicAuthorization] forHTTPHeaderField:@"Authorization"];
                        }
                     uploadProgress:nil
                   downloadProgress:nil
                             stream:nil
                         completion:^(TWAPIRequestOperation * __nullable operation, id __nullable json, NSError * __nullable error) {
                             if (error) {
                                 completion(self, nil, error);
                                 return ;
                             }
                             
                             /**
                              *  {"token_type":"bearer","access_token":"AAAA%2FAAA%3DAAAAAAAA"}
                              */
                             
                             NSError *parseError = nil;
                             TWOAuth2Token *token = [TWOAuth2Token tokenWithDictionary:json error:&parseError];
                             
                             if (parseError) {
                                 completion(self, nil, parseError);
                                 return ;
                             }
                             
                             self.bearerAccessToken = token.bearerAccessToken;
                             completion(self, token, nil);
                         }];
}

#pragma mark OAuth 2.0 - Invalidate access token

/**
 *  https://dev.twitter.com/oauth/reference/post/oauth2/invalidate/token
 */

- (void)invalidateBearerAccessTokenWithCompletion:(void (^)(TWAuth *auth, NSString * __nullable invalidatedBearerAccessToken, NSError * __nullable error))completion
{
    if (!self.bearerAccessToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self, nil, [NSError tw_badArgumentErrorWithFailureReason:@"bearerToken is nil."]);
        });
    }
    
    [self sendRequestWithHTTPMethod:kTWHTTPMethodPOST
                      baseURLString:kTWBaseURLString_API
                  relativeURLString:@"oauth2/invalidate_token"
                         parameters:@{@"access_token" : self.bearerAccessToken}
                        willRequest:^(NSMutableURLRequest * __nonnull request) {
                            [request setValue:[self basicAuthorization] forHTTPHeaderField:@"Authorization"];
                        }
                     uploadProgress:nil
                   downloadProgress:nil
                             stream:nil
                         completion:^(TWAPIRequestOperation * __nullable operation, id __nullable json, NSError * __nullable error) {
                             if (error) {
                                 completion(self, nil, error);
                                 return ;
                             }
                             
                             /**
                              *  {"access_token":"AAAA%2FAAA%3DAAAAAAAA"}
                              */
                             
                             NSError *parseError = nil;
                             TWOAuth2Token *token = [TWOAuth2Token tokenWithDictionary:json error:&parseError];
                             if (parseError) {
                                 completion(self, nil, parseError);
                                 return ;
                             }
                             self.bearerAccessToken = nil;
                             completion(self, token.bearerAccessToken, nil);
                         }];
}

#pragma mark - Authorization

- (NSString *)basicAuthorization
{
    NSString *token = [NSString stringWithFormat:@"%@:%@", [self.consumerKey ab_RFC3986EncodedString], [self.consumerSecret ab_RFC3986EncodedString]];
    return [NSString stringWithFormat:@"Basic %@", [[token dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
}

- (NSString *)bearerAuthorization
{
    if (!self.bearerAccessToken) return nil;
    return [NSString stringWithFormat:@"Bearer %@", self.bearerAccessToken];
}

@end
NS_ASSUME_NONNULL_END
