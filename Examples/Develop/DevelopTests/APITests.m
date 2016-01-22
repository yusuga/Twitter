//
//  APITests.m
//
//  Created by Yu Sugawara on 4/14/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Twitter.h"
#import "Constants.h"

static TWAPIClient *__apiClient;

static int64_t const kSinceID = 1;
static int64_t const kMaxID = INT64_MAX - 1; // 63bit maximum - 1 is the maximum value

@interface APITests : XCTestCase

@end

@implementation APITests

- (void)setUp
{
    [super setUp];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TWOAuth1Token *token = [[TWOAuth1Token alloc] initWithConsumerKey:[Constants consumerKey]
                                                           consumerSecret:[Constants consumerSecret]
                                                              accessToken:[Constants accessToken]
                                                        accessTokenSecret:[Constants accessTokenSecret]
                                                                   userID:[Constants userID]
                                                               screenName:nil];
        
        __apiClient = [[TWAPIClient alloc] initWithAuth:[TWAuth userAuthWithOAuth1Token:token]];
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Statuses

- (void)testGetStatusesHomeTimeline
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesHomeTimelineWithCount:100
                                         sinceID:kSinceID
                                           maxID:kMaxID
                                        trimUser:YES
                                  excludeReplies:YES
                              contributorDetails:YES
                                 includeEntities:YES
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                          validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                      }];
    }];
}

- (void)testGetStatusesMentionsTimeline
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesMentionsTimelineWithCount:100
                                             sinceID:kSinceID
                                               maxID:kMaxID
                                            trimUser:YES
                                      excludeReplies:YES
                                  contributorDetails:YES
                                     includeEntities:YES
                                          completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                              validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                          }];
    }];
}

- (void)testGetStatusesRetweetsOfMe
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesRetweetsOfMeWithCount:100
                                         sinceID:kSinceID
                                           maxID:kMaxID
                                        trimUser:YES
                                 includeEntities:YES
                             includeUserEntities:YES
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                          validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                      }];
    }];
}

- (void)testGetStatusesUserTimeline
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesUserTimelineWithUserID:kTargetUserID
                                     orScreenName:nil
                                            count:100
                                          sinceID:kSinceID
                                            maxID:kMaxID
                                       completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                           validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                       }];
    }];
}

- (void)testGetStatusesUserTimelineWithScreenName
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesUserTimelineWithUserID:0
                                     orScreenName:kTargetScreenName
                                            count:100
                                          sinceID:kSinceID
                                            maxID:kMaxID
                                       completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                           validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                       }];
    }];
}

- (void)testGetStatusesShow
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesShowWithTweetID:kTargetTweetID
                                  trimUser:YES
                          includeMyRetweet:YES
                           includeEntities:YES
                                completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
                                    validateAPICompletionAndFulfill(operation, NSDictionary, tweet, error);
                                }];
    }];
}

- (void)testGetStatusesLookup
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesLookupWithTweetIDs:@[kTargetTweetIDStr]
                              includeEntities:YES
                                     trimUser:YES
                                   completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                       validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                   }];
    }];
}

- (void)testGetStatusesLookupMapped
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesLookupMappedWithTweetIDs:@[kTargetTweetIDStr]
                                    includeEntities:YES
                                           trimUser:YES
                                         completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable mappedTweets, NSError * __nullable error) {
                                             validateAPICompletionAndFulfill(operation, NSDictionary, mappedTweets, error);
                                         }];
    }];
}

- (void)testPostStatusesUpdateAndPostStatusesDestroy
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
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
             
             [client postStatusesDestroyWithTweetID:[tweet[@"id"] longLongValue]
                                         completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSDictionary, tweet, error);
              }];
         }];
    }];
}

- (void)testPostStatusesUpdateWithRFC2396ReservedString
{    
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client postStatusesUpdateWithStatus:[NSString stringWithFormat:@"%@ RFC2396 :#[]@!$&'()*+,;=?/", kText]
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
             
             [client postStatusesDestroyWithTweetID:[tweet[@"id"] longLongValue]
                                         completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSDictionary, tweet, error);
              }];
         }];
    }];
}

- (void)testPostStatusesUpdateWithMediaAndPostStatusesDestroy
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [client postStatusesUpdateWithMediaWithStatus:kText
                                                media:[Constants imageData]
                                    possiblySensitive:NO
                                    inReplyToStatusID:0
                                             latitude:nil
                                            longitude:nil
                                              placeID:nil
                                   displayCoordinates:NO
                                       uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             NSLog(@"uploadPrgress bytesWritten = %zd, totalBytesWritten = %lld, totalBytesExpectedToWrite = %lld, progress = %f", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
             validateAPICompletion(operation, NSDictionary, tweet, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             [client postStatusesDestroyWithTweetID:[tweet[@"id"] longLongValue]
                                         completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSDictionary, tweet, error);
              }];
         }];
