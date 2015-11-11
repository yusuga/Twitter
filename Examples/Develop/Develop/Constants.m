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
 *      "userID : "",
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
    NSString *value = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(value, @"%@ is not found.", NSStringFromSelector(_cmd));
    return value;
}

+ (NSString *)consumerSecret
{
    NSString *value = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(value, @"%@ is not found.", NSStringFromSelector(_cmd));
    return value;
}

+ (NSString *)accessToken
{
    NSString *value = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(value, @"%@ is not found.", NSStringFromSelector(_cmd));
    return value;
}

+ (NSString *)accessTokenSecret
{
    NSString *value = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(value, @"%@ is not found.", NSStringFromSelector(_cmd));
    return value;
}

+ (NSString *)userID
{
    NSString *value = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(value, @"%@ is not found.", NSStringFromSelector(_cmd));
    return value;
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
    NSString *value = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(value, @"%@ is not found.", NSStringFromSelector(_cmd));
    return value;
}

+ (NSString *)password
{
    NSString *value = __keys[NSStringFromSelector(_cmd)];
    NSAssert1(value, @"%@ is not found.", NSStringFromSelector(_cmd));
    return value;
}

#pragma mark -

+ (NSData *)imageData
{
    UIImage *image = [UIImage imageNamed:@"jackal.jpg"];
    NSAssert(image, nil);
    return UIImageJPEGRepresentation(image, 1.f);
}

@end
