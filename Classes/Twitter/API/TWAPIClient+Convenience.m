//
//  TWAPIClient+Convenience.m
//
//  Created by Yu Sugawara on 4/20/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIClient+Convenience.h"
#import "NSError+TWTwitter.h"

static uint64_t const kFirstPageCursor = -1;
static uint64_t const kLastPageCursor = 0;
static NSUInteger const kUserIDsRequestCountMax = 5000;

typedef void (^TWAPIClientGetAllUserIDsRequestCompletion)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error);
typedef TWAPIRequestOperation *(^TWAPIClientGetAllUserIDsCreateRequest)(uint64_t cursor, TWAPIClientGetAllUserIDsRequestCompletion requestCompletion);

static inline NSString *tw_modeStr(NSNumber *privateBoolNum)
{
    return privateBoolNum.boolValue ? @"private" : @"public";
}

NS_ASSUME_NONNULL_BEGIN
@implementation TWAPIClient (Convenience)

#pragma mark - Favorite

- (TWAPIRequestOperation *)tw_postFavoritesWithTweetID:(int64_t)tweetID
                                             favorited:(BOOL)favorited
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion
{
    if (favorited) {
        return [self postFavoritesCreateWithTweetID:tweetID
                                    includeEntities:YES
                                         completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
                                             if (error) {
                                                 // Ignore error
                                                 if (![error.domain isEqualToString:TWAPIErrorDomain] || error.code != TWAPIErrorCodeAlreadyFavorited) {
                                                     completion(operation, error);
                                                     return ;
                                                 }
                                             }
                                             completion(operation, nil);
                                         }];
    } else {
        return [self postFavoritesDestroyWithTweetID:tweetID
                                     includeEntities:YES
                                          completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
                                              if (error) {
                                                  // Ignore error
                                                  if (![error.domain isEqualToString:TWAPIErrorDomain] || error.code != TWAPIErrorCodeNoStatusFoundWithThatID) {
                                                      completion(operation, error);
                                                      return ;
                                                  }
                                              }
                                              completion(operation, nil);
                                          }];
    }
}

#pragma mark - Retweet

- (TWAPIRequestOperation *)tw_postStatusesRetweetWithTweetID:(int64_t)tweetID
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion
{
    return [self postStatusesRetweetWithTweetID:tweetID
                                       trimUser:YES
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
                                         if (error) {
                                             // Ignore error
                                             if (![error.domain isEqualToString:TWAPIErrorDomain] ||
                                                 (error.code != TWAPIErrorCodeAlreadyRetweeted && error.code != TWAPIErrorCodeStatusIsDuplicate)) {
                                                 completion(operation, error);
                                                 return ;
                                             }
                                         }
                                         completion(operation, nil);
                                     }];
}

#pragma mark - Tweet

- (TWAPIRequestOperation *)tw_postStatusesDestroyWithTweetID:(int64_t)tweetID
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSError * __nullable error))completion
{
    return [self postStatusesDestroyWithTweetID:tweetID
                                       trimUser:YES
                                     completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error) {
                                         if (error) {
                                             // Ignore error
                                             if (![error.domain isEqualToString:TWAPIErrorDomain] || error.code != TWAPIErrorCodeNoStatusFoundWithThatID) {
                                                 completion(operation, error);
                                                 return ;
                                             }
                                         }
                                         completion(operation, nil);
                                     }];
}

- (TWAPIMultipleRequestOperation *)tw_postStatusesUpdateWithStatus:(NSString *)status
                                                         mediaData:(NSArray<NSData *> *)mediaData
                                                 inReplyToStatusID:(int64_t)inReplyToStatusID
                                                 possiblySensitive:(BOOL)possiblySensitive
                                                          latitude:(NSString * __nullable)latitude
                                                         longitude:(NSString * __nullable)longitude
                                                           placeID:(NSString * __nullable)placeID
                                                displayCoordinates:(BOOL)displayCoordinates
                                                          trimUser:(BOOL)trimUser
                                                    uploadProgress:(void (^ __nullable)(TWRequestState state, CGFloat progress))uploadProgress
                                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    TWAPIMultipleRequestOperation *multipleOpe = [[TWAPIMultipleRequestOperation alloc] init];
    
    NSMutableArray *mediaIDs = [NSMutableArray arrayWithCapacity:[mediaData count]];
    __block CGFloat mediaProgress = 0.;
    NSMutableArray *errors = [NSMutableArray array];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSData *data in mediaData) {
        dispatch_group_enter(group);
        [multipleOpe addOperation:[self postMediaUploadWithMedia:data
                                                  uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
                                   {
                                       if (uploadProgress) {
                                           CGFloat increment = (CGFloat)bytesWritten/totalBytesExpectedToWrite;
                                           mediaProgress += increment/[mediaData count];
                                           uploadProgress(TWRequestStateUploadMedia, mediaProgress * 0.9);
                                       }
                                   } completion:^(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable mediaUpload, NSError * __nullable error)
                                   {
                                       if (error) {
                                           [errors addObject:[NSError tw_localizedAPIErrorWithHTTPOperation:operation
                                                                                            underlyingError:error
                                                                                                 screenName:nil]];
                                       } else {
                                           [mediaIDs addObject:mediaUpload[@"media_id_string"]];
                                       }
                                       dispatch_group_leave(group);
                                   }]];
    }
    
    __weak typeof(self) wself = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (!wself) return ;
        
        if ([errors count]) {
            for (NSError *error in errors) {
                if ([error tw_isCancelled]) {
                    completion(nil, nil, error);
                    return ;
                }
            }
            completion(nil, nil, [NSError tw_errorFromErrors:errors]);
            return ;
        }
        NSParameterAssert([mediaData count] == [mediaIDs count]);
        
        [multipleOpe addOperation:[wself postStatusesUpdateWithStatus:status
                                                    inReplyToStatusID:inReplyToStatusID
                                                    possiblySensitive:possiblySensitive
                                                             latitude:latitude
                                                            longitude:longitude
                                                              placeID:placeID
                                                   displayCoordinates:displayCoordinates
                                                             trimUser:trimUser
                                                             mediaIDs:[NSArray arrayWithArray:mediaIDs]
                                                       uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
                                   {
                                       if (uploadProgress) uploadProgress(TWRequestStateUploadTweet, 0.9 + ((CGFloat)totalBytesWritten/totalBytesExpectedToWrite)*0.1);
                                   } completion:completion]];
    });
    
    return multipleOpe;
}

