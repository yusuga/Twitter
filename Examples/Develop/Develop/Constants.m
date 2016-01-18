//
//  Constants.m
//
//  Created by Yu Sugawara on 4/15/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "Constants.h"

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

+ (UIImage *)imageOfPNGLandscape
{
    UIImage *image = [UIImage imageNamed:@"png_landscape.png"];
    NSParameterAssert(image);
    return image;
}

+ (UIImage *)imageOfPNGLandscapeWithMaxResolution:(CGFloat)maxResolution
{
    return [Constants resizeImage:[self imageOfPNGLandscape] withMaxResolution:maxResolution];
}

+ (UIImage *)imageOfJPEGLandscape
{
    UIImage *image = [UIImage imageNamed:@"jpeg_landscape.jpg"];
    NSParameterAssert(image);
    return image;
}

+ (UIImage *)imageOfJPEGLandscapeWithMaxResolution:(CGFloat)maxResolution
{
    return [Constants resizeImage:[self imageOfJPEGLandscape] withMaxResolution:maxResolution];
}

+ (UIImage *)resizeImage:(UIImage *)image
       withMaxResolution:(CGFloat)maxResolution
{
    CGImageRef cgImage = image.CGImage;
    
    CGFloat width = CGImageGetWidth(cgImage);
    CGFloat height = CGImageGetHeight(cgImage);
    
    if (MAX(width, height) < maxResolution) {
        return image;
    }
    
    CGFloat ratio = width/height;
    if (ratio > 1.) {
        width = maxResolution;
        height = width / ratio;
    } else {
        height = maxResolution;
        width = height * ratio;
    }
    
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 width,
                                                 height,
                                                 CGImageGetBitsPerComponent(cgImage),
                                                 CGImageGetBytesPerRow(cgImage),
                                                 CGImageGetColorSpace(cgImage),
                                                 CGImageGetBitmapInfo(cgImage));
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0., 0., width, height), cgImage);
    
    UIImage *scaledImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CFRelease(context);
    
    return scaledImage;
}

+ (NSData *)imageData
{
    return UIImageJPEGRepresentation([self resizeImage:[self imageOfJPEGLandscape] withMaxResolution:256.], 1.);
}

@end
