//
//  APIConvenienceTests.m
//
//  Created by Yu Sugawara on 4/20/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Twitter.h"
#import "Constants.h"
#import "TWStreamParser.h"

static TWAPIClient *__apiClient;

@interface APIConvenienceTests : XCTestCase

@end

@implementation APIConvenienceTests

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
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Favorite

- (void)testFavoritesAndUnfavorites
{
    int64_t tweetID = kTargetTweetID;
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        // Favorite
        [client tw_postFavoritesWithTweetID:tweetID
                                      favorited:YES
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSNull, [NSNull null], error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             // Check Favorited
             [client getStatusesShowWithTweetID:tweetID
                                       trimUser:NO
                               includeMyRetweet:YES
                                includeEntities:YES
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
              {
                  validateAPICompletion(operation, NSDictionary, tweet, error);
                  if (error) {
                      [expectation fulfill];
                      return ;
                  }
                  
                  XCTAssertTrue([tweet[@"favorited"] boolValue]);
                  
                  // Duplicate Favorite
                  [client tw_postFavoritesWithTweetID:tweetID
                                                favorited:YES
                                               completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
                   {
                       validateAPICompletion(operation, NSNull, [NSNull null], error);
                       if (error) {
                           [expectation fulfill];
                           return ;
                       }
                       
                       // Unfavorite
                       [client postFavoritesDestroyWithTweetID:tweetID
                                               includeEntities:YES
                                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
                        {
                            validateAPICompletion(operation, NSDictionary, tweet, error);
                            if (error) {
                                [expectation fulfill];
                                return ;
                            }
                            
                            // Check Unfavorited
                            [client getStatusesShowWithTweetID:tweetID
                                                      trimUser:NO
                                              includeMyRetweet:YES
                                               includeEntities:YES
                                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
                             {
                                 validateAPICompletion(operation, NSDictionary, tweet, error);
                                 if (error) {
                                     [expectation fulfill];
                                     return ;
                                 }
                                 
                                 XCTAssertFalse([tweet[@"favorited"] boolValue]);
                                 
                                 // Duplicate Unfavorite
                                 [client tw_postFavoritesWithTweetID:tweetID
                                                               favorited:NO
                                                              completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
                                  {
                                      validateAPICompletionAndFulfill(operation, NSNull, [NSNull null], error);
                                  }];
                             }];
                        }];
                   }];
              }];
         }];
    }];
}

#pragma mark - Retweet

- (void)testRetweetAndUnretweet
{
    int64_t tweetID = kTargetTweetID;
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        // Retweet
        [client tw_postStatusesRetweetWithTweetID:tweetID
                                       completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSNull, [NSNull null], error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             // Check Retweeted
             [client getStatusesShowWithTweetID:tweetID
                                       trimUser:NO
                               includeMyRetweet:YES
                                includeEntities:YES
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
              {
                  validateAPICompletion(operation, NSDictionary, tweet, error);
                  if (error) {
                      [expectation fulfill];
                      return ;
                  }

                  XCTAssertTrue([tweet[@"retweeted"] boolValue]);
                  
                  // Duplicate Retweet
                  [client tw_postStatusesRetweetWithTweetID:tweetID
                                                 completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
                   {
                       validateAPICompletion(operation, NSNull, [NSNull null], error);
                       if (error) {
                           [expectation fulfill];
                           return ;
                       }
                       
                       // Unretweet
                       [client postStatusesUnretweetWithTweetID:tweetID
                                                     completion:^(TWAPIRequestOperation * _Nullable operation, NSDictionary * _Nullable tweet, NSError * _Nullable error)
                        {
                            validateAPICompletion(operation, NSNull, [NSNull null], error);
                            if (error) {
                                [expectation fulfill];
                                return ;
                            }
                            
                            // Check Unretweeeted
                            [client getStatusesShowWithTweetID:tweetID
                                                      trimUser:NO
                                              includeMyRetweet:YES
                                               includeEntities:YES
                                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
                             {
                                 validateAPICompletion(operation, NSDictionary, tweet, error);
                                 if (error) {
                                     [expectation fulfill];
                                     return ;
                                 }
                                 
                                 XCTAssertFalse([tweet[@"retweeted"] boolValue]);
                                 
                                 // Duplicate Unretweet
                                 [client postStatusesUnretweetWithTweetID:tweetID
                                                               completion:^(TWAPIRequestOperation * _Nullable operation, NSDictionary * _Nullable tweet, NSError * _Nullable error)
                                  {
                                      validateAPICompletionAndFulfill(operation, NSNull, [NSNull null], error);
                                  }];
                             }];
                        }];
                   }];
              }];
         }];
    }];
}

#pragma mark - Tweet

