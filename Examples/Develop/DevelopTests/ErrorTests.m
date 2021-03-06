//
//  ErrorTests.m
//
//  Created by Yu Sugawara on 4/16/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Twitter.h"
#import "Constants.h"
#import "TWConstants.h"

static TWAPIClient *__apiClient;

@interface ErrorTests : XCTestCase

@end

@implementation ErrorTests

- (void)setUp
{
    [super setUp];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __apiClient = [[TWAPIClient alloc] initWithAuth:[TWAuth userAuthWithConsumerKey:[Constants consumerKey]
                                                                         consumerSecret:[Constants consumerSecret]
                                                                            accessToken:[Constants accessToken]
                                                                      accessTokenSecret:[Constants accessTokenSecret]]];
    });
    
    [TWAPIRequestOperationManager setAllowsPostErrorNotification:YES];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test404
{
    [self expectationForNotification:TWAPIErrorNotification
                              object:nil
                             handler:^BOOL(NSNotification * _Nonnull notification)
     {
         XCTAssertNotNil(notification);
         NSError *error = notification.object;
         XCTAssertTrue([error isKindOfClass:[NSError class]]);
         AFHTTPRequestOperation *operation = notification.userInfo[@"operation"];
         XCTAssertTrue([operation isKindOfClass:[AFHTTPRequestOperation class]]);
         return YES;
     }];
    
    [__apiClient getUsersShowWithUserID:1
                           orScreenName:nil
                        includeEntities:YES
                             completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error) {
                                 XCTAssertNotNil(operation);
                                 XCTAssertNil(user);
                                 XCTAssertNotNil(error);
                                 XCTAssertTrue([error.localizedDescription isKindOfClass:[NSString class]]);
                                 XCTAssertTrue([error.tw_failingURL isKindOfClass:[NSURL class]]);
                                 XCTAssertTrue([error.tw_failingURLResponse isKindOfClass:[NSHTTPURLResponse class]]);
                                 XCTAssertTrue([error.tw_underlyingError isKindOfClass:[NSError class]]);
                                 XCTAssertEqual(error.tw_HTTPStatusCode, 404);
                                 XCTAssertFalse(error.tw_isCancelled);
                             }];
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testCancelAPIRequestOpration
{
    XCTestExpectation *expectation = [self expectationForNotification:TWAPIErrorNotification
                                                               object:nil
                                                              handler:^BOOL(NSNotification * _Nonnull notification)
                                      {
                                          XCTFail();
                                          return NO;
                                      }];
    
    TWAPIRequestOperation *ope = [__apiClient getUsersShowWithUserID:20
                                                       orScreenName:nil
                                                    includeEntities:YES
                                                         completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
                                      {
                                          XCTAssertNotNil(operation);
                                          XCTAssertNil(user);
                                          XCTAssertNotNil(error);
                                          XCTAssertTrue([error.localizedDescription isKindOfClass:[NSString class]]);
                                          XCTAssertTrue([error.tw_failingURL isKindOfClass:[NSURL class]]);
                                          XCTAssertTrue([error.tw_underlyingError isKindOfClass:[NSError class]]);
                                          XCTAssertEqual(error.tw_HTTPStatusCode, NSURLErrorCancelled);
                                          XCTAssertTrue([error tw_isCancelled]);
                                      }];
    XCTAssertNotNil(ope);
    [ope cancel];
    
    NSTimeInterval timeout = 5;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((timeout - 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testCancelAPIMultipleOperation
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSData *media = [Constants imageData];
        
        TWAPIMultipleRequestOperation *ope = [client tw_postStatusesUpdateWithStatus:kText
                                                                           mediaData:@[media, media, media, media]
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
                                              } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
                                                  XCTAssertNil(tweet);
                                                  XCTAssertNotNil(error);
                                                  XCTAssertTrue([error.localizedDescription isKindOfClass:[NSString class]]);
                                                  XCTAssertTrue([error.tw_failingURL isKindOfClass:[NSURL class]]);
                                                  XCTAssertTrue([error.tw_underlyingError isKindOfClass:[NSError class]]);
                                                  XCTAssertEqual(error.tw_HTTPStatusCode, NSURLErrorCancelled);
                                                  XCTAssertTrue([error tw_isCancelled]);
                                                  [expectation fulfill];
                                              }];
        XCTAssertNotNil(ope);
        [ope cancel];
    } timeout:30.];
}

