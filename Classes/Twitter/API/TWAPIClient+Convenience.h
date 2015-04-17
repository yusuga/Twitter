//
//  TWAPIClient+Convenience.h
//  Develop
//
//  Created by Yu Sugawara on 4/20/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIClient.h"
#import "TWAPIRequestOperation.h"
#import "TWAPIMultipleRequestOperation.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWAPIClient (Convenience)

#pragma mark - Favorite

- (TWAPIRequestOperation *)sendRequestFavoritesWithTweetID:(int64_t)tweetID
                                                 favorited:(BOOL)favorited
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion;

#pragma mark - Retweet

- (TWAPIRequestOperation *)sendRequestRetweetWithTweetID:(int64_t)tweetID
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion;

- (TWAPIMultipleRequestOperation *)sendRequestDestroyRetweetWithOriginalTweetID:(int64_t)tweetID
                                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion;

#pragma mark - Tweet

- (TWAPIRequestOperation *)sendRequestDestroyTweetWithTweetID:(int64_t)tweetID
                                                   completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion;

- (TWAPIMultipleRequestOperation *)sendRequestMediaTweetWithStatus:(NSString *)status
                                                         mediaData:(NSArray *)mediaData
                                                 inReplyToStatusID:(int64_t)inReplyToStatusID
                                                 possiblySensitive:(BOOL)possiblySensitive
                                                          latitude:(NSString * __nullable)latitude
                                                         longitude:(NSString * __nullable)longitude
                                                           placeID:(NSString * __nullable)placeID
                                                displayCoordinates:(BOOL)displayCoordinates
                                                          trimUser:(BOOL)trimUser
                                                    uploadProgress:(void (^ __nullable)(CGFloat progress))uploadProgress
                                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

@end
NS_ASSUME_NONNULL_END