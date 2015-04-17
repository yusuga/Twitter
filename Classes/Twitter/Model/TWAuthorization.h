//
//  TWAuthorization.h
//
//  Created by Yu Sugawara on 4/24/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuthObject.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWAuthorization : TWAuthObject

+ (TWAuthorization * __nullable)authorizationWithCommaSeparatedAuthorizationString:(NSString *)authorizationString;

- (NSString *__nullable)oauth_consumer_key;
- (NSString *__nullable)oauth_token;
- (NSString *__nullable)oauth_signature_method;
- (NSString *__nullable)oauth_signature;
- (NSString *__nullable)oauth_nonce;
- (NSString *__nullable)oauth_version;
- (NSString *__nullable)oauth_timestamp;
- (NSString *__nullable)oauth_callback;

@end
NS_ASSUME_NONNULL_END