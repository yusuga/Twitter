//
//  ManualTests.m
//  Develop
//
//  Created by Yu Sugawara on 2016/01/18.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Twitter.h"
#import "TWUtil.h"
#import "Constants.h"

@interface ManualTests : XCTestCase

@end

@implementation ManualTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#if 0
#warning manual test is enabled
- (void)testUploadMediaWithSingleJPEG1024x683
{
    NSData *imageData = UIImageJPEGRepresentation([Constants imageOfJPEGLandscapeWithMaxResolution:1024.], 0.8);
    
    [self uploadMediaWithText:kText
                    imageData:@[imageData]];
}
#endif

#if 0
#warning manual test is enabled
- (void)testUploadMediaWithMultipleJPEG1024x683
{
    NSData *imageData = UIImageJPEGRepresentation([Constants imageOfJPEGLandscapeWithMaxResolution:1024.], 0.8);
    
    [self uploadMediaWithText:kText
                    imageData:@[imageData, imageData, imageData, imageData]];
}
#endif

#if 0
#warning manual test is enabled
- (void)testUploadMediaWithSinglePNG1024x683
{
    NSData *imageData = UIImagePNGRepresentation([Constants imageOfPNGLandscapeWithMaxResolution:1024.]);
    
    [self uploadMediaWithText:kText
                    imageData:@[imageData]];
}
#endif

#if 0
#warning manual test is enabled
- (void)testUploadMediaWithMultiplePNG1024x683
{
    NSData *imageData = UIImagePNGRepresentation([Constants imageOfPNGLandscapeWithMaxResolution:1024.]);
    
    [self uploadMediaWithText:kText
                    imageData:@[imageData, imageData, imageData, imageData]];
}
#endif

#if 0
#warning manual test is enabled
- (void)testGetUser
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUserWithUserOnly:NO
                         allReplies:YES
                          locations:nil
                 stringifyFriendIDs:YES
                             stream:^(TWAPIRequestOperation * __nonnull operation, NSDictionary * __nonnull json, TWStreamJSONType type)
         {
             if (type == TWStreamJSONTypeTweet) {
                 if ([json[@"user"][@"id_str"] isEqualToString:client.auth.userID]) {
                     NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                     //NSLog(@"json: \n%@", json);
                     NSLog(@"json: \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 }
             }
         } failure:^(TWAPIRequestOperation * __nonnull operation, NSError * __nonnull error) {
             XCTFail(@"errro = %@", error);
             [expectation fulfill];
         }];
    } timeout:60.*60.];
}
#endif

#pragma mark - Utility

- (void)uploadMediaWithText:(NSString *)text
                  imageData:(NSArray<NSData *> *)imageData
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSMutableString *desc = [NSMutableString stringWithFormat:@"will %@, imageData {", text];
        for (NSData *data in imageData) {
            [desc appendFormat:@"\n\tdata.length = %zd", data.length];
        }
        [desc appendString:@"\n}"];
        NSLog(@"%@", desc);
        
        [client tw_postStatusesUpdateWithStatus:text
                                      mediaData:imageData
                              inReplyToStatusID:0
                              possiblySensitive:NO
                                       latitude:nil
                                      longitude:nil
                                        placeID:nil
                             displayCoordinates:YES
                                       trimUser:NO
                                  attachmentURL:nil
                                 uploadProgress:^(TWRequestState state, CGFloat progress)
         {
             NSLog(@"%s, state = %zd, progress = %f", __func__, state, progress);
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSDictionary, tweet, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             NSLog(@"%s, posted tweet URL: %@", __func__, TWTweetURLString([tweet valueForKeyPath:@"user.screen_name"], [tweet valueForKey:@"id"]));
             [expectation fulfill];
         }];
    } timeout:60.];
}

- (void)clientAsyncTestBlock:(void(^)(TWAPIClient *client, XCTestExpectation *expectation))block
{
    [self clientAsyncTestBlock:block timeout:10.];
}

- (void)clientAsyncTestBlock:(void(^)(TWAPIClient *client, XCTestExpectation *expectation))block
                     timeout:(NSTimeInterval)timeout
{
    TWAPIClient *client = [[TWAPIClient alloc] initWithAuth:[TWAuth userAuthWithConsumerKey:[Constants consumerKey]
                                                                             consumerSecret:[Constants consumerSecret]
                                                                                accessToken:[Constants accessToken]
                                                                          accessTokenSecret:[Constants accessTokenSecret]]];
    client.auth.userID = [Constants userID];
    client.auth.screenName = [Constants screenName];

    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
    block(client, expectation);
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

@end
