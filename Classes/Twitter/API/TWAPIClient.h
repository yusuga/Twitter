//
//  TWAPIClient.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWAPIRequestOperation.h"
#import "TWAuthModels.h"
#import "TWStreamParser.h"
#import "TWConstants.h"
@class TWAuth;

/**
 *  Public API
 *  https://dev.twitter.com/rest/public
 *
 *  Rate Limits: Chart
 *  https://dev.twitter.com/rest/public/rate-limits
 *  Twitter limits (API, updates, and following)
 *  https://support.twitter.com/articles/15364-twitter-limits-api-updates-and-following
 *
 *  The Streaming APIs Overview
 *  https://dev.twitter.com/streaming/overview
 *
 *  Yahoo! GeoPlanet Guide - WOEID
 *  https://developer.yahoo.com/geo/geoplanet/guide/concepts.html
 */

NS_ASSUME_NONNULL_BEGIN
@interface TWAPIClient : NSObject

- (instancetype)initWithAuth:(TWAuth *)auth;
@property (nonatomic, readonly) TWAuth *auth;

#pragma mark - Request

- (TWAPIRequestOperation * __nullable)sendRequestWithHTTPMethod:(NSString *)HTTPMethod
                                                  baseURLString:(NSString *)baseURLString
                                              relativeURLString:(NSString *)relativeURLString
                                                     parameters:(NSDictionary * __nullable)parameters
                                                    willRequest:(void (^ __nullable)(NSMutableURLRequest *request) )willRequest
                                                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                               downloadProgress:(void (^ __nullable)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) downloadProgress
                                                         stream:(void (^ __nullable)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)GET:(NSString *)relativeURLString
                    parameters:(NSDictionary * __nullable)parameters
                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)POST:(NSString *)relativeURLString
                     parameters:(NSDictionary * __nullable)parameters
                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)POST:(NSString *)relativeURLString
                     parameters:(NSDictionary * __nullable)parameters
                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (void)cancelAllRequests;

#pragma mark - Statuses

/**
 *  GET statuses/home_timeline
 *  https://dev.twitter.com/rest/reference/get/statuses/home_timeline
 */

- (TWAPIRequestOperation *)getStatusesHomeTimelineWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                   trimUser:(BOOL)trimUser
                                             excludeReplies:(BOOL)excludeReplies
                                         contributorDetails:(BOOL)contributorDetails
                                            includeEntities:(BOOL)includeEntities
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesHomeTimelineWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/mentions_timeline
 *  https://dev.twitter.com/rest/reference/get/statuses/mentions_timeline
 */

- (TWAPIRequestOperation *)getStatusesMentionsTimelineWithCount:(NSUInteger)count
                                                        sinceID:(int64_t)sinceID
                                                          maxID:(int64_t)maxID
                                                       trimUser:(BOOL)trimUser
                                                 excludeReplies:(BOOL)excludeReplies
                                             contributorDetails:(BOOL)contributorDetails
                                                includeEntities:(BOOL)includeEntities
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesMentionsTimelineWithCount:(NSUInteger)count
                                                        sinceID:(int64_t)sinceID
                                                          maxID:(int64_t)maxID
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/retweets_of_me
 *  https://dev.twitter.com/rest/reference/get/statuses/retweets_of_me
 */

- (TWAPIRequestOperation *)getStatusesRetweetsOfMeWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                   trimUser:(BOOL)trimUser
                                            includeEntities:(BOOL)includeEntities
                                        includeUserEntities:(BOOL)includeUserEntities
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesRetweetsOfMeWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/user_timeline
 *  https://dev.twitter.com/rest/reference/get/statuses/user_timeline
 */

- (TWAPIRequestOperation *)getStatusesUserTimelineWithUserID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                                       count:(NSUInteger)count
                                                     sinceID:(int64_t)sinceID
                                                       maxID:(int64_t)maxID
                                                    trimUser:(BOOL)trimUser
                                              excludeReplies:(BOOL)excludeReplies
                                          contributorDetails:(BOOL)contributorDetails
                                                  includeRTs:(BOOL)includeRTs
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesUserTimelineWithUserID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                                       count:(NSUInteger)count
                                                     sinceID:(int64_t)sinceID
                                                       maxID:(int64_t)maxID
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/show/:id
 *  https://dev.twitter.com/rest/reference/get/statuses/show/%3Aid
 */

- (TWAPIRequestOperation *)getStatusesShowWithTweetID:(int64_t)tweetID
                                             trimUser:(BOOL)trimUser
                                     includeMyRetweet:(BOOL)includeMyRetweet
                                      includeEntities:(BOOL)includeEntities
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesShowWithTweetID:(int64_t)tweetID
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/lookup
 *  https://dev.twitter.com/rest/reference/get/statuses/lookup
 *
 *  Returns fully-hydrated tweet objects for up to 100 tweets per request, as specified by comma-separated values passed to the id parameter.
 *
 */

- (TWAPIRequestOperation *)getStatusesLookupWithTweetIDs:(NSArray *)tweetIDs
                                         includeEntities:(BOOL)includeEntities
                                                trimUser:(BOOL)trimUser
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesLookupWithTweetIDs:(NSArray *)tweetIDs
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesLookupMappedWithTweetIDs:(NSArray *)tweetIDs
                                               includeEntities:(BOOL)includeEntities
                                                      trimUser:(BOOL)trimUser
                                                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable mappedTweets, NSError * __nullable error))completion;

#pragma mark -

/**
 *  POST statuses/update
 *  https://dev.twitter.com/rest/reference/post/statuses/update
 */

- (TWAPIRequestOperation *)postStatusesUpdateWithStatus:(NSString *)status
                                      inReplyToStatusID:(int64_t)inReplyToStatusID
                                      possiblySensitive:(BOOL)possiblySensitive
                                               latitude:(NSString * __nullable)latitude
                                              longitude:(NSString * __nullable)longitude
                                                placeID:(NSString * __nullable)placeID
                                     displayCoordinates:(BOOL)displayCoordinates
                                               trimUser:(BOOL)trimUser
                                               mediaIDs:(NSArray * __nullable)mediaIDs
                                         uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postStatusesUpdateWithStatus:(NSString *)status
                                      inReplyToStatusID:(int64_t)inReplyToStatusID
                                         uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postStatusesUpdateWithStatus:(NSString *)status
                                      inReplyToStatusID:(int64_t)inReplyToStatusID
                                               mediaIDs:(NSArray *)mediaIDs
                                         uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

#pragma mark -

/**
 *  POST statuses/update_with_media
 *  https://dev.twitter.com/rest/reference/post/statuses/update_with_media
 */