#pragma GCC diagnostic pop
    } timeout:60.];
}

- (void)testPostStatusesRetweetAndUnretweet
{
    int64_t tweetID = kTargetTweetID;
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        // Retweet
        [client postStatusesRetweetWithTweetID:tweetID
                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
         {
             XCTAssertTrue([NSThread isMainThread]);
             XCTAssertNotNil(operation);
             
             if (error) {
                 // Ignore error
                 if (![error.domain isEqualToString:TWAPIErrorDomain] ||
                     (error.code != TWAPIErrorCodeAlreadyRetweeted && error.code != TWAPIErrorCodeStatusIsDuplicate)) {
                     validateAPICompletion(operation, NSNull, [NSNull null], error);
                     [expectation fulfill];
                     return ;
                 }
             }
             
             // Check retweeeted tweet
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
                  
                  // Unretweet
                  [client postStatusesUnretweetWithTweetID:tweetID
                                                  trimUser:NO
                                                completion:^(TWAPIRequestOperation * _Nullable operation, NSDictionary * _Nullable tweet, NSError * _Nullable error)
                   {
                       validateAPICompletion(operation, NSDictionary, tweet, error);
                       if (error) {
                           [expectation fulfill];
                           return ;
                       }
                       
                       // Check unretweeted
                       [client getStatusesShowWithTweetID:tweetID
                                                 trimUser:NO
                                         includeMyRetweet:YES
                                          includeEntities:YES
                                               completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
                        {
                            XCTAssertFalse([tweet[@"retweeted"] boolValue]);
                            [expectation fulfill];
                        }];
                   }];
              }];
         }];
    }];
}

- (void)testGetStatusesRetweets
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesRetweetsWithTweetID:kTargetTweetID
                                         count:100
                                    completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                        validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                    }];
    }];
}

- (void)testGetStatusesRetweeters
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesRetweetersWithTweetID:kTargetTweetID
                                          cursor:0
                                        trimUser:YES
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error) {
                                          validateAPICompletionAndFulfill(operation, NSDictionary, identifiers, error);
                                      }];
    }];
}

- (void)testGetStatusesOembed
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesOembedWithTweetID:kTargetTweetID
                                       orURL:nil
                                    maxwidth:300
                                   hideMedia:YES
                                  hideThread:YES
                                  omitScript:YES
                                       align:@"center"
                                     related:nil
                                        lang:nil
                                  widgetType:nil
                                   hideTweet:NO
                                  completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable json, NSError * __nullable error) {
                                      validateAPICompletionAndFulfill(operation, NSDictionary, json, error);
                                  }];
    }];
}

#pragma mark - Media

- (void)testPostMediaUpload
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client postMediaUploadWithMedia:[Constants imageData]
                          uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             NSLog(@"uploadPrgress bytesWritten = %zd, totalBytesWritten = %lld, totalBytesExpectedToWrite = %lld, progress = %f", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
         } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable uploadMedia, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSDictionary, uploadMedia, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             NSString *mediaID = uploadMedia[@"media_id_string"];
             XCTAssertNotNil(mediaID);
             
             [client postStatusesUpdateWithStatus:kText
                                inReplyToStatusID:0
                                         mediaIDs:@[mediaID]
                                   uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
              {
                  NSLog(@"uploadPrgress bytesWritten = %zd, totalBytesWritten = %lld, totalBytesExpectedToWrite = %lld, progress = %f", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
              } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
              {
                  validateAPICompletion(operation, NSDictionary, uploadMedia, error);
                  if (error) {
                      [expectation fulfill];
                      return ;
                  }
                  
                  NSNumber *tweetID = tweet[@"id"];
                  XCTAssertNotNil(tweetID);                  
                  
                  [client postStatusesDestroyWithTweetID:tweetID.longLongValue
                                              completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
                   {
                       validateAPICompletionAndFulfill(operation, NSDictionary, tweet, error);
                   }];
              }];
         }];
    } timeout:60.];
}

#pragma mark - Favorites

- (void)testGetFavoritesList
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFavoritesListWithUserID:kTargetUserID
                              orScreenName:nil
                                     count:100
                                   sinceID:kSinceID
                                     maxID:kMaxID
                           includeEntities:YES
                                completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                    validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                }];
    }];
}

