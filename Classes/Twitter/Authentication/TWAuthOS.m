//
//  TWAuthOS.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuthOS.h"
#import "TWOAuth1.h"
#import "TWAuthModels.h"
#import "TWConstants.h"
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"
@import Social;

NS_ASSUME_NONNULL_BEGIN

static inline SLRequestMethod tw_SLRequestMethodFromHTTPMethod(NSString *HTTPMethod)
{
    if([HTTPMethod isEqualToString:@"POST"]) return SLRequestMethodPOST;
    if([HTTPMethod isEqualToString:@"DELETE"]) return SLRequestMethodDELETE;
    if([HTTPMethod isEqualToString:@"PUT"]) return SLRequestMethodPUT;
    return SLRequestMethodGET;
}

@implementation ACAccount (TwitterOS)
- (NSString*)tw_userID
{
    return [self valueForKeyPath:@"properties.user_id"];
}
@end

@interface TWAuthOS ()

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) ACAccount *account;

@end

@implementation TWAuthOS

- (instancetype)initWithAccount:(ACAccount *)account
{
    if (self = [super init]) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.account = account;
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
    
    [desc appendFormat:@"%@account = %@;\n", indent, [self account]];
    
    [desc appendFormat:@"%@}", tw_indent(level)];
    
    return [NSString stringWithString:desc];
}

#pragma mark - TwitterAuthProtocol
#pragma mark @required

- (NSString *)userID
{
    return [self.account tw_userID];
}

- (NSString *)screenName
{
    return self.account.username;
}

- (BOOL)authorized
{
    SLRequest *validationRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                      requestMethod:SLRequestMethodGET
                                                                URL:[NSURL URLWithString:@"https://twitter.com"] // dummy URL
                                                         parameters:nil];
    validationRequest.account = self.account;
    return validationRequest.preparedURLRequest != nil;
}

- (void)authorizeWithCompletion:(void (^)(TWAuth * __nullable, NSError * __nullable))completion
{
    ACAccountType *type = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:type
                                               options:nil
                                            completion:^(BOOL granted, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSError *accountError = nil;
             if (error) {
                 accountError = error;
             } else if (!granted) {
                 accountError = [NSError tw_twitterPrivacyAccessError];
             }
             completion(accountError ? nil : self, accountError);
         });
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
    
    SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                              requestMethod:tw_SLRequestMethodFromHTTPMethod(HTTPMethod)
                                                        URL:url
                                                 parameters:requestParams];
    slRequest.account = self.account;
    
    if(postData) {
        [slRequest addMultipartData:postData.data
                           withName:postData.name
                               type:postData.mimeType
                           filename:postData.fileName];
    }
    
    NSMutableURLRequest *request = [slRequest preparedURLRequest].mutableCopy;
    if (!request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil, [NSError tw_accountAuthenticationFailed]);
        });
        return nil;
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
    return @"UserAuth-iOS";
}

- (void)reverseAuthWithConsumerKey:(NSString *)consumerKey
                    consumerSecret:(NSString *)consumerSecret
                        completion:(void (^)(TWAuth *auth, TWOAuth1Token * __nullable authToken, NSError * __nullable error))completion
{
    TWOAuth1 *oauth = [[TWOAuth1 alloc] initWithConsumerKey:consumerKey
                                             consumerSecret:consumerSecret];
    [oauth acquireReverseAuthRequestTokenWithCompletion:^(TWAuth *auth, NSString * __nullable reverseAuthParametersString, NSError * __nullable error)
     {
         if (error) {
             completion(self, nil, error);
             return ;
         }
         
         [self acquireReverseAuthAccessTokenWithConsumerKey:consumerKey
                                             consumerSecret:consumerSecret
                                reverseAuthParametersString:reverseAuthParametersString
                                                 completion:completion];
     }];
}

#pragma mark - Public
#pragma mark Auth

#pragma mark - Private

- (void)acquireReverseAuthAccessTokenWithConsumerKey:(NSString *)consumerKey
                                      consumerSecret:(NSString *)consumerSecret
                         reverseAuthParametersString:(NSString *)reverseAuthParametersString
                                          completion:(void (^)(TWAuth *auth, TWOAuth1Token * __nullable authToken, NSError * __nullable error))completion
{
    [self sendRequestWithHTTPMethod:@"POST"
                      baseURLString:@"https://api.twitter.com/"
                  relativeURLString:@"oauth/access_token"
                         parameters:@{@"x_reverse_auth_target" : consumerKey,
                                      @"x_reverse_auth_parameters" : reverseAuthParametersString}
                        willRequest:nil
                     uploadProgress:nil
                   downloadProgress:nil
                             stream:nil
                         completion:^(TWAPIRequestOperation * operation, id responseObject, NSError *error) {
                             if (error) {
                                 completion(self, nil, error);
                                 return ;
                             }
                             
                             NSError *initError = nil;
                             TWOAuth1Token *authToken = [TWOAuth1Token tokenWithAmpersandSeparatedAuthenticationString:operation.responseString
                                                                                                           consumerKey:consumerKey
                                                                                                        consumerSecret:consumerSecret
                                                                                                                 error:&initError];
                             completion(self, authToken, initError);
                         }];
}

@end
NS_ASSUME_NONNULL_END