- (TWAPIRequestOperation *)postStatusesUpdateWithMediaWithStatus:(NSString *)status
                                                           media:(NSData *)media
                                               possiblySensitive:(BOOL)possiblySensitive
                                               inReplyToStatusID:(int64_t)inReplyToStatusID
                                                        latitude:(NSString * __nullable)latitude
                                                       longitude:(NSString * __nullable)longitude
                                                         placeID:(NSString * __nullable)placeID
                                              displayCoordinates:(BOOL)displayCoordinates
                                                  uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                      completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion __attribute__((deprecated("This endpoint has been DEPRECATED. Please use POST statuses/update for uploading one or more media entities.")));

#pragma mark -

/**
 *  POST statuses/retweet/:id
 *  https://dev.twitter.com/rest/reference/post/statuses/retweet/%3Aid
 */

- (TWAPIRequestOperation *)postStatusesRetweetWithTweetID:(int64_t)tweetID
                                                 trimUser:(BOOL)trimUser
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postStatusesRetweetWithTweetID:(int64_t)tweetID
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

#pragma mark -

/**
 *  POST statuses/destroy/:id
 *  https://dev.twitter.com/rest/reference/post/statuses/destroy/%3Aid
 */

- (TWAPIRequestOperation *)postStatusesDestroyWithTweetID:(int64_t)tweetID
                                                 trimUser:(BOOL)trimUser
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postStatusesDestroyWithTweetID:(int64_t)tweetID
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/retweets/:id
 *  https://dev.twitter.com/rest/reference/get/statuses/retweets/%3Aid
 */

- (TWAPIRequestOperation *)getStatusesRetweetsWithTweetID:(int64_t)tweetID
                                                    count:(NSUInteger)count
                                                 trimUser:(BOOL)trimUser
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getStatusesRetweetsWithTweetID:(int64_t)tweetID
                                                    count:(NSUInteger)count
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/retweeters/ids
 *  https://dev.twitter.com/rest/reference/get/statuses/retweeters/ids
 */

- (TWAPIRequestOperation *)getStatusesRetweetersWithTweetID:(int64_t)tweetID
                                                     cursor:(NSUInteger)count
                                                   trimUser:(BOOL)trimUser
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET statuses/oembed
 *  https://dev.twitter.com/rest/reference/get/statuses/oembed
 */

- (TWAPIRequestOperation *)getStatusesOembedWithTweetID:(int64_t)tweetID
                                                  orURL:(NSString * __nullable)tweetURLString
                                               maxwidth:(NSInteger)maxWidth
                                              hideMedia:(BOOL)hideMedia
                                             hideThread:(BOOL)hideThread
                                             omitScript:(BOOL)omitScript
                                                  align:(NSString * __nullable)align
                                                related:(NSString * __nullable)related
                                                   lang:(NSString * __nullable)lang
                                             widgetType:(NSString * __nullable)widgetType
                                              hideTweet:(BOOL)hideTweet
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable json, NSError * __nullable error))completion;

#pragma mark - Media

/**
 *  POST media/upload
 *  https://dev.twitter.com/rest/reference/post/media/upload
 *
 *  Upload media (images) to Twitter, to use in a Tweet or Twitter-hosted Card.
 */

- (TWAPIRequestOperation *)postMediaUploadWithMedia:(NSData *)media
                                     uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable mediaUpload, NSError * __nullable error))completion;

#pragma mark - Favorites

/**
 *  GET favorites/list
 *  https://dev.twitter.com/rest/reference/get/favorites/list
 */

- (TWAPIRequestOperation *)getFavoritesListWithUserID:(int64_t)userID
                                         orScreenName:(NSString * __nullable)screenName
                                                count:(NSUInteger)count
                                              sinceID:(int64_t)sinceID
                                                maxID:(int64_t)maxID
                                      includeEntities:(BOOL)includeEntities
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

/**
 *  POST favorites/create
 *  https://dev.twitter.com/rest/reference/post/favorites/create
 */

- (TWAPIRequestOperation *)postFavoritesCreateWithTweetID:(int64_t)tweetID
                                          includeEntities:(BOOL)includeEntities
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

/**
 *  POST favorites/destroy
 *  https://dev.twitter.com/rest/reference/post/favorites/destroy
 */

- (TWAPIRequestOperation *)postFavoritesDestroyWithTweetID:(int64_t)tweetID
                                           includeEntities:(BOOL)includeEntities
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

#pragma mark - Search

/**
 *  GET search/tweets
 *  https://dev.twitter.com/rest/reference/get/search/tweets
 */

- (TWAPIRequestOperation *)getSearchTweetsWithQuery:(NSString *)query
                                              count:(NSUInteger)count
                                            sinceID:(int64_t)sinceID
                                              maxID:(int64_t)maxID
                                         resultType:(TWAPISearchResultType)resultType
                                            geocode:(NSString * __nullable)geocode
                                               lang:(NSString * __nullable)lang
                                             locale:(NSString * __nullable)locale
                                              until:(NSString * __nullable)until
                                    includeEntities:(BOOL)includeEntities
                                           callback:(NSString * __nullable)callback
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable searchResult, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getSearchTweetsWithQuery:(NSString *)query
                                              count:(NSUInteger)count
                                            sinceID:(int64_t)sinceID
                                              maxID:(int64_t)maxID
                                         resultType:(TWAPISearchResultType)resultType
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable searchResult, NSError * __nullable error))completion;

#pragma mark - Users

/**
 *  GET users/show
 *  https://dev.twitter.com/rest/reference/get/users/show
 */

- (TWAPIRequestOperation *)getUsersShowWithUserID:(int64_t)userID
                                     orScreenName:(NSString * __nullable)screenName
                                  includeEntities:(BOOL)includeEntities
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  GET users/lookup
 *  https://dev.twitter.com/rest/reference/get/users/lookup
 */

- (TWAPIRequestOperation *)getUsersLookupWithUserIDs:(NSArray * __nullable)userIDs
                                       orScreenNames:(NSArray * __nullable)screenNames
                                     includeEntities:(BOOL)includeEntities
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error))completion;

/**
 *  GET users/search
 *  https://dev.twitter.com/rest/reference/get/users/search
 */

- (TWAPIRequestOperation *)getUsersSearchWithQuery:(NSString *)query
                                             count:(NSUInteger)count
                                              page:(NSUInteger)page
                                   includeEntities:(BOOL)includeEntities
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error))completion;

/**
 *  GET users/profile_banner
 *  https://dev.twitter.com/rest/reference/get/users/profile_banner
 */

- (TWAPIRequestOperation *)getUsersProfileBannerWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable profileBanner, NSError * __nullable error))completion;

/**
 *  GET users/suggestions
 *  https://dev.twitter.com/rest/reference/get/users/suggestions
 */

- (TWAPIRequestOperation *)getUsersSuggestionsWithLang:(NSString * __nullable)lang
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable suggestions, NSError * __nullable error))completion;

/**
 *  GET users/suggestions/:slug
 *  https://dev.twitter.com/rest/reference/get/users/suggestions/%3Aslug
 */

