//
//  TWUtil.m
//  Develop
//
//  Created by Yu Sugawara on 2016/01/18.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import "TWUtil.h"
#import <OAuthCore/OAuth+Additions.h>

NSString *TWTweetURLString(NSString *screenName, NSNumber *tweetID)
{
    return [NSString stringWithFormat:@"https://twitter.com/%@/status/%@", screenName, tweetID];
}

@implementation TWUtil

+ (NSString *)percentEscapedURLQueryWithParameters:(NSDictionary<NSString *, NSString *> *)parameters
{
    if (![parameters isKindOfClass:[NSDictionary class]] || ![parameters count]) return nil;
    
    NSMutableArray *queryItems = [NSMutableArray arrayWithCapacity:[parameters count]];
    
    for (NSString *key in [parameters keyEnumerator]) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:[key ab_RFC3986EncodedString]
                                                          value:[parameters[key] ab_RFC3986EncodedString]]];
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithString:@"http://example.com"];
    components.queryItems = [queryItems copy];
    
    return components.query;
}

@end