- (void)testPostFavoritesCreateAndPostFavoritesDestroy
{
    int64_t tweetID = kTargetTweetID;
    
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        // Favorite
        [client postFavoritesCreateWithTweetID:tweetID
                               includeEntities:YES
                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
         {
             XCTAssertTrue([NSThread isMainThread]);
             XCTAssertNotNil(operation);
             
             if (error) {
                 // Ignore error
                 if (![error.domain isEqualToString:TWAPIErrorDomain] || error.code != TWAPIErrorCodeAlreadyFavorited) {
                     validateAPICompletion(operation, NSDictionary, tweet, error);
                     [expectation fulfill];
                     return ;
                 }
             }
             
             // Check favorited
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
                  
                  // Unfavorite
                  [client postFavoritesDestroyWithTweetID:tweetID
                                          includeEntities:YES
                                               completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error)
                   {
                       validateAPICompletionAndFulfill(operation, NSDictionary, tweet, error);
                   }];
              }];
         }];
    }];
}

#pragma mark - Search

- (void)testGetSearchTweets
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getSearchTweetsWithQuery:@"apple"
                                   count:100
                                 sinceID:kSinceID
                                   maxID:kMaxID
                              resultType:TWAPISearchResultTypeMixed
                              completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable searchResult, NSError * __nullable error) {
                                  validateAPICompletionAndFulfill(operation, NSDictionary, searchResult, error);
                              }];
    }];
}

#pragma mark - Users

- (void)testGetUsersShow
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUsersShowWithUserID:kTargetUserID
                          orScreenName:nil
                       includeEntities:YES
                            completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error) {
                                validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
                            }];
    }];
}

- (void)testGetUsersLookup
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUsersLookupWithUserIDs:@[kTargetUserIDStr]
                            orScreenNames:nil
                          includeEntities:YES
                               completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error) {
                                   validateAPICompletionAndFulfill(operation, NSArray, users, error);
                               }];
    }];
}

- (void)testGetUsersSearch
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUsersSearchWithQuery:kTargetScreenName
                                  count:100
                                   page:0
                        includeEntities:YES
                             completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error) {
                                 validateAPICompletionAndFulfill(operation, NSArray, users, error);
                             }];
    }];
}

- (void)testGetUsersProfileBanner
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUsersProfileBannerWithUserID:kTargetUserID
                                   orScreenName:nil
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable profileBanner, NSError * __nullable error) {
                                         validateAPICompletionAndFulfill(operation, NSDictionary, profileBanner, error);
                                     }];
    }];
}

- (void)testGetUsersSuggestions
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUsersSuggestionsWithLang:@"en"
                                 completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable suggestions, NSError * __nullable error) {
                                     validateAPICompletionAndFulfill(operation, NSArray, suggestions, error);
                                 }];
    }];
}

- (void)testGetUsersSuggestionsSlug
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUsersSuggestionsSlugWithSlug:kSlug
                                           lang:nil
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable suggestedUsers, NSError * __nullable error) {
                                         validateAPICompletionAndFulfill(operation, NSDictionary, suggestedUsers, error);
                                     }];
    }];
}

- (void)testGetUsersSuggestionsSlugMembers
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUsersSuggestionsSlugMembersWithSlug:kSlug
                                            completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error) {
                                                validateAPICompletionAndFulfill(operation, NSArray, users, error);
                                            }];
    }];
}

- (void)testPostUsersReportSpam
{
    
}

#pragma mark - Account

- (void)testPostAccountUpdateProfile
{
    
}

- (void)testPostAccountUpdateProfileImage
{
    
}

- (void)testPostAccountUpdateProfileBackgroundImage
{
    
}

- (void)testPostAccountUpdateProfileBanner
{
    
}

- (void)testPostAccountRemoveProfileBanner
{
    
}

- (void)testGetAccountSettings
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getAccountSettingsWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable settings, NSError * __nullable error) {
            validateAPICompletionAndFulfill(operation, NSDictionary, settings, error);
        }];
    }];
}

- (void)testPostAccountSettings
{
    
}

- (void)testPostAccountUpdateDeliveryDevice
{
    
}

- (void)testGetAccountVerifyCredentials
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getAccountVerifyCredentialsWithIncludeEntites:YES
                                                   skipStatus:YES
                                                   completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error) {
                                                       validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
                                                   }];
    }];
}

#pragma mark - Friendships

- (void)testGetFriendshipsShow
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFriendshipsShowWithSourceID:kTargetUserID
                            orSourceScreenName:nil
                                      targetID:kTargetUserID2
                            orTargetScreenName:nil
                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable relationship, NSError * __nullable error) {
                                        validateAPICompletionAndFulfill(operation, NSDictionary, relationship, error);
                                    }];
    }];
}