- (TWAPIRequestOperation *)getUsersSuggestionsSlugWithSlug:(NSString *)slug
                                                      lang:(NSString * __nullable)lang
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable suggestedUsers, NSError * __nullable error))completion;
/**
 *  GET users/suggestions/:slug/members
 *  https://dev.twitter.com/rest/reference/get/users/suggestions/%3Aslug/members
 */

- (TWAPIRequestOperation *)getUsersSuggestionsSlugMembersWithSlug:(NSString *)slug
                                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error))completion;

/**
 *  POST users/report_spam
 *  https://dev.twitter.com/rest/reference/post/users/report_spam
 */

- (TWAPIRequestOperation *)postUsersReportSpamWithUserID:(int64_t)userID
                                              screenName:(NSString * __nullable)screenName
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

#pragma mark - Acocunt

/**
 *  POST account/update_profile
 *  https://dev.twitter.com/rest/reference/post/account/update_profile
 */

- (TWAPIRequestOperation *)postAccountUpdateProfileWithName:(NSString * __nullable)name
                                                        url:(NSString * __nullable)url
                                                   location:(NSString * __nullable)location
                                                description:(NSString * __nullable)description
                                           profileLinkColor:(NSString * __nullable)profileLinkColor
                                            includeEntities:(BOOL)includeEntities
                                                 skipStatus:(BOOL)skipStatus
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST account/update_profile_image
 *  https://dev.twitter.com/rest/reference/post/account/update_profile_image
 */

- (TWAPIRequestOperation *)postAccountUpdateProfileImageWithImage:(NSData *)image
                                                  includeEntities:(BOOL)includeEntities
                                                       skipStatus:(BOOL)skipStatus
                                                   uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST account/update_profile_background_image
 *  https://dev.twitter.com/rest/reference/post/account/update_profile_background_image
 */

- (TWAPIRequestOperation *)postAccountUpdateProfileBackgroundImageWithImage:(NSData * __nullable)image
                                                            includeEntities:(BOOL)includeEntities
                                                                 skipStatus:(BOOL)skipStatus
                                                                        use:(BOOL)use
                                                             uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST account/update_profile_banner
 *  https://dev.twitter.com/rest/reference/post/account/update_profile_banner
 */

- (TWAPIRequestOperation *)postAccountUpdateProfileBannerWithBanner:(NSData *)banner
                                                              width:(NSString * __nullable)width
                                                             height:(NSString * __nullable)height
                                                         offsetLeft:(NSString * __nullable)offsetLeft
                                                          offsetTop:(NSString * __nullable)offsetTop
                                                     uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST account/remove_profile_banner
 *  https://dev.twitter.com/rest/reference/post/account/remove_profile_banner
 */

- (TWAPIRequestOperation *)postAccountRemoveProfileBannerWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  GET account/settings
 *  https://dev.twitter.com/rest/reference/get/account/settings
 */

- (TWAPIRequestOperation *)getAccountSettingsWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable settings, NSError * __nullable error))completion;

/**
 *  POST account/settings
 *  https://dev.twitter.com/rest/reference/post/account/settings
 */

- (TWAPIRequestOperation *)postAccountSettingsWithSleepTimeEnabled:(BOOL)sleepTimeEnabled
                                                    startSleepTime:(NSString * __nullable)startSleepTime
                                                      endSleepTime:(NSString * __nullable)endSleepTime
                                                          timeZone:(NSString * __nullable)timeZone
                                                trendLocationWOEID:(int32_t)trendLocationWOEID
                                           allowContributorRequest:(NSString * __nullable)allowContributorRequest
                                                              lang:(NSString * __nullable)lang
                                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable settings, NSError * __nullable error))completion;

/**
 *  POST account/update_delivery_device
 *  https://dev.twitter.com/rest/reference/post/account/update_delivery_device
 */

- (TWAPIRequestOperation *)postAccountUpdateDeliveryDeviceWithDevice:(NSString *)device
                                                      includeEntites:(BOOL)includeEntities
                                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable json, NSError * __nullable error))completion;

/**
 *  GET account/verify_credentials
 *  https://dev.twitter.com/rest/reference/get/account/verify_credentials
 */

- (TWAPIRequestOperation *)getAccountVerifyCredentialsWithIncludeEntites:(BOOL)includeEntities
                                                              skipStatus:(BOOL)skipStatus
                                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

#pragma mark - Friendships

/**
 *  GET friendships/show
 *  https://dev.twitter.com/rest/reference/get/friendships/show
 *
 *  Returns detailed information about the relationship between two arbitrary users.
 *  指定のユーザ同士の関係を返します。
 */

- (TWAPIRequestOperation *)getFriendshipsShowWithSourceID:(int64_t)sourceID
                                       orSourceScreenName:(NSString * __nullable)sourceScreenName
                                                 targetID:(int64_t)targetID
                                       orTargetScreenName:(NSString * __nullable)targetScreenName
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable friendship, NSError * __nullable error))completion;

/**
 *  GET friendships/lookup
 *  https://dev.twitter.com/rest/reference/get/friendships/lookup
 *
 *  Returns the relationships of the authenticating user to the comma-separated list of up to 100 screen_names or user_ids provided.
 *  認証ユーザとの関連を返します。
 */

- (TWAPIRequestOperation *)getFriendshipsLookupWithUserIDs:(NSArray * __nullable)userIDs
                                             orScreenNames:(NSArray * __nullable)screenNames
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable friendships, NSError * __nullable error))completion;

/**
 *  POST friendships/create
 *  https://dev.twitter.com/rest/reference/post/friendships/create
 *
 *  Allows the authenticating users to follow the user specified in the ID parameter. If you are already friends with the user a HTTP 403 may be returned, though for performance reasons you may get a 200 OK message even if the friendship already exists. Actions taken in this method are asynchronous and changes will be eventually consistent.
 *  指定のユーザをフォローします。すでにフォローしている場合は`HTTP 403`を返すが、パフォーマンス上の理由からHTTP 200を返す場合があります。アクションは非同期で実行され、最終的に変更は矛盾しないものになる。
 *
 *  Note:
 *  備考: Friendships create/destroyを連続して実行した場合にHTTP 200なのに最終的なフォロー関係が最後に実行したリクエストどおりでないケースがあった。連続するリクエストは避け数秒の間隔を設けた方が安全かもしれない。(リクエストを遅延させ連続実行はキャンセル扱いにするなど)
 */

- (TWAPIRequestOperation *)postFriendshipsCreateWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST friendships/destroy
 *  https://dev.twitter.com/rest/reference/post/friendships/destroy
 *
 *  Allows the authenticating user to unfollow the user specified in the ID parameter.
 *  指定のユーザへのフォローを解除します。
 *
 *  Note: It is not an error in duplicate request. (6/24/15)
 *  備考: `friendships/create`と同様に重複でリクエストをしてもHTTP 200が返される。 (2015/6/24)
 */

