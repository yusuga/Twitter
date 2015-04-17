//
//  TWAuthorization.m
//
//  Created by Yu Sugawara on 4/24/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuthorization.h"

NS_ASSUME_NONNULL_BEGIN
@implementation TWAuthorization

+ (TWAuthorization * __nullable)authorizationWithCommaSeparatedAuthorizationString:(NSString *)authorizationString
{
    /**
     *  "OAuth oauth_timestamp=\"1429858168\", oauth_version=\"1.0\", oauth_consumer_key=\"OAUTH_CONSUMER_KEY\", oauth_signature=\"SMNZb2T2V6f8BRwGMCigBK6Ntbo%3D\", oauth_token=\"OAUTH_TOKEN\", oauth_nonce=\"4A6AA983-2E08-4383-8896-3E6BC89BD825\", oauth_signature_method=\"HMAC-SHA1\""
     */
    
    if (![authorizationString hasPrefix:@"OAuth "]) {
        return nil;
    }
    NSString *authStr = [authorizationString stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
    authStr = [authStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    authStr = [authStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *pairs = [authStr componentsSeparatedByString:@","];
    for(NSString *pair in pairs) {
        NSArray *keyValue = [pair componentsSeparatedByString:@"="];
        if([keyValue count] == 2) {
            NSString *key = [keyValue objectAtIndex:0];
            NSString *value = [keyValue objectAtIndex:1];
            if(key && value)
                [dict setObject:value forKey:key];
        }
    }
    return [[TWAuthorization alloc] initWithDictionary:[NSDictionary dictionaryWithDictionary:dict]];
}

- (NSString *__nullable)oauth_consumer_key
{
    return self.dictionary[@"oauth_consumer_key"];
}

- (NSString *__nullable)oauth_token
{
    return self.dictionary[@"oauth_token"];
}

- (NSString *__nullable)oauth_signature_method
{
    return self.dictionary[@"oauth_signature_method"];
}

- (NSString *__nullable)oauth_signature
{
    return self.dictionary[@"oauth_signature"];
}

- (NSString *__nullable)oauth_nonce
{
    return self.dictionary[@"oauth_nonce"];
}

- (NSString *__nullable)oauth_version
{
    return self.dictionary[@"oauth_version"];
}

- (NSString *__nullable)oauth_timestamp
{
    return self.dictionary[@"oauth_timestamp"];
}

- (NSString *__nullable)oauth_callback
{
    return self.dictionary[@"oauth_callback"];
}

@end
NS_ASSUME_NONNULL_END