- (void)testGetFriendshipsLookup
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFriendshipsLookupWithUserIDs:@[kTargetUserIDStr]
                                  orScreenNames:nil
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable friendships, NSError * __nullable error) {
                                         validateAPICompletionAndFulfill(operation, NSArray, friendships, error);
                                     }];
    }];
}

- (void)testPostFriendshipsCreateAndPostFriendshipsDestroy
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        int64_t sourceUserID = client.auth.userID.longLongValue;
        XCTAssertGreaterThan(sourceUserID, 0);
        int64_t targetUserID = kTargetUserID;
        
        NSString *followingKeyPath = @"relationship.source.following";
        
        /*  Unfollow -> Follow -> Unfollow -> Follow */
        
        // Unfollow
        [client postFriendshipsDestroyWithUserID:targetUserID
                                    orScreenName:nil
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSDictionary, user, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             // Verify unfollowing
             [client getFriendshipsShowWithSourceID:sourceUserID
                                 orSourceScreenName:nil
                                           targetID:targetUserID
                                 orTargetScreenName:nil
                                         completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable friendship, NSError * __nullable error)
              {
                  validateAPICompletion(operation, NSDictionary, friendship, error);
                  BOOL following = [[friendship valueForKeyPath:followingKeyPath] boolValue];
                  XCTAssertFalse(following, @"friendship = %@", friendship);
                  if (error || following) {
                      [expectation fulfill];
                      return ;
                  }
                  
                  //
                  [NSThread sleepForTimeInterval:5.];
                  
                  // Follow
                  [client postFriendshipsCreateWithUserID:targetUserID
                                             orScreenName:nil
                                               completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
                   {
                       validateAPICompletion(operation, NSDictionary, user, error);
                       if (error) {
                           [expectation fulfill];
                           return ;
                       }
                       
                       // Duplicate follow request
                       [client postFriendshipsCreateWithUserID:targetUserID
                                                  orScreenName:nil
                                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
                        {
                            validateAPICompletion(operation, NSDictionary, user, error);
                            if (error) {
                                [expectation fulfill];
                                return ;
                            }
                            
                            // Verify following
                            [client getFriendshipsShowWithSourceID:sourceUserID
                                                orSourceScreenName:nil
                                                          targetID:targetUserID
                                                orTargetScreenName:nil
                                                        completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable friendship, NSError * __nullable error)
                             {
                                 validateAPICompletion(operation, NSDictionary, friendship, error);
                                 BOOL following = [[friendship valueForKeyPath:followingKeyPath] boolValue];
                                 XCTAssertTrue(following, @"friendship = %@", friendship);
                                 if (error || !following) {
                                     [expectation fulfill];
                                     return ;
                                 }
                                 
                                 [NSThread sleepForTimeInterval:5.];
                                 
                                 // Unfollow
                                 [client postFriendshipsDestroyWithUserID:targetUserID
                                                             orScreenName:nil
                                                               completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
                                  {
                                      validateAPICompletion(operation, NSDictionary, user, error);
                                      if (error) {
                                          [expectation fulfill];
                                          return ;
                                      }
                                      
                                      // Duplicate unfollow request
                                      [client postFriendshipsDestroyWithUserID:targetUserID
                                                                  orScreenName:nil
                                                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
                                       {
                                           validateAPICompletion(operation, NSDictionary, user, error);
                                           if (error) {
                                               [expectation fulfill];
                                               return ;
                                           }
                                           
                                           // Verify unfollowing
                                           [client getFriendshipsShowWithSourceID:sourceUserID
                                                               orSourceScreenName:nil
                                                                         targetID:targetUserID
                                                               orTargetScreenName:nil
                                                                       completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable friendship, NSError * __nullable error)
                                            {
                                                validateAPICompletion(operation, NSDictionary, friendship, error);
                                                BOOL following = [[friendship valueForKeyPath:followingKeyPath] boolValue];
                                                XCTAssertFalse(following, @"friendship = %@", friendship);
                                                if (error || following) {
                                                    [expectation fulfill];
                                                    return ;
                                                }
                                                
                                                [NSThread sleepForTimeInterval:5.];
                                                
                                                // Follow
                                                [client postFriendshipsCreateWithUserID:targetUserID
                                                                           orScreenName:nil
                                                                             completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
                                                 {
                                                     validateAPICompletion(operation, NSDictionary, user, error);
                                                     if (error) {
                                                         [expectation fulfill];
                                                         return ;
                                                     }
                                                     
                                                     // Verify following
                                                     [client getFriendshipsShowWithSourceID:sourceUserID
                                                                         orSourceScreenName:nil
                                                                                   targetID:targetUserID
                                                                         orTargetScreenName:nil
                                                                                 completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable friendship, NSError * __nullable error)
                                                      {
                                                          validateAPICompletion(operation, NSDictionary, friendship, error);
                                                          BOOL following = [[friendship valueForKeyPath:followingKeyPath] boolValue];
                                                          XCTAssertTrue(following, @"friendship = %@", friendship);
                                                          
                                                          [expectation fulfill];
                                                      }];
                                                 }];
                                            }];
                                       }];
                                  }];
                             }];
                        }];
                   }];
              }];
         }];
    } timeout:60.];
}

