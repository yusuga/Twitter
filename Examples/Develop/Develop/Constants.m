//
//  Constants.m
//
//  Created by Yu Sugawara on 4/15/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>

static NSDictionary *__keys;

/**
 *  kesy.txt example
 *
 *  {
 *      "consumerKey" : "",
 *      "consumerSecret" : "",
 *      "accessToken" : "",
 *      "accessTokenSecret" : "",
 *      "consumerKeyOfAllowedXAuth" : "",
 *      "consumerSecretOfAllowedXAuth" : "",
 *      "screenName" : "",
 *      "password" : ""
 *  }
 */

@implementation Constants

+ (void)initialize
{
    if (self == [Constants class]) {
        NSError *error = nil;
        NSString *json = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"txt"]
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
        NSAssert1(!error, @"keys error = %@", error);
        __keys = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSAssert1(!error, @"json error = %@", error);
        NSAssert1([__keys isKindOfClass:[NSDictionary class]], @"__keys.class = %@", NSStringFromClass([__keys class]));
    }
}

+ (NSString *)consumerKey
{
    NSString *key = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(key, @"%@ is not found.", NSStringFromSelector(_cmd));
    return key;
}

+ (NSString *)consumerSecret
{
    NSString *key = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(key, @"%@ is not found.", NSStringFromSelector(_cmd));
    return key;
}

+ (NSString *)accessToken
{
    NSString *key = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(key, @"%@ is not found.", NSStringFromSelector(_cmd));
    return key;
}

+ (NSString *)accessTokenSecret
{
    NSString *key = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(key, @"%@ is not found.", NSStringFromSelector(_cmd));
    return key;
}

+ (NSString *)consumerKeyOfAllowedXAuth
{
    return __keys[NSStringFromSelector(_cmd)];
}

+ (NSString *)consumerSecretOfAllowedXAuth
{
    return __keys[NSStringFromSelector(_cmd)];
}

+ (NSString *)screenName
{
    NSString *key = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(key, @"%@ is not found.", NSStringFromSelector(_cmd));
    return key;
}

+ (NSString *)password
{
    NSString *key = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(key, @"%@ is not found.", NSStringFromSelector(_cmd));
    return key;
}

#pragma mark -

+ (NSData *)imageData
{
    UIImage *image = [UIImage imageNamed:@"jpg"];
    NSAssert(image, nil);
    return UIImageJPEGRepresentation(image, 1.f);
}

@end