#pragma mark - List

- (TWAPIRequestOperation *)tw_postListsCreateWithName:(NSString *)name
                                              private:(NSNumber * __nullable)privateBoolNum
                                          description:(NSString * __nullable)description
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion;
{
    return [self postListsCreateWithName:name
                                    mode:tw_modeStr(privateBoolNum)
                             description:description
                              completion:completion];
}

- (TWAPIRequestOperation *)tw_postListsUpdateWithListID:(NSNumber *)listID
                                                   name:(NSString * __nullable)name
                                                private:(NSNumber * __nullable)privateBoolNum
                                            description:(NSString * __nullable)description
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    return [self postListsUpdateWithListID:listID
                                      name:name
                                      mode:tw_modeStr(privateBoolNum)
                               description:description
                                completion:completion];
}

- (TWAPIRequestOperation *)tw_postListsUpdateWithSlug:(NSString *)slug
                                              ownerID:(NSNumber * __nullable)ownerID
                                    orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                 name:(NSString * __nullable)name
                                              private:(NSNumber * __nullable)privateBoolNum
                                          description:(NSString * __nullable)description
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    return [self postListsUpdateWithSlug:slug
                                 ownerID:ownerID
                       orOwnerScreenName:ownerScreenName
                                    name:name
                                    mode:tw_modeStr(privateBoolNum)
                             description:description
                              completion:completion];
}

#pragma mark - User

- (TWAPIRequestOperation *)tw_postUsersLookupWithUserIDs:(NSArray *)userIDs
                                           orScreenNames:(NSArray * _Nullable)screenNames
                                         includeEntities:(BOOL)includeEntities
                                              completion:(void (^)(TWAPIRequestOperation * _Nullable, NSArray * _Nullable, NSError * _Nullable))completion
{
    return [self postUsersLookupWithUserIDs:userIDs
                              orScreenNames:screenNames
                            includeEntities:includeEntities
                                 completion:^(TWAPIRequestOperation * _Nullable operation, NSArray * _Nullable users, NSError * _Nullable error)
            {
                if (error) {
                    // Ignore error
                    if (![error.domain isEqualToString:TWAPIErrorDomain] || error.code != TWAPIErrorCodeNoUserMatchesForSpecifiedTerms) {
                        completion(operation, nil, error);
                        return ;
                    }
                }
                completion(operation, users, nil);
            }];
}

#pragma mark - Friends

- (TWAPIMultipleRequestOperation *)tw_getAllFriendsIDsWithUserID:(int64_t)userID
                                                    orScreenName:(NSString * __nullable)screenName
                                                      completion:(void (^)(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * __nullable userIDs, NSError * __nullable error))completion
{
    __weak typeof(self) wself = self;
    return [self tw_getAllUserIDsWithCreateRequest:^TWAPIRequestOperation *(uint64_t cursor, TWAPIClientGetAllUserIDsRequestCompletion requestCompletion) {
        return [wself getFriendsIDsWithUserID:userID
                                 orScreenName:nil
                                        count:kUserIDsRequestCountMax
                                       cursor:cursor
                                 stringifyIDs:NO
                                   completion:requestCompletion];
    } completion:completion];
}

#pragma mark - Followers

- (TWAPIMultipleRequestOperation *)tw_getAllFollowersIDsWithUserID:(int64_t)userID
                                                      orScreenName:(NSString * __nullable)screenName
                                                        completion:(void (^)(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * __nullable userIDs, NSError * __nullable error))completion
{
    __weak typeof(self) wself = self;
    return [self tw_getAllUserIDsWithCreateRequest:^TWAPIRequestOperation *(uint64_t cursor, TWAPIClientGetAllUserIDsRequestCompletion requestCompletion) {
        return [wself getFollowersIDsWithUserID:userID
                                   orScreenName:nil
                                          count:kUserIDsRequestCountMax
                                         cursor:cursor
                                   stringifyIDs:NO
                                     completion:requestCompletion];
    } completion:completion];
}