- (void)testDuplicateDestroyTweet
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        // Post Tweet
        [client postStatusesUpdateWithStatus:kText
                           inReplyToStatusID:0
                              uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             NSLog(@"uploadPrgress bytesWritten = %zd, totalBytesWritten = %lld, totalBytesExpectedToWrite = %lld, progress = %f", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
             validateAPICompletion(operation, NSDictionary, tweet, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             int64_t tweetedID = [tweet[@"id"] longLongValue];
             XCTAssertGreaterThan(tweetedID, 0);
             
             // Destroy Tweet
             [client tw_postStatusesDestroyWithTweetID:tweetedID
                                            completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
              {
                  validateAPICompletion(operation, NSDictionary, tweet, error);
                  if (error) {
                      [expectation fulfill];
                      return ;
                  }
                  
                  // Check Destroyed tweet
                  [client getStatusesShowWithTweetID:tweetedID
                                            trimUser:NO
                                    includeMyRetweet:YES
                                     includeEntities:YES
                                          completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
                   {
                       XCTAssertEqualObjects(error.domain, TWAPIErrorDomain);
                       XCTAssertEqual(error.code, TWAPIErrorCodeNoStatusFoundWithThatID);
                       XCTAssertEqual(error.tw_HTTPStatusCode, 404);
                       
                       // Duplicate Destroy Tweet
                       [client tw_postStatusesDestroyWithTweetID:tweetedID
                                                      completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
                        {
                            validateAPICompletionAndFulfill(operation, NSNull, [NSNull null], error);
                        }];
                   }];
              }];
         }];
    }];
}

- (void)testUploadMultipleMedia
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSData *media = [Constants imageData];
        
        [client tw_postStatusesUpdateWithStatus:kText
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
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSDictionary, tweet, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             [client tw_postStatusesDestroyWithTweetID:[tweet[@"id"] longLongValue]
                                            completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSNull, [NSNull null], error);
              }];
         }];
    } timeout:60.];
}

- (void)testUploadMultipleMediaWithQuoteTweetText
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSData *media = [Constants imageData];
        
        [client tw_postStatusesUpdateWithStatus:[NSString stringWithFormat:@"%@, QuoteTweet: %@", kText, kAttachmentURL]
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
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSDictionary, tweet, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }

             [client tw_postStatusesDestroyWithTweetID:[tweet[@"id"] longLongValue]
                                            completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSNull, [NSNull null], error);
              }];
         }];
    } timeout:60.];
}

- (void)testUploadMultipleMediaWithEmptyText
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSData *media = [Constants imageData];
        
        [client tw_postStatusesUpdateWithStatus:@""
                                      mediaData:@[media]
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
             
             [client tw_postStatusesDestroyWithTweetID:[tweet[@"id"] longLongValue]
                                            completion:^(TWAPIRequestOperation * __nullable operation, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSNull, [NSNull null], error);
              }];
         }];
    } timeout:60.];
}


#pragma mark - User

- (void)testPostUsersLookup
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        NSArray *userIDs = @[@(kTargetUserID), @(kTargetUserID2)];
        [client tw_postUsersLookupWithUserIDs:userIDs
                                orScreenNames:nil
                              includeEntities:NO
                                   completion:^(TWAPIRequestOperation * _Nullable operation, NSArray * _Nullable users, NSError * _Nullable error)
         {
             XCTAssertNil(error);
             XCTAssertEqual([users count], [userIDs count]);
             
             [expectation fulfill];
         }];
    }];
}

- (void)testPostUsersLookupWithNotExistUsers
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client tw_postUsersLookupWithUserIDs:@[@(1), @(2)]
                                orScreenNames:nil
                              includeEntities:NO
                                   completion:^(TWAPIRequestOperation * _Nullable operation, NSArray * _Nullable users, NSError * _Nullable error)
         {
             XCTAssertNil(users);
             XCTAssertNil(error);
             
             [expectation fulfill];
         }];
    }];
}

#pragma mark - Friends

- (void)testGetAllFriendsIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client tw_getAllFriendsIDsWithUserID:[[client.auth retrieveUserIDFromAccessToken] longLongValue]
                                 orScreenName:nil
                                   completion:^(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * _Nullable userIDs, NSError * _Nullable error)
         {
#if 1
             XCTAssertNil(error);
             XCTAssertGreaterThan([userIDs count], 0);
             NSLog(@"count: %zd", [userIDs count]);
#else
             /* Test rate limit */
             
             XCTAssertNotNil(error);
             TWRateLimit *rateLimit = [error tw_rateLimit];
             XCTAssertNotNil(rateLimit);
             NSLog(@"rateLimit: %@", rateLimit);
             
             XCTAssertGreaterThan([userIDs count], 0);
             
             NSLog(@"userIDs:%@ count: %zd", userIDs, [userIDs count]);
#endif
             [expectation fulfill];
         }];
    }];
}

- (void)testGetAllFollowersIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client tw_getAllFollowersIDsWithUserID:[[client.auth retrieveUserIDFromAccessToken] longLongValue]
                                   orScreenName:nil
                                     completion:^(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * _Nullable userIDs, NSError * _Nullable error)
         {
             XCTAssertNil(error);
             XCTAssertGreaterThan([userIDs count], 0);
             
             [expectation fulfill];
         }];
    }];
}

- (void)testGetAllFriendshipsNoRetweetsIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client tw_getAllFriendshipsNoRetweetsIDsWithCompletion:^(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * _Nullable userIDs, NSError * _Nullable error)
         {
             XCTAssertNil(error);
             XCTAssertGreaterThan([userIDs count], 0);
             
             [expectation fulfill];
         }];
    }];
}

- (void)testGetAllMutesUserIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client tw_getAllMutesUsersIDsWithCompletion:^(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * _Nullable userIDs, NSError * _Nullable error)
         {
             XCTAssertNil(error);
             XCTAssertGreaterThan([userIDs count], 0);
             [expectation fulfill];
         }];
    }];
}

- (void)testGetAllBlocksUserIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client tw_getAllBlocksIDsWithCompletion:^(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * _Nullable userIDs, NSError * _Nullable error)
         {
             XCTAssertNil(error);
             XCTAssertGreaterThan([userIDs count], 0);
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
