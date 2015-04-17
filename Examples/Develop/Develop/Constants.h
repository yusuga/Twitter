//
//  Constants.h
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTargetUserID 783214 // https://twitter.com/twitter
#define kTargetUserIDStr @"783214"
#define kTargetScreenName @"twitter" // https://twitter.com/twitter
#define kTargetUserID2 384704911 // https://twitter.com/yusuga_
#define kTargetUserID2Str @"384704911"

#define kTargetTweetID 20 // https://twitter.com/jack/status/20
#define kTargetTweetIDStr @"20"
#define kTargetTweetID2 440322224407314432 // https://twitter.com/theellenshow/status/440322224407314432
#define kTargetTweetID2Str @"440322224407314432"

#define kSlug @"twitter"

#define kListUserID 12 // https://twitter.com/jack
#define kListOwnerID 26642006 // https://twitter.com/Alyssa_Milano
#define kListID 21294 // https://twitter.com/Alyssa_Milano/lists/happy-tweeting
#define kListSlug @"happy-tweeting" // https://twitter.com/Alyssa_Milano/lists/happy-tweeting

#define kWOEID 1
#define kPlaceID @"df51dec6f4ee2b2c"

#define kLatitude @"37.76893497"
#define kLongitude @"-122.42284884"

/*---*/

#define kText [NSString stringWithFormat:@"- [API %@] (%@)", NSStringFromSelector(_cmd), [NSDate dateWithTimeIntervalSinceNow:0.]]

#define validateAPICompletion(operation, jsonClassName, json, error) XCTAssertTrue([NSThread isMainThread]);\
XCTAssertNotNil(operation);\
XCTAssertTrue([json isKindOfClass:[jsonClassName class]]);\
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

+ (NSString *)consumerKeyOfAllowedXAuth;
+ (NSString *)consumerSecretOfAllowedXAuth;
+ (NSString *)screenName;
+ (NSString *)password;

+ (NSData *)imageData;

@end