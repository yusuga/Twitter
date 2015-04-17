//
//  TWOAuth2Token.m
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWOAuth2Token.h"
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"

NS_ASSUME_NONNULL_BEGIN
@implementation TWOAuth2Token

+ (TWOAuth2Token * __nullable)tokenWithDictionary:(NSDictionary *)dictionary
                                            error:(NSError ** __nullable)errorPtr
{
    TWOAuth2Token *token = [[[self class] alloc] initWithDictionary:dictionary];
    
    if ([token isValid] && [token.tokenType isEqualToString:@"bearer"]) {
        return token;
    }
    if (errorPtr) {
        *errorPtr = [NSError tw_parseFailedErrorWithUnderlyingString:[NSString stringWithFormat:@"json = %@", [dictionary description]]];
    }
    return nil;
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                  bearerAccessToken:(NSString *)bearerAccessToken
{
    return [self initWithDictionary:bearerAccessToken ? @{@"access_token" : bearerAccessToken} : nil
                        consumerKey:consumerKey
                     consumerSecret:consumerSecret];
}

- (NSString *)bearerAccessToken
{
    return self.dictionary[@"access_token"];
}

- (NSString *)tokenType
{
    return self.dictionary[@"token_type"];
}

- (BOOL)isValid
{
    return self.bearerAccessToken != nil;
}

- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSMutableString *desc = [super descriptionWithIndent:level].mutableCopy;
    NSString *indent = tw_indent(level + 1);
    
    [desc appendFormat:@"%@bearerAccessToken = %@;\n", indent, [self bearerAccessToken]];
    
    [desc appendFormat:@"%@}", tw_indent(level)];
    
    return [NSString stringWithString:desc];
}

@end
NS_ASSUME_NONNULL_END