- (TWAPIRequestOperation *)postFriendshipsDestroyWithUserID:(int64_t)userID
                                               orScreenName:(NSString * __nullable)screenName
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST friendships/update
 *  https://dev.twitter.com/rest/reference/post/friendships/update
 *
 *  Allows one to enable or disable retweets and device notifications from the specified user.
 */

- (TWAPIRequestOperation *)postFriendshipsUpdateWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                    device:(BOOL)device
                                                  retweets:(BOOL)retweets
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable relationship, NSError * __nullable error))completion;

/**
 *  GET friendships/no_retweets/ids
 *  https://dev.twitter.com/rest/reference/get/friendships/no_retweets/ids
 *
 *  Returns a collection of user_ids that the currently authenticated user does not want to receive retweets from.
 *  認証ユーザのリツイートを受信しないリストを返します。
 */

- (TWAPIRequestOperation *)getFriendshipsNoRetweetsIDsWithStringifyIDs:(BOOL)stringifyIDs
                                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable userIDs, NSError * __nullable error))completion;

/**
 *  GET friendships/incoming
 *  https://dev.twitter.com/rest/reference/get/friendships/incoming
 *
 *  Returns a collection of numeric IDs for every user who has a pending request to follow the authenticating user.
 */

- (TWAPIRequestOperation *)getFriendshipsIncomingWithCursor:(int64_t)cursor
                                               stringifyIDs:(BOOL)stringifyIDs
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion;

/**
 *  GET friendships/outgoing
 *  https://dev.twitter.com/rest/reference/get/friendships/outgoing
 *
 *  Returns a collection of numeric IDs for every protected user for whom the authenticating user has a pending follow request.
 */

- (TWAPIRequestOperation *)getFriendshipsOutgoingWithCursor:(int64_t)cursor
                                               stringifyIDs:(BOOL)stringifyIDs
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion;

#pragma mark - Friends

/**
 *  GET friends/ids
 *  https://dev.twitter.com/rest/reference/get/friends/ids
 */

- (TWAPIRequestOperation *)getFriendsIDsWithUserID:(int64_t)userID
                                      orScreenName:(NSString * __nullable)screenName
                                             count:(NSUInteger)count
                                            cursor:(int64_t)cursor
                                      stringifyIDs:(BOOL)stringifyIDs
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion;

/**
 *  GET friends/list
 *  https://dev.twitter.com/rest/reference/get/friends/list
 */

- (TWAPIRequestOperation *)getFriendsListWithUserID:(int64_t)userID
                                       orScreenName:(NSString * __nullable)screenName
                                              count:(NSUInteger)count
                                             cursor:(int64_t)cursor
                                         skipStatus:(BOOL)skipStatus
                                includeUserEntities:(BOOL)includeUserEntities
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

#pragma mark - Followers

/**
 *  GET followers/ids
 *  https://dev.twitter.com/rest/reference/get/followers/ids
 */

- (TWAPIRequestOperation *)getFollowersIDsWithUserID:(int64_t)userID
                                        orScreenName:(NSString * __nullable)screenName
                                               count:(NSUInteger)count
                                              cursor:(int64_t)cursor
                                        stringifyIDs:(BOOL)stringifyIDs
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion;

/**
 *  GET followers/list
 *  https://dev.twitter.com/rest/reference/get/followers/list
 */

- (TWAPIRequestOperation *)getFollowersListWithUserID:(int64_t)userID
                                         orScreenName:(NSString * __nullable)screenName
                                                count:(NSUInteger)count
                                               cursor:(int64_t)cursor
                                           skipStatus:(BOOL)skipStatus
                                  includeUserEntities:(BOOL)includeUserEntities
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

#pragma mark - Lists

/**
 *  GET lists/statuses
 *  https://dev.twitter.com/rest/reference/get/lists/statuses
 *
 *  Returns a timeline of tweets authored by members of the specified list. Retweets are included by default. Use the include_rts=false parameter to omit retweets.
 *  指定リストに追加されているユーザのツイートを返します(デフォルトはリツートを含む)。includeRTs=NOでリツイートを省略できます。
 */

- (TWAPIRequestOperation *)getListsStatusesWithListID:(int64_t)listID
                                                count:(NSUInteger)count
                                              sinceID:(int64_t)sinceID
                                                maxID:(int64_t)maxID
                                      includeEntities:(BOOL)includeEntities
                                           includeRTs:(BOOL)includeRTs
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getListsStatusesWithSlug:(NSString *)slug
                                            ownerID:(int64_t)ownerID
                                  orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                              count:(NSUInteger)count
                                            sinceID:(int64_t)sinceID
                                              maxID:(int64_t)maxID
                                    includeEntities:(BOOL)includeEntities
                                         includeRTs:(BOOL)includeRTs
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET lists/show
 *  https://dev.twitter.com/rest/reference/get/lists/show
 *
 *  Returns the specified list. Private lists will only be shown if the authenticated user owns the specified list.
 *  指定のリストを返します(認証ユーザの場合のみプライベートリストを指定できます)。
 */

- (TWAPIRequestOperation *)getListsShowWithListID:(int64_t)listID
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getListsShowWithSlug:(NSString *)slug
                                        ownerID:(int64_t)ownerID
                              orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

/**
 *  POST lists/create
 *  https://dev.twitter.com/rest/reference/post/lists/create
 *
 *  Creates a new list for the authenticated user. Note that you can’t create more than 20 lists per account.
 *  新しいリストを作成します(最大20件)。
 */

- (TWAPIRequestOperation *)postListsCreateWithName:(NSString *)name
                                              mode:(NSString * __nullable)mode
                                       description:(NSString * __nullable)description
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

/**
 *  POST lists/update
 *  https://dev.twitter.com/rest/reference/post/lists/update
 *
 *  Updates the specified list. The authenticated user must own the list to be able to update it.
 *  指定のリストを更新します(認証ユーザが作成したリストのみ可能)。
 */

- (TWAPIRequestOperation *)postListsUpdateWithListID:(int64_t)listID
                                                name:(NSString * __nullable)name
                                                mode:(NSString * __nullable)mode
                                         description:(NSString * __nullable)description
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsUpdateWithSlug:(NSString *)slug
                                           ownerID:(int64_t)ownerID
                                 orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                              name:(NSString * __nullable)name
                                              mode:(NSString * __nullable)mode
                                       description:(NSString * __nullable)description
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

/**
 *  POST lists/destroy
 *  https://dev.twitter.com/rest/reference/post/lists/destroy
 *
 *  Deletes the specified list. The authenticated user must own the list to be able to destroy it.
 *  指定のリストを削除します(認証ユーザが作成したリストのみ可能)。
 */