- (void)testPostFriendshipsUpdate
{
    
}

- (void)testGetFriendshipsNoRetweetsIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFriendshipsNoRetweetsIDsWithStringifyIDs:YES
                                                 completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable userIDs, NSError * __nullable error) {
                                                     validateAPICompletionAndFulfill(operation, NSArray, userIDs, error);
                                                 }];
    }];
}

- (void)testGetFriendshipsIncoming
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFriendshipsIncomingWithCursor:0
                                    stringifyIDs:YES
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error) {
                                          validateAPICompletionAndFulfill(operation, NSDictionary, identifiers, error);
                                      }];
    }];
}

- (void)testGetFriendshipsOutgoing
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFriendshipsOutgoingWithCursor:0
                                    stringifyIDs:YES
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error) {
                                          validateAPICompletionAndFulfill(operation, NSDictionary, identifiers, error);
                                      }];
    }];
}

#pragma mark - Friends

- (void)testGetFriendsIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFriendsIDsWithUserID:kTargetUserID
                           orScreenName:nil
                                  count:100
                                 cursor:0
                           stringifyIDs:NO
                             completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error) {
                                 validateAPICompletionAndFulfill(operation, NSDictionary, identifiers, error);
                             }];
    }];
}

- (void)testGetFriendsList
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFriendsListWithUserID:kTargetUserID
                            orScreenName:nil
                                   count:100
                                  cursor:0
                              skipStatus:YES
                     includeUserEntities:YES
                              completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                  validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                              }];
    }];
}

#pragma mark - Followers

- (void)testGetFollowersIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFollowersIDsWithUserID:kTargetUserID
                             orScreenName:nil
                                    count:100
                                   cursor:0
                             stringifyIDs:YES
                               completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error) {
                                   validateAPICompletionAndFulfill(operation, NSDictionary, identifiers, error);
                               }];
    }];
}

- (void)testGetFollowersList
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getFollowersListWithUserID:kTargetUserID
                              orScreenName:nil
                                     count:100
                                    cursor:0
                                skipStatus:YES
                       includeUserEntities:YES
                                completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                    validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                                }];
    }];
}

#pragma mark - Lists

- (void)testGetListsStatusesWithListID
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsStatusesWithListID:@(kListID)
                                     count:@(100)
                                   sinceID:@(kSinceID)
                                     maxID:@(kMaxID)
                           includeEntities:@YES
                                includeRTs:@YES
                                completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                    validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                                }];
    }];
}

- (void)testGetListsStatusesWithSlug
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsStatusesWithSlug:kListSlug
                                 ownerID:@(kListOwnerID)
                       orOwnerScreenName:nil
                                   count:@(100)
                                 sinceID:@(kSinceID)
                                   maxID:@(kMaxID)
                         includeEntities:@YES
                              includeRTs:@YES
                              completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error) {
                                  validateAPICompletionAndFulfill(operation, NSArray, tweets, error);
                              }];
    }];
}

- (void)testGetListsShowWithListID
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsShowWithListID:@(kListID)
                            completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error) {
                                validateAPICompletionAndFulfill(operation, NSDictionary, list, error);
                            }];
    }];
}

- (void)testGetListsShowWithSlug
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsShowWithSlug:kListSlug
                             ownerID:@(kListOwnerID)
                   orOwnerScreenName:nil
                          completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error) {
                              validateAPICompletionAndFulfill(operation, NSDictionary, list, error);
                          }];
    }];
}

- (void)testPostListsCreate
{
    
}

- (void)testPostListsUpdateWithListID
{
    
}

- (void)testPostListsUpdateWithSlug
{
    
}

- (void)testPostListsDestroyWithListID
{
    
}

- (void)testPostListsDestroyWithSlug
{
    
}

- (void)testGetListsMembersWithListID
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsMembersWithListID:@(kListID)
                                    count:@(100)
                                   cursor:nil
                          includeEntities:@YES
                               skipStatus:@YES
                               completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                   validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                               }];
    }];
}