#pragma mark - Friendships

- (TWAPIMultipleRequestOperation *)tw_getAllFriendshipsNoRetweetsIDsWithCompletion:(void (^)(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * __nullable userIDs, NSError * __nullable error))completion
{
    __weak typeof(self) wself = self;
    return [self tw_getAllUserIDsWithCreateRequest:^TWAPIRequestOperation *(uint64_t cursor, TWAPIClientGetAllUserIDsRequestCompletion requestCompletion) {
        return [wself getFriendshipsNoRetweetsIDsWithStringifyIDs:NO
                                                       completion:requestCompletion];
    } completion:completion];
}

#pragma mark - Mutes

- (TWAPIMultipleRequestOperation *)tw_getAllMutesUsersIDsWithCompletion:(void (^)(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * __nullable userIDs, NSError * __nullable error))completion
{
    __weak typeof(self) wself = self;
    return [self tw_getAllUserIDsWithCreateRequest:^TWAPIRequestOperation *(uint64_t cursor, TWAPIClientGetAllUserIDsRequestCompletion requestCompletion) {
        return [wself getMutesUsersIDsWithCursor:cursor
                                    stringifyIDs:NO
                                      completion:requestCompletion];
    } completion:completion];
}

#pragma mark - Blocks

- (TWAPIMultipleRequestOperation *)tw_getAllBlocksIDsWithCompletion:(void (^)(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * __nullable userIDs, NSError * __nullable error))completion
{
    __weak typeof(self) wself = self;
    return [self tw_getAllUserIDsWithCreateRequest:^TWAPIRequestOperation *(uint64_t cursor, TWAPIClientGetAllUserIDsRequestCompletion requestCompletion) {
        return [wself getBlocksIDsWithCursor:cursor
                                stringifyIDs:NO
                                  completion:requestCompletion];
    } completion:completion];
}

#pragma mark - Private

- (TWAPIMultipleRequestOperation *)tw_getAllUserIDsWithCreateRequest:(TWAPIClientGetAllUserIDsCreateRequest)createRequest
                                                          completion:(void (^)(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * __nullable userIDs, NSError * __nullable error))completion
{
    TWAPIMultipleRequestOperation *multipleRequest = [[TWAPIMultipleRequestOperation alloc] init];
    NSMutableArray *allUserIDs = [NSMutableArray array];
    
    [self tw_getAllUserIDsWithCreateRequest:createRequest
                            multipleRequest:multipleRequest
                                 allUserIDs:allUserIDs
                                     cursor:kFirstPageCursor
                                 completion:completion];
    
    return multipleRequest;
}

- (void)tw_getAllUserIDsWithCreateRequest:(TWAPIClientGetAllUserIDsCreateRequest)createRequest
                          multipleRequest:(TWAPIMultipleRequestOperation *)multipleRequest
                               allUserIDs:(NSMutableArray *)allUserIDs
                                   cursor:(uint64_t)cursor
                               completion:(void (^)(TWAPIMultipleRequestOperation * __nullable operation, NSArray<NSNumber *> * __nullable userIDs, NSError * __nullable error))completion
{
    if (cursor == kLastPageCursor) {
        if (completion) completion(multipleRequest, [allUserIDs copy], nil);
        return;
    }
    
    __weak typeof(self) wself = self;
    [multipleRequest addOperation:createRequest(cursor, ^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error) {
        NSLog(@"GET: netCursor: %llu", cursor);
        
        /*
         *  # Response object pattern
         *  1. NSDictionary
         *  https://dev.twitter.com/overview/api/cursoring
         *
         *  2. NSArray of NSNumber
         */
        NSArray<NSNumber *> *userIDs;
        uint64_t nextCursor = kLastPageCursor;
        
        if (responseObject) {
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                userIDs = responseObject[@"ids"];
                nextCursor = [responseObject[@"next_cursor"] unsignedLongLongValue];
            } else if ([responseObject isKindOfClass:[NSArray class]]) {
                userIDs = responseObject;
            } else {
                if (completion) completion(multipleRequest, nil, [NSError tw_parseFailedErrorWithUnderlyingString:[NSString stringWithFormat:@"Unsupported responseObject: %@", NSStringFromClass([responseObject class])]]);
                return;
            }
        }
        
        [allUserIDs addObjectsFromArray:userIDs];
        
        if (error || operation.isCancelled) {
            if (completion) completion(multipleRequest, [allUserIDs copy], error);
            return ;
        }
        
        [wself tw_getAllUserIDsWithCreateRequest:createRequest
                                 multipleRequest:multipleRequest
                                      allUserIDs:allUserIDs
                                          cursor:nextCursor
                                      completion:completion];
    })];
}

@end
NS_ASSUME_NONNULL_END