- (TWAPIRequestOperation *)postListsDestroyWithListID:(int64_t)listID
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsDestroyWithSlug:(NSString *)slug
                                            ownerID:(int64_t)ownerID
                                  orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET lists/members
 *  https://dev.twitter.com/rest/reference/get/lists/members
 *
 *  Returns the members of the specified list. Private list members will only be shown if the authenticated user owns the specified list.
 *  指定リストのメンバーを返します。
 */

- (TWAPIRequestOperation *)getListsMembersWithListID:(int64_t)listID
                                               count:(NSUInteger)count
                                              cursor:(int64_t)cursor
                                     includeEntities:(BOOL)includeEntities
                                          skipStatus:(BOOL)skipStatus
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getListsMembersWithSlug:(NSString *)slug
                                           ownerID:(int64_t)ownerID
                                 orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                             count:(NSUInteger)count
                                            cursor:(int64_t)cursor
                                   includeEntities:(BOOL)includeEntities
                                        skipStatus:(BOOL)skipStatus
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

/**
 *  GET lists/members/show
 *  https://dev.twitter.com/rest/reference/get/lists/members/show
 *
 *  Check if the specified user is a member of the specified list.
 *  指定ユーザが指定リストのメンバーかを返します。
 */

- (TWAPIRequestOperation *)getListsMembersShowWithListID:(int64_t)listID
                                                  userID:(int64_t)userID
                                            orScreenName:(NSString * __nullable)screenName
                                         includeEntities:(BOOL)includeEntities
                                              skipStatus:(BOOL)skipStatus
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getListsMembersShowWithSlug:(NSString *)slug
                                               ownerID:(int64_t)ownerID
                                     orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                userID:(int64_t)userID
                                          orScreenName:(NSString * __nullable)screenName
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST lists/members/create
 *  https://dev.twitter.com/rest/reference/post/lists/members/create
 *
 *  Add a member to a list. The authenticated user must own the list to be able to add members to it. Note that lists cannot have more than 5,000 members.
 *  指定リストのメンバーに指定ユーザを追加する(最大5000人)。
 */

- (TWAPIRequestOperation *)postListsMembersCreateWithListID:(int64_t)listID
                                                     userID:(int64_t)userID
                                               orScreenName:(NSString * __nullable)screenName
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsMembersCreateWithSlug:(NSString *)slug
                                                  ownerID:(int64_t)ownerID
                                        orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                   userID:(int64_t)userID
                                             orScreenName:(NSString * __nullable)screenName
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

/**
 *  POST lists/members/create_all
 *  https://dev.twitter.com/rest/reference/post/lists/members/create_all
 *
 *  Adds multiple members to a list, by specifying a comma-separated list of member ids or screen names. The authenticated user must own the list to be able to add members to it. Note that lists can’t have more than 5,000 members, and you are limited to adding up to 100 members to a list at a time with this method.
 *  指定リストのメンバーに指定ユーザを複数人追加する。(一度に100人まで追加可能。最大5000人)
 */

- (TWAPIRequestOperation *)postListsMembersCreateAllWithListID:(int64_t)listID
                                                       userIDs:(NSArray * __nullable)userIDs
                                                 orScreenNames:(NSArray * __nullable)screenNames
                                                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsMembersCreateAllWithSlug:(NSString *)slug
                                                     ownerID:(int64_t)ownerID
                                           orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                     userIDs:(NSArray * __nullable)userIDs
                                               orScreenNames:(NSArray * __nullable)screenNames
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

/**
 *  POST lists/members/destroy
 *  https://dev.twitter.com/rest/reference/post/lists/members/destroy
 *
 *  Removes the specified member from the list. The authenticated user must be the list’s owner to remove members from the list.
 *  指定リストのメンバーから指定ユーザを削除する。
 */

- (TWAPIRequestOperation *)postListsMembersDestroyWithListID:(int64_t)listID
                                                      userID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsMembersDestroyWithSlug:(NSString *)slug
                                                   ownerID:(int64_t)ownerID
                                         orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                    userID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

/**
 *  POST lists/members/destroy_all
 *  https://dev.twitter.com/rest/reference/post/lists/members/destroy_all
 */

- (TWAPIRequestOperation *)postListsMembersDestroyAllWithListID:(int64_t)listID
                                                        userIDs:(NSArray * __nullable)userIDs
                                                  orScreenNames:(NSArray * __nullable)screenNames
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsMembersDestroyAllWithSlug:(NSString *)slug
                                                      ownerID:(int64_t)ownerID
                                            orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                      userIDs:(NSArray * __nullable)userIDs
                                                orScreenNames:(NSArray * __nullable)screenNames
                                                   completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET lists/subscribers
 *  https://dev.twitter.com/rest/reference/get/lists/subscribers
 *
 *  Returns the subscribers of the specified list. Private list subscribers will only be shown if the authenticated user owns the specified list.
 *  指定リストの加入者を返します。
 */

- (TWAPIRequestOperation *)getListsSubscribersWithListID:(int64_t)listID
                                                   count:(NSUInteger)count
                                                  cursor:(int64_t)cursor
                                         includeEntities:(BOOL)includeEntities
                                              skipStatus:(BOOL)skipStatus
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getListsSubscribersWithSlug:(NSString *)slug
                                               ownerID:(int64_t)ownerID
                                     orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                 count:(NSUInteger)count
                                                cursor:(int64_t)cursor
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

/**
 *  GET lists/subscribers/show
 *  https://dev.twitter.com/rest/reference/get/lists/subscribers/show
 *
 *  Check if the specified user is a subscriber of the specified list. Returns the user if they are subscriber.
 *  指定ユーザが指定リストの購読者かを返します。
 */

- (TWAPIRequestOperation *)getListsSubscribersShowWithListID:(int64_t)listID
                                                      userID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                             includeEntities:(BOOL)includeEntities
                                                  skipStatus:(BOOL)skipStatus
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getListsSubscribersShowWithSlug:(NSString *)slug
                                                   ownerID:(int64_t)ownerID
                                         orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                    userID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                           includeEntities:(BOOL)includeEntities
                                                skipStatus:(BOOL)skipStatus
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST lists/subscribers/create
 *  https://dev.twitter.com/rest/reference/post/lists/subscribers/create
 *
 *  Subscribes the authenticated user to the specified list.
 *  指定リストを購読する。
 */

- (TWAPIRequestOperation *)postListsSubscribersCreateWithListID:(int64_t)listID
                                                         userID:(int64_t)userID
                                                   orScreenName:(NSString * __nullable)screenName
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsSubscribersCreateWithSlug:(NSString *)slug
                                                      ownerID:(int64_t)ownerID
                                            orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                       userID:(int64_t)userID
                                                 orScreenName:(NSString * __nullable)screenName
                                                   completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

/**
 *  POST lists/subscribers/destroy
 *  https://dev.twitter.com/rest/reference/post/lists/subscribers/destroy
 */