- (void)testGetListsMembersWithSlug
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsMembersWithSlug:kListSlug
                                ownerID:@(kListOwnerID)
                      orOwnerScreenName:nil
                                  count:@(100)
                                 cursor:nil
                        includeEntities:@YES
                             skipStatus:@YES
                             completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                 validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                             }];
    }];
}

- (void)testGetListsMembersShowWithListID
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsMembersShowWithListID:@(kListID)
                                       userID:@(kListMemberID)
                                 orScreenName:nil
                              includeEntities:@YES
                                   skipStatus:@YES
                                   completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error) {
                                       validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
                                   }];
    }];
}

- (void)testGetListsMembersShowWithSlug
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsMembersShowWithSlug:kListSlug
                                    ownerID:@(kListOwnerID)
                          orOwnerScreenName:nil
                                     userID:@(kListMemberID)
                               orScreenName:nil
                            includeEntities:@YES
                                 skipStatus:@YES
                                 completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error) {
                                     validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
                                 }];
    }];
}

- (void)testPostListsMembersCreateWithListID
{
    
}

- (void)testPostListsMembersCreateWithSlug
{
    
}

- (void)testPostListsMembersCreateAllWithListID
{
    
}

- (void)testPostListsMembersCreateAllWithSlug
{
    
}

- (void)testPostListsMembersDestroyWithListID
{
    
}

- (void)testPostListsMembersDestroyWithSlug
{
    
}

- (void)testPostListsMembersDestroyAllWithListID
{
    
}

- (void)testPostListsMembersDestroyAllWithSlug
{
    
}

- (void)testGetListsSubscribersWithListID
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsSubscribersWithListID:@(kListID)
                                        count:@(100)
                                       cursor:nil
                              includeEntities:@YES
                                   skipStatus:@YES
                                   completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                       validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                                   }];
    }];
}

- (void)testGetListsSubscribersWithSlug
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsSubscribersWithSlug:kListSlug
                                    ownerID:@(kListOwnerID)
                          orOwnerScreenName:nil
                                      count:@(100)
                                     cursor:0
                            includeEntities:@YES
                                 skipStatus:@YES
                                 completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                     validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                                 }];
    }];
}

- (void)testGetListsSubscribersShowWithListID
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsSubscribersShowWithListID:@(kListID)
                                           userID:@(kListUserID)
                                     orScreenName:nil
                                  includeEntities:nil
                                       skipStatus:nil
                                       completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error) {
                                           validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
                                       }];
    }];
}

- (void)testGetListsSubscribersShowWithSlug
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsSubscribersShowWithSlug:kListSlug
                                        ownerID:@(kListOwnerID)
                              orOwnerScreenName:nil
                                         userID:@(kListUserID)
                                   orScreenName:nil
                                includeEntities:nil
                                     skipStatus:nil
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error) {
                                         validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
                                     }];
    }];
}

- (void)testPostListsSubscribersCreateWithListID
{
    
}

- (void)testPostListsSubscribersCreateWithSlug
{
    
}

- (void)testPostListsSubscribersDestroyWithListID
{
    
}

- (void)testPostListsSubscribersDestroyWithSlug
{
    
}

- (void)testGetListsList
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsListWithUserID:@(kTargetUserID)
                          orScreenName:nil
                               reverse:nil
                            completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable lists, NSError * __nullable error) {
                                validateAPICompletionAndFulfill(operation, NSArray, lists, error);
                            }];
    }];
}

- (void)testGetListsOwnerships
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsOwnershipsWithUserID:@(kTargetUserID)
                                orScreenName:nil
                                       count:nil
                                      cursor:nil
                                  completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error) {
                                      validateAPICompletionAndFulfill(operation, NSDictionary, lists, error);
                                  }];
    }];
}

- (void)testGetListsSubscriptions
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsSubscriptionsWithUserID:@(kTargetUserID)
                                   orScreenName:nil
                                          count:nil
                                         cursor:nil
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error) {
                                         validateAPICompletionAndFulfill(operation, NSDictionary, lists, error);
                                     }];
    }];
}

- (void)testGetListsMemberships
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getListsMembershipsWithUserID:@(kTargetUserID)
                                 orScreenName:nil
                                        count:nil
                                       cursor:nil
                           filterToOwnedLists:nil
                                   completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error) {
                                       validateAPICompletionAndFulfill(operation, NSDictionary, lists, error);
                                   }];
    }];
}

#pragma mark - Blocks

