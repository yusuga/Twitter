//
//  TWOAuthToken.m
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWOAuth1Token.h"
#import <OAuthCore/OAuth+Additions.h>
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuth1Token ()

@property (copy, nonatomic, readwrite) NSString *userID;
@property (copy, nonatomic, readwrite) NSString *screenName;

@end

@implementation TWOAuth1Token

+ (TWOAuth1Token * __nullable)tokenWithAmpersandSeparatedAuthenticationString:(NSString *)authenticationString
                                                                  consumerKey:(NSString *)consumerKey
                                                               consumerSecret:(NSString *)consumerSecret
                                                                        error:(NSError ** __nullable)errorPtr
{
    /**
     *    oauth_token=OAUTH_TOKEN&oauth_token_secret=OAUTH_TOKEN_SECRET&user_id=USERID&screen_name=SCREEN_NAME
     */
    NSDictionary *tokenDict = [NSURL ab_parseURLQueryString:authenticationString];
    
    TWOAuth1Token *token = [[TWOAuth1Token alloc] initWithDictionary:tokenDict
                                                         consumerKey:consumerKey
                                                      consumerSecret:consumerSecret];
    token.userID = tokenDict[@"user_id"];
    token.screenName = tokenDict[@"screen_name"];
    
    if ([token isValid] && token.userID && token.screenName) {
        return token;
    }
    if (errorPtr) {
        *errorPtr = [NSError tw_parseFailedErrorWithUnderlyingString:[NSString stringWithFormat:@"authenticationString = %@, consumerKey = %@, consumerSecret = %@", authenticationString, consumerKey, consumerSecret]];
    }
    return nil;
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                  accessTokenSecret:(NSString *)accessTokenSecret
                             userID:(NSString * __nullable)userID
                         screenName:(NSString * __nullable)screenName
{
    NSMutableDictionary *token = [NSMutableDictionary dictionary];
    if (accessToken) token[@"oauth_token"] = accessToken;
    if (accessTokenSecret) token[@"oauth_token_secret"] = accessTokenSecret;
    self.userID = userID;
    self.screenName = screenName;
    
    return [self initWithDictionary:[NSDictionary dictionaryWithDictionary:token]
                        consumerKey:consumerKey
                     consumerSecret:consumerSecret];
}

- (NSString *)accessToken
{
    return self.dictionary[@"oauth_token"];
}

- (NSString *)accessTokenSecret
{
    return self.dictionary[@"oauth_token_secret"];
}

- (BOOL)isValid
{
    return ([super isValid] &&
            self.accessToken &&
            self.accessTokenSecret);
}

- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSMutableString *desc = [super descriptionWithIndent:level].mutableCopy;
    NSString *indent = tw_indent(level + 1);
    
    [desc appendFormat:@"%@accessToken = %@;\n", indent, [self accessToken]];
    [desc appendFormat:@"%@accessTokenSecret = %@;\n", indent, [self accessTokenSecret]];
    [desc appendFormat:@"%@userID = %@;\n", indent, [self userID]];
    [desc appendFormat:@"%@screenName = %@;\n", indent, [self screenName]];
    
    [desc appendFormat:@"%@}", tw_indent(level)];
    
    return [NSString stringWithString:desc];
}

#pragma mark - Equal

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    if (![object isKindOfClass:[TWOAuth1Token class]]) {
        return NO;
    }
    
    TWOAuth1Token *token = object;
    return self.userID.hash == token.userID.hash &&
    self.screenName.hash == token.screenName.hash;
}

- (NSUInteger)hash
{
    return [super hash] ^
    self.userID.hash ^
    self.screenName.hash;
}

#pragma mark - NSSecureCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.userID = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(userID))];
        self.screenName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(screenName))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.userID forKey:NSStringFromSelector(@selector(userID))];
    [aCoder encodeObject:self.screenName forKey:NSStringFromSelector(@selector(screenName))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithConsumerKey:self.consumerKey
                                                   consumerSecret:self.consumerSecret
                                                      accessToken:self.accessToken
                                                accessTokenSecret:self.accessTokenSecret
                                                           userID:self.userID
                                                       screenName:self.screenName];
}

@end
NS_ASSUME_NONNULL_END