- (TWAPIRequestOperation *)postListsSubscribersDestroyWithListID:(int64_t)listID
                                                          userID:(int64_t)userID
                                                    orScreenName:(NSString * __nullable)screenName
                                                      completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)postListsSubscribersDestroyWithSlug:(NSString *)slug
                                                       ownerID:(int64_t)ownerID
                                             orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                        userID:(int64_t)userID
                                                  orScreenName:(NSString * __nullable)screenName
                                                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion;
#pragma mark -

/**
 *  GET lists/list
 *  https://dev.twitter.com/rest/reference/get/lists/list
 *
 *  Returns all lists the authenticating or specified user subscribes to, including their own. The user is specified using the user_id or screen_name parameters. If no user is given, the authenticating user is used.
 *  指定ユーザのリストと購読している全てのリストを返します。user_idまたはscreen_nameを指定しなければ認証ユーザのリストを返します。
 */

- (TWAPIRequestOperation *)getListsListWithUserID:(int64_t)userID
                                     orScreenName:(NSString * __nullable)screenName
                                          reverse:(BOOL)reverse
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable lists, NSError * __nullable error))completion;

/**
 *  GET lists/ownerships
 *  https://dev.twitter.com/rest/reference/get/lists/ownerships
 *
 *  Returns the lists owned by the specified Twitter user. Private lists will only be shown if the authenticated user is also the owner of the lists.
 *  指定ユーザのリストを返します(認証ユーザの場合はプライベートリストも含む)。
 */

- (TWAPIRequestOperation *)getListsOwnershipsWithUserID:(int64_t)userID
                                           orScreenName:(NSString * __nullable)screenName
                                                  count:(NSUInteger)count
                                                 cursor:(int64_t)cursor
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error))completion;

/**
 *  GET lists/subscriptions
 *  https://dev.twitter.com/rest/reference/get/lists/subscriptions
 *
 *  Obtain a collection of the lists the specified user is subscribed to, 20 lists per page by default. Does not include the user’s own lists.
 *  指定ユーザが購読しているリストを返します(自身のリストは含まれない)。
 */

- (TWAPIRequestOperation *)getListsSubscriptionsWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                     count:(NSUInteger)count
                                                    cursor:(int64_t)cursor
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error))completion;

/**
 *  GET lists/memberships
 *  https://dev.twitter.com/rest/reference/get/lists/memberships
 *
 *  Returns the lists the specified user has been added to. If user_id or screen_name are not provided the memberships for the authenticating user are returned.
 *  指定ユーザが追加されているリストを返します。user_idまたはscreen_nameを指定しなければ認証ユーザのリストを返します。
 */

- (TWAPIRequestOperation *)getListsMembershipsWithUserID:(int64_t)userID
                                            orScreenName:(NSString * __nullable)screenName
                                                   count:(NSUInteger)count
                                                  cursor:(int64_t)cursor
                                      filterToOwnedLists:(BOOL)filterToOwnedLists
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error))completion;

#pragma mark - Blocks

/**
 *  GET blocks/list
 *  https://dev.twitter.com/rest/reference/get/blocks/list
 *
 *  Returns a collection of user objects that the authenticating user is blocking.
 *  認証ユーザがブロックしているユーザを返します。
 */

- (TWAPIRequestOperation *)getBlocksListWithCursor:(int64_t)cursor
                                   includeEntities:(BOOL)includeEntities
                                        skipStatus:(BOOL)skipStatus
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

/**
 *  GET blocks/ids
 *  https://dev.twitter.com/rest/reference/get/blocks/ids
 *
 *  Returns an array of numeric user ids the authenticating user is blocking.
 *  認証ユーザがブロックしているユーザIDを返します。
 */

- (TWAPIRequestOperation *)getBlocksIDsWithCursor:(int64_t)cursor
                                     stringifyIDs:(BOOL)stringifyIDs
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion;

/**
 *  POST blocks/create
 *  https://dev.twitter.com/rest/reference/post/blocks/create
 *
 *  Blocks the specified user from following the authenticating user. In addition the blocked user will not show in the authenticating users mentions or timeline (unless retweeted by another user). If a follow or friend relationship exists it is destroyed.
 *  指定ユーザをブロックします。ブロックしたユーザのツイートはタイムラインに表示されません(別のユーザがリツートした場合を除く)。フォロー/フォロワー関係は破棄されます。
 */

- (TWAPIRequestOperation *)postBlocksCreateWithUserID:(int64_t)userID
                                         orScreenName:(NSString * __nullable)screenName
                                      includeEntities:(BOOL)includeEntities
                                           skipStatus:(BOOL)skipStatus
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST blocks/destroy
 *  https://dev.twitter.com/rest/reference/post/blocks/destroy
 *
 *  Un-blocks the user specified in the ID parameter for the authenticating user. Returns the un-blocked user in the requested format when successful. If relationships existed before the block was instated, they will not be restored.
 *  指定ユーザのブロックを解除します。ブロック前のフォロー/フォロワー関係は復元しません。
 */

- (TWAPIRequestOperation *)postBlocksDestroyWithUserID:(int64_t)userID
                                          orScreenName:(NSString * __nullable)screenName
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

#pragma mark - Mutes

/**
 *  GET mutes/users/list
 *  https://dev.twitter.com/rest/reference/get/mutes/users/list
 *
 *  Returns an array of user objects the authenticating user has muted.
 *  認証ユーザがミュートしているユーザを返します。
 */

- (TWAPIRequestOperation *)getMutesUsersListWithCursor:(int64_t)cursor
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion;

/**
 *  GET mutes/users/ids
 *  https://dev.twitter.com/rest/reference/get/mutes/users/ids
 *
 *  Returns an array of numeric user ids the authenticating user has muted.
 *  認証ユーザがミュートしているユーザIDを返します。
 */

- (TWAPIRequestOperation *)getMutesUsersIDsWithCursor:(int64_t)cursor
                                         stringifyIDs:(BOOL)stringifyIDs // Undocumented
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion;

/**
 *  POST mutes/users/create
 *  https://dev.twitter.com/rest/reference/post/mutes/users/create
 *
 *  Mutes the user specified in the ID parameter for the authenticating user.
 *  指定ユーザをミュートします。
 */

- (TWAPIRequestOperation *)postMutesUsersCreateWithUserID:(int64_t)userID
                                             orScreenName:(NSString * __nullable)screenName
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

/**
 *  POST mutes/users/destroy
 *  https://dev.twitter.com/rest/reference/post/mutes/users/destroy
 *
 *  Un-mutes the user specified in the ID parameter for the authenticating user.
 *  指定ユーザのミュートを解除します。
 */

- (TWAPIRequestOperation *)postMutesUsersDestroyWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                           includeEntities:(BOOL)includeEntities
                                                skipStatus:(BOOL)skipStatus
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;

#pragma mark - Saved Searches

/**
 *  GET saved_searches/list
 *  https://dev.twitter.com/rest/reference/get/saved_searches/list
 *
 *  Returns the authenticated user’s saved search queries.
 *  認証ユーザが保存している検索クエリを返します。
 */

