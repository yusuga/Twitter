//
//  TWAPIClient+Convenience.m
//
//  Created by Yu Sugawara on 4/20/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIClient+Convenience.h"
#import "NSError+TWTwitter.h"

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

@end
NS_ASSUME_NONNULL_END