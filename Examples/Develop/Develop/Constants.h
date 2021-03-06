//
//  Constants.h
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTargetUserID 783214 // https://twitter.com/twitter
#define kTargetUserIDStr @"783214"
#define kTargetScreenName @"twitter" // https://twitter.com/twitter
#define kTargetUserID2 384704911 // https://twitter.com/yusuga_
#define kTargetUserID2Str @"384704911"

#define kTargetTweetID 20 // https://twitter.com/jack/status/20
#define kTargetTweetIDStr @"20"
#define kTargetTweetID2 440322224407314432 // https://twitter.com/theellenshow/status/440322224407314432
#define kTargetTweetID2Str @"440322224407314432"

#define kAttachmentURL @"https://twitter.com/jack/status/20"
#define kAttachmentURL2 @"https://twitter.com/biz/status/21"

#define kSlug @"twitter"

#define kListUserID 20 // https://twitter.com/ev
#define kListOwnerID 571202103 // https://twitter.com/Medium
#define kListMemberID 1153 // https://twitter.com/AndrewCrow
#define kListID 86737505 // https://twitter.com/Medium/lists/medium-employees
#define kListSlug @"medium-employees" // https://twitter.com/Medium/lists/medium-employees

#define kWOEID 1
#define kPlaceID @"df51dec6f4ee2b2c"

#define kLatitude @"37.76893497"
#define kLongitude @"-122.42284884"

/*---*/

#define kText [NSString stringWithFormat:@"- [API %@] (%@)", NSStringFromSelector(_cmd), [NSDate dateWithTimeIntervalSinceNow:0.]]

#define validateAPICompletion(operation, jsonClassName, json, error) XCTAssertTrue([NSThread isMainThread]);\
XCTAssertNotNil(operation);\
XCTAssertTrue([json isKindOfClass:[jsonClassName class]], @"class = %@, json = %@", NSStringFromClass([json class]), json);\
if (error) {\
if ([error.domain isEqualToString:TWAPIErrorDomain] && error.code == TWAPIErrorCodeRateLimitExceeded) {\
NSLog(@"RateLimitExceeded; %s", __func__);\
} else {\
NSLog(@"error = %@, responseString = %@;", error, operation.responseString);\
XCTFail();\
}\
}\

#define validateAPICompletionAndFulfill(operation, jsonClassName, json, error) validateAPICompletion(operation, jsonClassName, json, error);\
[expectation fulfill];

@interface Constants : NSObject

+ (NSString *)consumerKey;
+ (NSString *)consumerSecret;
+ (NSString *)accessToken;
+ (NSString *)accessTokenSecret;
+ (NSString *)userID;

+ (NSString *)consumerKeyOfAllowedXAuth;
+ (NSString *)consumerSecretOfAllowedXAuth;
+ (NSString *)screenName;
+ (NSString *)password;

+ (UIImage *)imageOfPNGLandscape;
+ (UIImage *)imageOfPNGLandscapeWithMaxResolution:(CGFloat)maxResolution;
+ (UIImage *)imageOfJPEGLandscape;
+ (UIImage *)imageOfJPEGLandscapeWithMaxResolution:(CGFloat)maxResolution;

+ (UIImage *)resizeImage:(UIImage *)image
       withMaxResolution:(CGFloat)maxResolution;

+ (NSData *)imageData;

@end