- (void)testStreamTimeout
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSTimeInterval keepAliveTime = client.auth.httpClient.streamKeepAliveTime;
        client.auth.httpClient.streamKeepAliveTime = 5.;
        void(^resetTime)() = ^{
            client.auth.httpClient.streamKeepAliveTime = keepAliveTime;
        };
        
        [client postStatusesFilterWithKeywords:@[@"com.yusuga.twitter.test-stream-timeout"]
                                 followUserIDs:nil
                                     locations:nil
                                        stream:^(TWAPIRequestOperation * __nonnull operation, NSDictionary * __nonnull json, TWStreamJSONType type)
         {
             static NSUInteger __count;
             if (type == TWStreamJSONTypeTimeout) {
                 NSLog(@"type = %@ %zd", NSStringFromTWStreamJSONType(type), ++__count);
                 if (__count > 2) {
                     resetTime();
                     [operation cancel];
                     [expectation fulfill];
                 }
             }
         } failure:^(TWAPIRequestOperation * __nonnull operation, NSError * __nonnull error) {
             NSLog(@"error = %@", error);
             resetTime();
             [expectation fulfill];
         }];
    } timeout:30.];
}

- (void)testAuthenticationError
{
    NSString *invalidAccessToken = @"invalidated-access-token";
    
    TWAuth *invalidAuth = [TWAuth userAuthWithConsumerKey:[Constants consumerKey]
                                           consumerSecret:[Constants consumerSecret]
                                              accessToken:invalidAccessToken
                                        accessTokenSecret:[Constants accessTokenSecret]];
    
    invalidAuth.screenName = @"name";
    
    TWAPIClient *client = [[TWAPIClient alloc] initWithAuth:invalidAuth];
    
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
    
    [client getUsersShowWithUserID:kTargetUserID
                      orScreenName:nil
                   includeEntities:YES
                        completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
     {
         XCTAssertNotNil(error);
         XCTAssertEqualObjects(error.domain, TWAPIErrorDomain);
         
         /**
          *  Note:
          *
          *  - Invalid access token. (TWAPIErrorCodeInvalidOrExpiredToken)
          *  "code":89
          *  "message":"Invalid or expired token."
          *
          *  - Invalid consumerKey, consumerSecret or access token secret. (TWAPIErrorCodeCouldNotAuthenticate)
          *  "code":32
          *  "message":"Could not authenticate you."
          *
          *  - Authorization is missing in the HTTP header field. (TWAPIErrorCodeBadAuthenticationData)
          *  "code":215
          *  "message":"Bad Authentication data."
          */
         XCTAssertEqual(error.code, TWAPIErrorCodeInvalidOrExpiredToken);
         XCTAssertNotNil(error.tw_invalidAuthorizationString);
         
         TWAuthorization *authorization =[TWAuthorization authorizationWithCommaSeparatedAuthorizationString:error.tw_invalidAuthorizationString];
         XCTAssertNotNil([authorization oauth_consumer_key]);
         XCTAssertEqualObjects([authorization oauth_token], invalidAccessToken);
         XCTAssertNotNil([authorization oauth_token]);
         
         NSLog(@"%s {\n\tresponseString = %@;\n\terror.localizedDescription = %@;\n}", __func__, operation.responseString, error.localizedDescription);
         NSLog(@"Invalid authorization = %@;", authorization);
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#if 0
#warning testRateLimit enabled
- (void)testRateLimit
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [self rateLimitWithClient:client completion:^(TWAPIRequestOperation *operation, NSError *error) {
            NSLog(@"responseString = %@", operation.responseString);
            
            TWRateLimit *rateLimit = error.tw_rateLimit;
            NSLog(@"error = %@\n\nlocalizedDescription = %@\nrateLimit = %@\n", error, error.localizedDescription, rateLimit);
            XCTAssertNotNil(rateLimit);
            XCTAssertGreaterThan([rateLimit remainingTime], 0);
            XCTAssertNotNil([rateLimit localizedTimeString]);
            
            [expectation fulfill];
        }];
    } timeout:60.];
}