- (TWAPIRequestOperation *)getSavedSearchesListWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable savedSearches, NSError * __nullable error))completion;

/**
 *  GET saved_searches/show/:id
 *  https://dev.twitter.com/rest/reference/get/saved_searches/show/%3Aid
 *
 *  Retrieve the information for the saved search represented by the given id. The authenticating user must be the owner of saved search ID being requested.
 *  指定の検索保存IDの情報を返します。
 */

- (TWAPIRequestOperation *)getSavedSearchesShowIDWithSavedSearchID:(int64_t)savedSearchID
                                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable savedSearche, NSError * __nullable error))completion;

/**
 *  POST saved_searches/create
 *  https://dev.twitter.com/rest/reference/post/saved_searches/create
 *
 *  Create a new saved search for the authenticated user. A user may only have 25 saved searches.
 *  新しい検索保存を作成します(最大25件)。
 */

- (TWAPIRequestOperation *)postSavedSearchesCreateWithQuery:(NSString *)query
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable savedSearche, NSError * __nullable error))completion;

/**
 *  POST saved_searches/destroy/:id
 *  https://dev.twitter.com/rest/reference/post/saved_searches/destroy/%3Aid
 *
 *  Destroys a saved search for the authenticating user. The authenticating user must be the owner of saved search id being destroyed.
 *  指定の検索保存IDの検索保存を削除します。
 */

- (TWAPIRequestOperation *)postSavedSearchesDestroyIDWithSavedSearchID:(int64_t)savedSearchID
                                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable savedSearche, NSError * __nullable error))completion;

#pragma mark - Trends

/**
 *  GET trends/place
 *  https://dev.twitter.com/rest/reference/get/trends/place
 *
 *  Returns the top 10 trending topics for a specific WOEID, if trending information is available for it.
 *  指定のWOEIDのトレンドを返します。
 */

- (TWAPIRequestOperation *)getTrendsPlaceWithWOEID:(int32_t)woeid
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trends, NSError * __nullable error))completion;

/**
 *  GET trends/available
 *  https://dev.twitter.com/rest/reference/get/trends/available
 *
 *  Returns the locations that Twitter has trending topic information for.
 *  利用可能なトレンド位置情報を返します。
 */

- (TWAPIRequestOperation *)getTrendsAvailableWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trendLocations, NSError * __nullable error))completion;

/**
 *  GET trends/closest
 *  https://dev.twitter.com/rest/reference/get/trends/closest
 *
 *  Returns the locations that Twitter has trending topic information for, closest to a specified location.
 *  指定の位置情報から一番近いトレンド位置情報を返します。
 */

- (TWAPIRequestOperation *)getTrendsClosestWithLatitude:(NSString *)latitude
                                              longitude:(NSString *)longitude
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trendLocations, NSError * __nullable error))completion;

#pragma mark - Geo

/**
 *  GET geo/id/:place_id
 *  https://dev.twitter.com/rest/reference/get/geo/id/%3Aplace_id
 *
 *  Returns all the information about a known place.
 */

- (TWAPIRequestOperation *)getGeoIDPlaceIDWithPlaceID:(NSString *)placeID
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable place, NSError * __nullable error))completion;

/**
 *  GET geo/reverse_geocode
 *  https://dev.twitter.com/rest/reference/get/geo/reverse_geocode
 *
 *  Given a latitude and a longitude, searches for up to 20 places that can be used as a place_id when updating a status.
 */

- (TWAPIRequestOperation *)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                                                  longitude:(NSString *)longitude
                                                   accuracy:(NSString * __nullable)accuracy
                                                granularity:(NSString * __nullable)granularity
                                                 maxResults:(NSUInteger)maxResults
                                                   callback:(NSString * __nullable)callback
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion;

#pragma mark -

/**
 *  GET geo/search
 *  https://dev.twitter.com/rest/reference/get/geo/search
 *
 *  Search for places that can be attached to a statuses/update. Given a latitude and a longitude pair, an IP address, or a name, this request will return a list of all the valid places that can be used as the place_id when updating a status.
 */

- (TWAPIRequestOperation *)getGeoSearchWithLatitude:(NSString *)latitude
                                          longitude:(NSString *)longitude
                                           accuracy:(NSString * __nullable)accuracy
                                        granularity:(NSString * __nullable)granularity
                                         maxResults:(NSUInteger)maxResults
                                    containedWithin:(NSString * __nullable)containedWithin
                             attributeStreetAddress:(NSString * __nullable)attributeStreetAddress
                                           callback:(NSString * __nullable)callback
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getGeoSearchWithIP:(NSString *)ip
                                     accuracy:(NSString * __nullable)accuracy
                                  granularity:(NSString * __nullable)granularity
                                   maxResults:(NSUInteger)maxResults
                              containedWithin:(NSString * __nullable)containedWithin
                       attributeStreetAddress:(NSString * __nullable)attributeStreetAddress
                                     callback:(NSString * __nullable)callback
                                   completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)getGeoSearchWithQuery:(NSString *)query
                                        accuracy:(NSString * __nullable)accuracy
                                     granularity:(NSString * __nullable)granularity
                                      maxResults:(NSUInteger)maxResults
                                 containedWithin:(NSString * __nullable)containedWithin
                          attributeStreetAddress:(NSString * __nullable)attributeStreetAddress
                                        callback:(NSString * __nullable)callback
                                      completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion;

#pragma mark -

/**
 *  POST geo/place
 *  https://dev.twitter.com/rest/reference/post/geo/place
 *
 *  As of December 2nd, 2013, this endpoint is deprecated and retired and no longer functions.
 */

#pragma mark - Direct Messages

/**
 *  Important: This method requires an access token with RWD (read, write & direct message) permissions. Consult The Application Permission Model for more information.
 */


/**
 *  GET direct_messages
 *  https://dev.twitter.com/rest/reference/get/direct_messages
 *
 *  Returns the 20 most recent direct messages sent to the authenticating user. Includes detailed information about the sender and recipient user. You can request up to 200 direct messages per call, and only the most recent 200 DMs will be available using this endpoint.
 *
 *  受信したDMを返します。
 */

- (TWAPIRequestOperation *)getDirectMessagesWithCount:(NSUInteger)count
                                              sinceID:(int64_t)sinceID
                                                maxID:(int64_t)maxID
                                      includeEntities:(BOOL)includeEntities
                                           skipStatus:(BOOL)skipStatus
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable messages, NSError * __nullable error))completion;

/**
 *  GET direct_messages/sent
 *  https://dev.twitter.com/rest/reference/get/direct_messages/sent
 *
 *  Returns the 20 most recent direct messages sent by the authenticating user. Includes detailed information about the sender and recipient user. You can request up to 200 direct messages per call, up to a maximum of 800 outgoing DMs.
 *
 *  送信したDMを返します(最大800件)。
 */