- (void)testGetBlocksList
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getBlocksListWithCursor:0
                        includeEntities:YES
                             skipStatus:YES
                             completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                 validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                             }];
    }];
}

- (void)testGetBlocksIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getBlocksIDsWithCursor:0
                          stringifyIDs:YES
                            completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error) {
                                validateAPICompletionAndFulfill(operation, NSDictionary, identifiers, error);
                            }];
    }];
}

- (void)testPostBlocksCreateAndPostBlocksDestroy
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client postBlocksCreateWithUserID:kTargetUserID
                              orScreenName:nil
                           includeEntities:YES
                                skipStatus:NO
                                completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSDictionary, user, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             [client postBlocksDestroyWithUserID:kTargetUserID
                                    orScreenName:nil
                                 includeEntities:YES
                                      skipStatus:NO
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
              }];
         }];
    }];
}

#pragma mark - Mutes

- (void)testGetMutesUsersList
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getMutesUsersListWithCursor:0
                            includeEntities:YES
                                 skipStatus:YES
                                 completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error) {
                                     validateAPICompletionAndFulfill(operation, NSDictionary, users, error);
                                 }];
    }];
}

- (void)testGetMutesUsersIDs
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getMutesUsersIDsWithCursor:0
                              stringifyIDs:YES
                                completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error) {
                                    validateAPICompletionAndFulfill(operation, NSDictionary, identifiers, error);
                                }];
    }];
}

- (void)testPostMutesUsersCreateAndPostMutesUsersDestroy
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client postMutesUsersCreateWithUserID:kTargetUserID
                                  orScreenName:nil
                                    completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
         {
             validateAPICompletion(operation, NSDictionary, user, error);
             if (error) {
                 [expectation fulfill];
                 return ;
             }
             
             [client postMutesUsersDestroyWithUserID:kTargetUserID
                                        orScreenName:nil
                                     includeEntities:YES
                                          skipStatus:NO
                                          completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error)
              {
                  validateAPICompletionAndFulfill(operation, NSDictionary, user, error);
              }];
         }];
    }];
}

#pragma mark - Saved Searches

- (void)testGetSavedSearchesList
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getSavedSearchesListWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable savedSearches, NSError * __nullable error) {
            validateAPICompletionAndFulfill(operation, NSArray, savedSearches, error);
        }];
    }];
}

- (void)testGetSavedSearchesShowIDWithSavedSearchID
{
    
}

- (void)testPostSavedSearchesCreate
{
    
}

- (void)testPostSavedSearchesDestroyID
{
    
}

#pragma mark - Trends

- (void)testGetTrendsPlace
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getTrendsPlaceWithWOEID:kWOEID
                             completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trends, NSError * __nullable error) {
                                 validateAPICompletionAndFulfill(operation, NSArray, trends, error);
                             }];
    }];
}

- (void)testGetTrendsAvailable
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getTrendsAvailableWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trendLocations, NSError * __nullable error) {
            validateAPICompletionAndFulfill(operation, NSArray, trendLocations, error);
        }];
    }];
}

- (void)testGetTrendsClosest
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getTrendsClosestWithLatitude:kLatitude
                                   longitude:kLongitude
                                  completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trendLocations, NSError * __nullable error) {
                                      validateAPICompletionAndFulfill(operation, NSArray, trendLocations, error);
                                  }];
    }];
}

#pragma mark - Geo

- (void)testGetGeoIDPlaceID
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getGeoIDPlaceIDWithPlaceID:kPlaceID
                                completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable place, NSError * __nullable error) {
                                    validateAPICompletionAndFulfill(operation, NSDictionary, place, error);
                                }];
    }];
}

- (void)testGetGeoReverseGeocode
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getGeoReverseGeocodeWithLatitude:kLatitude
                                       longitude:kLongitude
                                        accuracy:nil
                                     granularity:nil
                                      maxResults:10
                                        callback:nil
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error) {
                                          validateAPICompletionAndFulfill(operation, NSDictionary, geoResult, error);
                                      }];
    }];
}

- (void)testGetGeoSearch
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getGeoSearchWithLatitude:kLatitude
                               longitude:kLongitude
                                accuracy:nil
                             granularity:nil
                              maxResults:10
                         containedWithin:nil
                  attributeStreetAddress:nil
                                callback:nil
                              completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error) {
                                  validateAPICompletionAndFulfill(operation, NSDictionary, geoResult, error);
                              }];
    }];
}

#pragma mark - Direct Messages

