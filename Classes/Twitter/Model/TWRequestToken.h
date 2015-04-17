//
//  TWRequestToken.h
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuthObject.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWRequestToken : TWAuthObject

+ (TWRequestToken * __nullable)tokenWithAmpersandSeparatedRequestTokenString:(NSString *)requestTokenString
                                                                       error:(NSError **)errorPtr;

- (instancetype)initWithRequestToken:(NSString *)requestToken
                       oauthVerifier:(NSString *)oauthVerifier;

- (NSString *)requestToken;
- (NSString *)oauthVerifier;

- (BOOL)isValid;

@end
NS_ASSUME_NONNULL_END