- (TWAPIRequestOperation *)getDirectMessagesSentWithSinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                       Page:(NSUInteger)page
                                            includeEntities:(BOOL)includeEntities
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable messages, NSError * __nullable error))completion;

/**
 *  GET direct_messages/show
 *  https://dev.twitter.com/rest/reference/get/direct_messages/show
 *
 *  Returns a single direct message, specified by an id parameter. Like the /1.1/direct_messages.format request, this method will include the user objects of the sender and recipient.
 *
 *  指定のDMIDのDMを返します。
 */

- (TWAPIRequestOperation *)getDirectMessagesShowWithDirectMessageID:(int64_t)directMessageID
                                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable message, NSError * __nullable error))completion;

/**
 *  POST direct_messages/new
 *  https://dev.twitter.com/rest/reference/post/direct_messages/new
 *
 *  Sends a new direct message to the specified user from the authenticating user. Requires both the user and text parameters and must be a POST. Returns the sent message in the requested format if successful.
 *
 *  DMを送信する。
 */

- (TWAPIRequestOperation *)postDirectMessagesNewWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                      text:(NSString *)text
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable message, NSError * __nullable error))completion;

/**
 *  POST direct_messages/destroy
 *  https://dev.twitter.com/rest/reference/post/direct_messages/destroy
 *
 *  Destroys the direct message specified in the required ID parameter. The authenticating user must be the recipient of the specified direct message.
 *  指定のDMIDのDMを削除します。
 */

- (TWAPIRequestOperation *)postDirectMessagesDestroyWithDirectMessageID:(int64_t)directMessageID
                                                        includeEntities:(BOOL)includeEntities
                                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable message, NSError * __nullable error))completion;

#pragma mark - Application

/**
 *  GET application/rate_limit_status
 *  https://dev.twitter.com/rest/reference/get/application/rate_limit_status
 *
 *  Returns the current rate limits for methods belonging to the specified resource families.
 *  指定したリソースのレートリミットを返します。
 */

- (TWAPIRequestOperation *)getApplicationRateLimitStatusWithResource:(NSString * __nullable)resource
                                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable rateLimitStatus, NSError * __nullable error))completion;

#pragma mark - Help

/**
 *  GET help/languages
 *  https://dev.twitter.com/rest/reference/get/help/languages
 *
 *  Returns the list of languages supported by Twitter along with the language code supported by Twitter.
 *  Twitterでサポートしている言語と言語コードを返します。
 */

- (TWAPIRequestOperation *)getHelpLanguagesWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable languages, NSError * __nullable error))completion;

/**
 *  GET help/configuration
 *  https://dev.twitter.com/rest/reference/get/help/configuration
 *
 *  Returns the current configuration used by Twitter including twitter.com slugs which are not usernames, maximum photo resolutions, and t.co URL lengths.
 *  Twitterの現在の各種構成を返します。
 */

- (TWAPIRequestOperation *)getHelpConfigurationWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable configuration, NSError * __nullable error))completion;

/**
 *  GET help/privacy
 *  https://dev.twitter.com/rest/reference/get/help/privacy
 *
 *  Returns Twitter’s Privacy Policy( https://twitter.com/privacy ).
 *  Twitterのプライバシーポリシーを返します。
 */

- (TWAPIRequestOperation *)getHelpPrivacyWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable privacy, NSError * __nullable error))completion;

/**
 *  GET help/tos
 *  https://dev.twitter.com/rest/reference/get/help/tos
 *
 *  Returns the Twitter Terms of Service( https://twitter.com/tos ). Note: these are not the same as the Developer Policy.
 *  Twitterのサービス利用規約を返します。
 */

- (TWAPIRequestOperation *)getHelpToSWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tos, NSError * __nullable error))completion;

#pragma mark - Public Streams

/**
 *  GET statuses/sample
 *  https://dev.twitter.com/streaming/reference/get/statuses/sample
 *
 *  Returns a small random sample of all public statuses. The Tweets returned by the default access level are the same, so if two different clients connect to this endpoint, they will see the same Tweets.
 *
 */

- (TWAPIRequestOperation *)getStatusesSampleWithStream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                               failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure;

/**
 *  POST statuses/filter
 *  https://dev.twitter.com/streaming/reference/post/statuses/filter
 *
 *  Returns public statuses that match one or more filter predicates. Multiple parameters may be specified which allows most clients to use a single connection to the Streaming API. Both GET and POST requests are supported, but GET requests with too many parameters may cause the request to be rejected for excessive URL length. Use a POST request to avoid long URLs.
 *
 */

- (TWAPIRequestOperation *)postStatusesFilterWithKeywords:(NSArray *)keywords
                                            followUserIDs:(NSArray * __nullable)followUserIDs
                                                locations:(NSString * __nullable)locations
                                                   stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                  failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure;

- (TWAPIRequestOperation *)postStatusesFilterWithKeywords:(NSArray *)keywords
                                                   stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                  failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure;

#pragma mark - User Streams

/**
 *  GET user
 *  https://dev.twitter.com/streaming/reference/get/user
 *
 *  Streams messages for a single user, as described in User streams.
 */

- (TWAPIRequestOperation *)getUserWithUserOnly:(BOOL)userOnly
                                    allReplies:(BOOL)allReplies
                                     locations:(NSString * __nullable)locations
                            stringifyFriendIDs:(BOOL)stringifyFriendIDs
                                        stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                       failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure;

- (TWAPIRequestOperation *)getUserWithStringifyFriendIDs:(BOOL)stringifyFriendIDs
                                                  stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                 failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure;

- (TWAPIRequestOperation *)getUserWithStream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                     failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure;

#pragma mark - Site Streams

/**
 *  GET site
 *  https://dev.twitter.com/streaming/reference/get/site
 *
 *  Streams messages for a set of users, as described in Site streams.
 */

- (TWAPIRequestOperation *)getSiteWithFollowUserIDs:(NSArray *)followUserIDs
                                         followings:(BOOL)followings
                                         allReplies:(BOOL)allReplies
                                          locations:(NSString * __nullable)locations
                                 stringifyFriendIDs:(BOOL)stringifyFriendIDs
                                             stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                            failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure;

/**
 *  GET c/:stream_id/info
 *  https://dev.twitter.com/streaming/reference/get/c/stream_id/info
 *
 *  Retrieves information about the established stream represented by the stream_handle_identifier, which is among the first streamed events when connecting to a stream that supports Control Streams.
 */

#pragma mark - Firehose

/**
 *  Firehose
 *  https://dev.twitter.com/streaming/firehose
 *
 *  This endpoint requires special permission to access.
 Returns all public statuses. Few applications require this level of access. Creative use of a combination of other resources and various access levels can satisfy nearly every application use case.
 */

@end
NS_ASSUME_NONNULL_END