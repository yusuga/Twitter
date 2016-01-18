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

- (TWAPIRequestOperation *)tw_postFavoritesWithTweetID:(int64_t)tweetID
                                             favorited:(BOOL)favorited
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion;

#pragma mark - Retweet

- (TWAPIRequestOperation *)tw_postStatusesRetweetWithTweetID:(int64_t)tweetID
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion;

#pragma mark - Tweet

- (TWAPIRequestOperation *)tw_postStatusesDestroyWithTweetID:(int64_t)tweetID
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion;

- (TWAPIMultipleRequestOperation *)tw_postStatusesUpdateWithStatus:(NSString *)status
                                                         mediaData:(NSArray<NSData *> *)mediaData
                                                 inReplyToStatusID:(int64_t)inReplyToStatusID
                                                 possiblySensitive:(BOOL)possiblySensitive
                                                          latitude:(NSString * __nullable)latitude
                                                         longitude:(NSString * __nullable)longitude
                                                           placeID:(NSString * __nullable)placeID
                                                displayCoordinates:(BOOL)displayCoordinates
                                                          trimUser:(BOOL)trimUser
                                                    uploadProgress:(void (^ __nullable)(CGFloat progress))uploadProgress
                                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion;

#pragma mark - List

///-----------
/// @name list
///-----------

- (TWAPIRequestOperation *)tw_postListsCreateWithName:(NSString *)name
                                              private:(NSNumber * __nullable)privateBoolNum
                                          description:(NSString * __nullable)description
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)tw_postListsUpdateWithListID:(NSNumber *)listID
                                                   name:(NSString * __nullable)name
                                                private:(NSNumber * __nullable)privateBoolNum
                                            description:(NSString * __nullable)description
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

- (TWAPIRequestOperation *)tw_postListsUpdateWithSlug:(NSString *)slug
                                              ownerID:(NSNumber * __nullable)ownerID
                                    orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                 name:(NSString * __nullable)name
                                              private:(NSNumber * __nullable)privateBoolNum
                                          description:(NSString * __nullable)description
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;

@end
NS_ASSUME_NONNULL_END