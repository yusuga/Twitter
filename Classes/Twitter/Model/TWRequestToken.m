//
//  TWRequestToken.m
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWRequestToken.h"
#import <OAuthCore/OAuth+Additions.h>
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"

NS_ASSUME_NONNULL_BEGIN
@implementation TWRequestToken

+ (TWRequestToken * __nullable)tokenWithAmpersandSeparatedRequestTokenString:(NSString *)requestTokenString
                                                                       error:(NSError **)errorPtr
{
    /**
     *  oauth_token=OWsaiwivW8pWMKu8lt8PuUpUzENQ1ezg&oauth_verifier=0lwDhwGH0URzip3dw9Qcc7GI1kN9cfWh
     */
    
    TWRequestToken *token = [[[self class] alloc] initWithDictionary:[NSURL ab_parseURLQueryString:requestTokenString]];
    
    if ([token isValid]) {
        return token;
    }
    if (errorPtr) {
        *errorPtr = [NSError tw_parseFailedErrorWithUnderlyingString:requestTokenString];
    }
    return nil;
}

- (instancetype)initWithRequestToken:(NSString *)requestToken
                       oauthVerifier:(NSString *)oauthVerifier
{
    NSMutableDictionary *token = [NSMutableDictionary dictionary];
    if (requestToken) token[@"oauth_token"] = requestToken;
    if (oauthVerifier) token[@"oauth_verifier"] = oauthVerifier;

    return [self initWithDictionary:[NSDictionary dictionaryWithDictionary:token]];
}

- (NSString *)requestToken
{
    return self.dictionary[@"oauth_token"];
}

- (NSString *)oauthVerifier
{
    return self.dictionary[@"oauth_verifier"];
}

- (BOOL)isValid
{
    return ([self requestToken] && [self oauthVerifier]);
}

@end
NS_ASSUME_NONNULL_END