- (void)rateLimitWithClient:(TWAPIClient *)client completion:(void (^)(TWAPIRequestOperation *operation, NSError *error))completion
{
    static NSUInteger __count;
    void(^log)(NSUInteger count) = ^(NSUInteger count) {
        NSLog(@"Request... (%zd)", count);
    };
    
    if (!__count) log(++__count);
    [client getTrendsAvailableWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trends, NSError * __nullable error) {
        if (error) {
            completion(operation, error);
        } else {
            log(++__count);
            [self rateLimitWithClient:client completion:completion];
        }
    }];
}
#endif

#pragma mark - API

- (void)testPostStatusesUpdateWithEmptyTextAndAttachmentURL
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client postStatusesUpdateWithStatus:@""
                           inReplyToStatusID:0
                           possiblySensitive:NO
                                    latitude:nil
                                   longitude:nil
                                     placeID:nil
                          displayCoordinates:NO
                                    trimUser:NO
                                    mediaIDs:nil
                               attachmentURL:kAttachmentURL
                              uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             NSLog(@"uploadPrgress bytesWritten = %zd, totalBytesWritten = %lld, totalBytesExpectedToWrite = %lld, progress = %f", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
             XCTAssertEqualObjects(error.domain, TWAPIErrorDomain);
             XCTAssertEqual(error.code, TWAPIErrorCodeMissingRequiredParameter);
             [expectation fulfill];
         }];
    }];
}

- (void)testUploadMultipleMediaWithAttachmentURL
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSData *media = [Constants imageData];
        
        [client tw_postStatusesUpdateWithStatus:kText
                                      mediaData:@[media]
                              inReplyToStatusID:0
                              possiblySensitive:NO
                                       latitude:nil
                                      longitude:nil
                                        placeID:nil
                             displayCoordinates:YES
                                       trimUser:NO
                                  attachmentURL:kAttachmentURL
                                 uploadProgress:^(TWRequestState state, CGFloat progress)
         {
             NSLog(@"%s, state = %zd, progress = %f", __func__, state, progress);
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
         {
             XCTAssertEqualObjects(error.domain, TWAPIErrorDomain);
             XCTAssertEqual(error.code, TWAPIErrorCodeErrorTweetExceedsTheNumberOfAllowedAttachmentTypes);
             [expectation fulfill];
         }];
    } timeout:60.];
}

- (void)testPostStatusesUpdateWithInvalidAttachmentURLs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client postStatusesUpdateWithStatus:kText
                           inReplyToStatusID:0
                           possiblySensitive:NO
                                    latitude:nil
                                   longitude:nil
                                     placeID:nil
                          displayCoordinates:NO
                                    trimUser:NO
                                    mediaIDs:nil
                               attachmentURL:@"https://twitter.com"
                              uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             NSLog(@"uploadPrgress bytesWritten = %zd, totalBytesWritten = %lld, totalBytesExpectedToWrite = %lld, progress = %f", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
             XCTAssertEqualObjects(error.domain, TWAPIErrorDomain);
             XCTAssertEqual(error.code, TWAPIErrorCodeAttachmentURLParameterIsInvalid);
             [expectation fulfill];
         }];
    }];
}

#pragma mark - Utility

- (void)clientAsyncTestBlock:(void(^)(TWAPIClient *client, XCTestExpectation *expectation))block
{
    [self clientAsyncTestBlock:block timeout:10.];
}

- (void)clientAsyncTestBlock:(void(^)(TWAPIClient *client, XCTestExpectation *expectation))block
                     timeout:(NSTimeInterval)timeout
{
    if (__apiClient) {
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        block(__apiClient, expectation);
        [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }
}

@end