- (void)testGetDirectMessages
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getDirectMessagesWithCount:100
                                   sinceID:kSinceID
                                     maxID:kMaxID
                           includeEntities:YES
                                skipStatus:YES
                                completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable messages, NSError * __nullable error) {
                                    validateAPICompletionAndFulfill(operation, NSArray, messages, error);
                                }];
    }];
}

- (void)testGetDirectMessagesSent
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getDirectMessagesSentWithSinceID:kSinceID
                                           maxID:kMaxID
                                            Page:0
                                 includeEntities:YES
                                      completion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable messages, NSError * __nullable error) {
                                          validateAPICompletionAndFulfill(operation, NSArray, messages, error);
                                      }];
    }];
}

- (void)testGetDirectMessagesShow
{
#if 0
    int64_t messageID = 431778132698226688;
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getDirectMessagesShowWithDirectMessageID:messageID
                                              completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable message, NSError * __nullable error)
         {
             validateAPICompletionAndFulfill(operation, NSDictionary, message, error);
         }];
    }];
#endif
}

- (void)testPostDirectMessagesNew
{
    
}

- (void)testPostDirectMessagesDestroy
{
    
}

#pragma mark - Application

- (void)testGetApplicationRateLimitStatus
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getApplicationRateLimitStatusWithResource:nil
                                               completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable rateLimitStatus, NSError * __nullable error) {
                                                   validateAPICompletionAndFulfill(operation, NSDictionary, rateLimitStatus, error);
                                               }];
    }];
}

#pragma mark - Help

- (void)testGetHelpLanguages
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getHelpLanguagesWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSArray * __nullable languages, NSError * __nullable error) {
            validateAPICompletionAndFulfill(operation, NSArray, languages, error);
        }];
    }];
}

- (void)testGetHelpConfiguration
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getHelpConfigurationWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable configuration, NSError * __nullable error) {
            validateAPICompletionAndFulfill(operation, NSDictionary, configuration, error);
        }];
    }];
}

- (void)testGetHelpPrivacy
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getHelpPrivacyWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable privacy, NSError * __nullable error) {
            validateAPICompletionAndFulfill(operation, NSDictionary, privacy, error);
        }];
    }];
}

- (void)testGetHelpToS
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getHelpToSWithCompletion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tos, NSError * __nullable error) {
            validateAPICompletionAndFulfill(operation, NSDictionary, tos, error);
        }];
    }];
}

#pragma mark - Public Stream

- (void)testGetStatusesSample
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getStatusesSampleWithStream:^(TWAPIRequestOperation * __nonnull operation, NSDictionary * __nonnull json, TWStreamJSONType type) {
            NSLog(@"type = %@", NSStringFromTWStreamJSONType(type));
            static NSUInteger __count;
            if (__count++ == 10) {
                [operation cancel];
                [expectation fulfill];
            }
        } failure:^(TWAPIRequestOperation * __nonnull operation, NSError * __nonnull error) {
            XCTFail(@"errro = %@", error);
            [expectation fulfill];
        }];
    } timeout:120.];
}

- (void)testPostStatuesesFilter
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client postStatusesFilterWithKeywords:@[@"is"]
                                 followUserIDs:nil
                                     locations:nil
                                        stream:^(TWAPIRequestOperation * __nonnull operation, NSDictionary * __nonnull json, TWStreamJSONType type)
         {
             NSLog(@"type = %@", NSStringFromTWStreamJSONType(type));
             static NSUInteger __count;
             if (__count++ == 10) {
                 [operation cancel];
                 [expectation fulfill];
             }
         } failure:^(TWAPIRequestOperation * __nonnull operation, NSError * __nonnull error) {
             XCTFail(@"errro = %@", error);
             [expectation fulfill];
         }];
    } timeout:120.];
}

#pragma mark - User Streams

- (void)testGetUser
{
    [self clientAsyncTestBlock:^(TWAPIClient *client, XCTestExpectation *expectation) {
        [client getUserWithUserOnly:NO
                         allReplies:YES
                          locations:nil
                 stringifyFriendIDs:YES
                             stream:^(TWAPIRequestOperation * __nonnull operation, NSDictionary * __nonnull json, TWStreamJSONType type)
         {
             NSLog(@"type = %@", NSStringFromTWStreamJSONType(type));
#if 0
             [operation cancel];
             [expectation fulfill];
#else
             static NSUInteger __count;
             if (__count++ == 2) {
                 [operation cancel];
                 [expectation fulfill];
             }
#endif
         } failure:^(TWAPIRequestOperation * __nonnull operation, NSError * __nonnull error) {
             XCTFail(@"errro = %@", error);
             [expectation fulfill];
         }];
    } timeout:120.];
}

#pragma mark - Site Streams

#pragma mark - Firehose

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
