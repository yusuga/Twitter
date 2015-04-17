//
//  TWConstants.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - URL

extern NSString *kTWBaseURLString_API;
extern NSString *kTWBaseURLString_API_1_1;
extern NSString *kTWBaseURLString_Upload_1_1;
extern NSString *kTWBaseURLString_Stream_1_1;
extern NSString *kTWBaseURLString_UserStream_1_1;
extern NSString *kTWBaseURLString_SiteStream_1_1;

extern NSString *kTWHTTPMethodGET;
extern NSString *kTWHTTPMethodPOST;
extern NSString *kTWHTTPMethodDELETE;
extern NSString *kTWHTTPMethodPUT;

#pragma mark - Model key

extern NSString * const kTWPostData;

#pragma mark - API

typedef NS_ENUM(NSInteger, TWAPISearchResultType) {
    TWAPISearchResultTypeMixed, // Default
    TWAPISearchResultTypeRecent,
    TWAPISearchResultTypePopular,
};

@interface TWConstants : NSObject

@end
