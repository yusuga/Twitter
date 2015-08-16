//
//  TWAPIClient.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIClient.h"
#import "TWAuth.h"
#import "NSError+TWTwitter.h"
#import "NSString+TWTwitter.h"
#import "TWConstants.h"

static inline NSString *tw_int64Str(int64_t int64)
{
    return [NSString stringWithFormat:@"%lld", int64];
}

static inline NSString *tw_int32Str(int32_t int32)
{
    return [NSString stringWithFormat:@"%d", int32];
}

static inline NSString *tw_uintegerStr(NSUInteger i)
{
    return [NSString stringWithFormat:@"%zd", i];
}

static inline NSString *tw_boolStr(BOOL b)
{
    return b ? @"1" : @"0";
}

NS_ASSUME_NONNULL_BEGIN
@interface TWAPIClient ()

@property (nonatomic, readwrite) TWAuth *auth;
@property (nonatomic) NSMapTable *requests;

@end

@implementation TWAPIClient

- (instancetype)initWithAuth:(TWAuth *)auth
{
    if (self = [super init]) {
        self.auth = auth;
        self.requests = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {\n%@auth = %@\n}", [super description], tw_indent(1), [self.auth descriptionWithIndent:1]];
}

#pragma mark - Request

- (TWAPIRequestOperation * __nullable)sendRequestWithHTTPMethod:(NSString *)HTTPMethod
                                                  baseURLString:(NSString *)baseURLString
                                              relativeURLString:(NSString *)relativeURLString
                                                     parameters:(NSDictionary * __nullable)parameters
                                                    willRequest:(void (^ __nullable)(NSMutableURLRequest *request) )willRequest
                                                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                               downloadProgress:(void (^ __nullable)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) downloadProgress
                                                         stream:(void (^ __nullable)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    TWAPIRequestOperation *ope = [self.auth sendRequestWithHTTPMethod:HTTPMethod
                                                        baseURLString:baseURLString
                                                    relativeURLString:relativeURLString
                                                           parameters:parameters
                                                          willRequest:willRequest
                                                       uploadProgress:uploadProgress
                                                     downloadProgress:downloadProgress
                                                               stream:stream
                                                           completion:completion];
    
    @synchronized(self.requests) {
        [self.requests setObject:ope forKey:ope];
    }
    return ope;
}

- (TWAPIRequestOperation *)GET:(NSString *)relativeURLString
                    parameters:(NSDictionary * __nullable)parameters
                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable json, NSError * __nullable error))completion
{
    return [self sendRequestWithHTTPMethod:kTWHTTPMethodGET
                             baseURLString:kTWBaseURLString_API_1_1
                         relativeURLString:relativeURLString
                                parameters:parameters
                               willRequest:nil
                            uploadProgress:nil
                          downloadProgress:nil
                                    stream:nil
                                completion:completion];
}

- (TWAPIRequestOperation *)POST:(NSString *)relativeURLString
                     parameters:(NSDictionary * __nullable)parameters
                 uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable json, NSError * __nullable error))completion
{
    return [self sendRequestWithHTTPMethod:kTWHTTPMethodPOST
                             baseURLString:kTWBaseURLString_API_1_1
                         relativeURLString:relativeURLString
                                parameters:parameters
                               willRequest:nil
                            uploadProgress:uploadProgress
                          downloadProgress:nil
                                    stream:nil
                                completion:completion];
}

- (TWAPIRequestOperation *)POST:(NSString *)relativeURLString
                     parameters:(NSDictionary * __nullable)parameters
                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable json, NSError * __nullable error))completion
{
    return [self POST:relativeURLString
           parameters:parameters
       uploadProgress:nil
           completion:completion];
}

- (TWAPIRequestOperation *)sendRequestStreamWithHTTPMethod:(NSString *)HTTPMethod
                                             baseURLString:(NSString *)baseURLString
                                         relativeURLString:(NSString *)relativeURLString
                                                parameters:(NSDictionary * __nullable)parameters
                                                    stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                   failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *streamParams = parameters ? parameters.mutableCopy : [NSMutableDictionary dictionary];
    streamParams[@"delimited"] = @"length";
    streamParams[@"stall_warnings"] = @"1";
    
    return [self sendRequestWithHTTPMethod:HTTPMethod
                             baseURLString:baseURLString
                         relativeURLString:relativeURLString
                                parameters:[NSDictionary dictionaryWithDictionary:streamParams]
                               willRequest:nil
                            uploadProgress:nil
                          downloadProgress:nil
                                    stream:stream
                                completion:^(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error) {
                                    if (operation.isCancelled) return ;
                                    failure(operation, error ?: [NSError tw_unexpectedBranchErrorWithDescription:@"Unexpected branch of success stream"]);
                                }];
}

- (void)cancelAllRequests
{
    @synchronized(self.requests) {
        for (TWAPIRequestOperation *ope in self.requests) {
            [ope cancel];
        }
    }
}

#pragma mark - Statuses

- (TWAPIRequestOperation *)getStatusesHomeTimelineWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                   trimUser:(BOOL)trimUser
                                             excludeReplies:(BOOL)excludeReplies
                                         contributorDetails:(BOOL)contributorDetails
                                            includeEntities:(BOOL)includeEntities
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    if (excludeReplies) params[@"exclude_replies"] = tw_boolStr(excludeReplies);
    if (contributorDetails) params[@"contributor_details"] = tw_boolStr(contributorDetails);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"statuses/home_timeline.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getStatusesHomeTimelineWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    return [self getStatusesHomeTimelineWithCount:count
                                          sinceID:sinceID
                                            maxID:maxID
                                         trimUser:NO
                                   excludeReplies:NO
                               contributorDetails:YES
                                  includeEntities:YES
                                       completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getStatusesMentionsTimelineWithCount:(NSUInteger)count
                                                        sinceID:(int64_t)sinceID
                                                          maxID:(int64_t)maxID
                                                       trimUser:(BOOL)trimUser
                                                 excludeReplies:(BOOL)excludeReplies
                                             contributorDetails:(BOOL)contributorDetails
                                                includeEntities:(BOOL)includeEntities
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    if (excludeReplies) params[@"exclude_replies"] = tw_boolStr(excludeReplies);
    if (contributorDetails) params[@"contributor_details"] = tw_boolStr(contributorDetails);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"statuses/mentions_timeline.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getStatusesMentionsTimelineWithCount:(NSUInteger)count
                                                        sinceID:(int64_t)sinceID
                                                          maxID:(int64_t)maxID
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    return [self getStatusesMentionsTimelineWithCount:count
                                              sinceID:sinceID
                                                maxID:maxID
                                             trimUser:NO
                                       excludeReplies:NO
                                   contributorDetails:YES
                                      includeEntities:YES
                                           completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getStatusesRetweetsOfMeWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                   trimUser:(BOOL)trimUser
                                            includeEntities:(BOOL)includeEntities
                                        includeUserEntities:(BOOL)includeUserEntities
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (includeUserEntities) params[@"include_user_entities"] = tw_boolStr(includeUserEntities);
    
    return [self GET:@"statuses/retweets_of_me.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getStatusesRetweetsOfMeWithCount:(NSUInteger)count
                                                    sinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    return [self getStatusesRetweetsOfMeWithCount:count
                                          sinceID:sinceID
                                            maxID:maxID
                                       completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getStatusesUserTimelineWithUserID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                                       count:(NSUInteger)count
                                                     sinceID:(int64_t)sinceID
                                                       maxID:(int64_t)maxID
                                                    trimUser:(BOOL)trimUser
                                              excludeReplies:(BOOL)excludeReplies
                                          contributorDetails:(BOOL)contributorDetails
                                                  includeRTs:(BOOL)includeRTs
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    if (excludeReplies) params[@"exclude_replies"] = tw_boolStr(excludeReplies);
    if (contributorDetails) params[@"contributor_details"] = tw_boolStr(contributorDetails);
    if (includeRTs) params[@"include_rts"] = tw_boolStr(includeRTs);
    
    return [self GET:@"statuses/user_timeline.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
    
}

- (TWAPIRequestOperation *)getStatusesUserTimelineWithUserID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                                       count:(NSUInteger)count
                                                     sinceID:(int64_t)sinceID
                                                       maxID:(int64_t)maxID
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    return [self getStatusesUserTimelineWithUserID:userID
                                      orScreenName:screenName
                                             count:count
                                           sinceID:sinceID
                                             maxID:maxID
                                          trimUser:NO
                                    excludeReplies:NO
                                contributorDetails:YES
                                        includeRTs:YES
                                        completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getStatusesShowWithTweetID:(int64_t)tweetID
                                             trimUser:(BOOL)trimUser
                                     includeMyRetweet:(BOOL)includeMyRetweet
                                      includeEntities:(BOOL)includeEntities
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tw_int64Str(tweetID);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    if (includeMyRetweet) params[@"include_my_retweet"] = tw_boolStr(includeMyRetweet);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"statuses/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getStatusesShowWithTweetID:(int64_t)tweetID
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    return [self getStatusesShowWithTweetID:tweetID
                                   trimUser:NO
                           includeMyRetweet:YES
                            includeEntities:YES
                                 completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getStatusesLookupWithTweetIDs:(NSArray *)tweetIDs
                                         includeEntities:(BOOL)includeEntities
                                                trimUser:(BOOL)trimUser
                                                     map:(BOOL)map
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable respondObject, NSError * __nullable error))completion;
{
    NSParameterAssert(tweetIDs);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetIDs) params[@"id"] = [tweetIDs componentsJoinedByString:@","];
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    if (map) params[@"map"] = tw_boolStr(map);
    
    return [self GET:@"statuses/lookup.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getStatusesLookupWithTweetIDs:(NSArray *)tweetIDs
                                         includeEntities:(BOOL)includeEntities
                                                trimUser:(BOOL)trimUser
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    return [self getStatusesLookupWithTweetIDs:tweetIDs
                               includeEntities:includeEntities
                                      trimUser:trimUser
                                           map:NO
                                    completion:completion];
}

- (TWAPIRequestOperation *)getStatusesLookupWithTweetIDs:(NSArray *)tweetIDs
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    return [self getStatusesLookupWithTweetIDs:tweetIDs
                               includeEntities:YES
                                      trimUser:NO
                                           map:NO
                                    completion:completion];
}

- (TWAPIRequestOperation *)getStatusesLookupMappedWithTweetIDs:(NSArray *)tweetIDs
                                               includeEntities:(BOOL)includeEntities
                                                      trimUser:(BOOL)trimUser
                                                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable mappedTweets, NSError * __nullable error))completion
{
    return [self getStatusesLookupWithTweetIDs:tweetIDs
                               includeEntities:includeEntities
                                      trimUser:trimUser
                                           map:YES
                                    completion:completion];
}

#pragma mark -

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
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    NSParameterAssert(status);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (status) params[@"status"] = status;
    if (inReplyToStatusID) params[@"in_reply_to_status_id"] = tw_int64Str(inReplyToStatusID);
    if (possiblySensitive) params[@"possibly_sensitive"] = tw_boolStr(possiblySensitive);
    if (latitude) params[@"lat"] = latitude;
    if (longitude) params[@"long"] = longitude;
    if (placeID) params[@"place_id"] = placeID;
    if (displayCoordinates) params[@"display_coordinates"] = tw_boolStr(displayCoordinates);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    if ([mediaIDs count]) params[@"media_ids"] = [mediaIDs componentsJoinedByString:@","];
    
    return [self POST:@"statuses/update.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
       uploadProgress:uploadProgress
           completion:completion];
}

- (TWAPIRequestOperation *)postStatusesUpdateWithStatus:(NSString *)status
                                      inReplyToStatusID:(int64_t)inReplyToStatusID
                                         uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    return [self postStatusesUpdateWithStatus:status
                            inReplyToStatusID:inReplyToStatusID
                            possiblySensitive:NO
                                     latitude:nil
                                    longitude:nil
                                      placeID:nil
                           displayCoordinates:NO
                                     trimUser:NO
                                     mediaIDs:nil
                               uploadProgress:uploadProgress
                                   completion:completion];
}

- (TWAPIRequestOperation *)postStatusesUpdateWithStatus:(NSString *)status
                                      inReplyToStatusID:(int64_t)inReplyToStatusID
                                               mediaIDs:(NSArray *)mediaIDs
                                         uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    return [self postStatusesUpdateWithStatus:status
                            inReplyToStatusID:inReplyToStatusID
                            possiblySensitive:NO
                                     latitude:nil
                                    longitude:nil
                                      placeID:nil
                           displayCoordinates:NO
                                     trimUser:NO
                                     mediaIDs:mediaIDs
                               uploadProgress:uploadProgress
                                   completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)postStatusesUpdateWithMediaWithStatus:(NSString *)status
                                                           media:(NSData *)media
                                               possiblySensitive:(BOOL)possiblySensitive
                                               inReplyToStatusID:(int64_t)inReplyToStatusID
                                                        latitude:(NSString * __nullable)latitude
                                                       longitude:(NSString * __nullable)longitude
                                                         placeID:(NSString * __nullable)placeID
                                              displayCoordinates:(BOOL)displayCoordinates
                                                  uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                      completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    NSParameterAssert(status);
    NSParameterAssert(media);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (status) params[@"status"] = status;
    if (media) params[kTWPostData] = [[TWPostData alloc] initWithData:media
                                                                 name:@"media[]"
                                                             fileName:@"media.jpg"];
    if (possiblySensitive) params[@"possibly_sensitive"] = tw_boolStr(possiblySensitive);
    if (inReplyToStatusID) params[@"in_reply_to_status_id"] = tw_int64Str(inReplyToStatusID);
    if (latitude) params[@"lat"] = latitude;
    if (longitude) params[@"long"] = longitude;
    if (placeID) params[@"place_id"] = placeID;
    if (displayCoordinates) params[@"display_coordinates"] = tw_boolStr(displayCoordinates);
    
    return [self POST:@"statuses/update_with_media.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
       uploadProgress:uploadProgress
           completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)postStatusesRetweetWithTweetID:(int64_t)tweetID
                                                 trimUser:(BOOL)trimUser
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID);
    
    NSString *tweetIDStr = tw_int64Str(tweetID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tweetIDStr;
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    
    return [self POST:[NSString stringWithFormat:@"statuses/retweet/%@.json", tweetIDStr]
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postStatusesRetweetWithTweetID:(int64_t)tweetID
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    return [self postStatusesRetweetWithTweetID:tweetID
                                       trimUser:NO
                                     completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)postStatusesDestroyWithTweetID:(int64_t)tweetID
                                                 trimUser:(BOOL)trimUser
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID);
    
    NSString *tweetIDStr = tw_int64Str(tweetID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tweetIDStr;
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    
    return [self POST:[NSString stringWithFormat:@"statuses/destroy/%@.json", tweetIDStr]
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postStatusesDestroyWithTweetID:(int64_t)tweetID
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    return [self postStatusesDestroyWithTweetID:tweetID
                                       trimUser:NO
                                     completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getStatusesRetweetsWithTweetID:(int64_t)tweetID
                                                    count:(NSUInteger)count
                                                 trimUser:(BOOL)trimUser
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID);
    
    NSString *tweetIDStr = tw_int64Str(tweetID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tweetIDStr;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    
    return [self GET:[NSString stringWithFormat:@"statuses/retweets/%@.json", tweetIDStr]
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getStatusesRetweetsWithTweetID:(int64_t)tweetID
                                                    count:(NSUInteger)count
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    return [self getStatusesRetweetsWithTweetID:tweetID
                                          count:count
                                       trimUser:NO
                                     completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getStatusesRetweetersWithTweetID:(int64_t)tweetID
                                                     cursor:(NSUInteger)count
                                                   trimUser:(BOOL)trimUser
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tw_int64Str(tweetID);
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (trimUser) params[@"trim_user"] = tw_boolStr(trimUser);
    
    return [self GET:@"statuses/retweeters/ids.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark -

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
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable json, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID || tweetURLString);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tw_int64Str(tweetID);
    if (tweetURLString) params[@"url"] = tweetURLString;
    if (maxWidth) params[@"maxwidth"] = tw_uintegerStr(maxWidth);
    if (hideMedia) params[@"hide_media"] = tw_boolStr(hideMedia);
    if (hideThread) params[@"hide_thread"] = tw_boolStr(hideThread);
    if (omitScript) params[@"omit_script"] = tw_boolStr(omitScript);
    if (align) params[@"align"] = align;
    if (related) params[@"related"] = related;
    if (lang) params[@"lang"] = lang;
    if (widgetType) params[@"widget_type"] = widgetType;
    if (hideTweet) params[@"hide_tweet"] = tw_boolStr(hideTweet);
    
    return [self GET:@"statuses/oembed.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark - Media

/**
 *  POST media/upload
 *  https://dev.twitter.com/rest/reference/post/media/upload
 */

- (TWAPIRequestOperation *)postMediaUploadWithMedia:(NSData *)media
                                     uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable mediaUpload, NSError * __nullable error))completion
{
    NSParameterAssert(media);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (media) params[kTWPostData] = [[TWPostData alloc] initWithData:media
                                                                 name:@"media"
                                                             fileName:@"media.jpg"];
    
    return [self sendRequestWithHTTPMethod:kTWHTTPMethodPOST
                             baseURLString:kTWBaseURLString_Upload_1_1
                         relativeURLString:@"media/upload.json"
                                parameters:[NSDictionary dictionaryWithDictionary:params]
                               willRequest:nil
                            uploadProgress:uploadProgress
                          downloadProgress:nil
                                    stream:nil
                                completion:completion];
}

#pragma mark - Favorites

- (TWAPIRequestOperation *)getFavoritesListWithUserID:(int64_t)userID
                                         orScreenName:(NSString * __nullable)screenName
                                                count:(NSUInteger)count
                                              sinceID:(int64_t)sinceID
                                                maxID:(int64_t)maxID
                                      includeEntities:(BOOL)includeEntities
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion;
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"favorites/list.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postFavoritesCreateWithTweetID:(int64_t)tweetID
                                          includeEntities:(BOOL)includeEntities
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tw_int64Str(tweetID);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self POST:@"favorites/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postFavoritesDestroyWithTweetID:(int64_t)tweetID
                                           includeEntities:(BOOL)includeEntities
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tweet, NSError * __nullable error))completion
{
    NSParameterAssert(tweetID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (tweetID) params[@"id"] = tw_int64Str(tweetID);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self POST:@"favorites/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark - Search

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
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable searchResult, NSError * __nullable error))completion
{
    NSParameterAssert(query);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (query) params[@"q"] = query;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (resultType) params[@"result_type"] = ^NSString *{
        switch (resultType) {
            default:
            case TWAPISearchResultTypeMixed:
                return @"mixed";
            case TWAPISearchResultTypeRecent:
                return @"recent";
            case TWAPISearchResultTypePopular:
                return @"popular";
        }
    }();
    if (geocode) params[@"geocode"] = geocode;
    if (lang) params[@"lang"] = lang;
    if (locale) params[@"locale"] = locale;
    if (until) params[@"until"] = until;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (callback) params[@"callback"] = callback;
    
    return [self GET:@"search/tweets.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getSearchTweetsWithQuery:(NSString *)query
                                              count:(NSUInteger)count
                                            sinceID:(int64_t)sinceID
                                              maxID:(int64_t)maxID
                                         resultType:(TWAPISearchResultType)resultType
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable searchResult, NSError * __nullable error))completion
{
    return [self getSearchTweetsWithQuery:query
                                    count:count
                                  sinceID:sinceID
                                    maxID:maxID
                               resultType:resultType
                                  geocode:nil
                                     lang:nil
                                   locale:nil
                                    until:nil
                          includeEntities:YES
                                 callback:nil
                               completion:completion];
}

#pragma mark - Users

- (TWAPIRequestOperation *)getUsersShowWithUserID:(int64_t)userID
                                     orScreenName:(NSString * __nullable)screenName
                                  includeEntities:(BOOL)includeEntities
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion;
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"users/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getUsersLookupWithUserIDs:(NSArray * __nullable)userIDs
                                       orScreenNames:(NSArray * __nullable)screenNames
                                     includeEntities:(BOOL)includeEntities
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(userIDs || screenNames);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userIDs) params[@"user_id"] = [userIDs componentsJoinedByString:@","];
    if (screenNames) params[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"users/lookup.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getUsersSearchWithQuery:(NSString *)query
                                             count:(NSUInteger)count
                                              page:(NSUInteger)page
                                   includeEntities:(BOOL)includeEntities
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(query);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (query) params[@"q"] = query;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (page) params[@"page"] = tw_uintegerStr(page);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"users/search.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getUsersProfileBannerWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable profileBanner, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self GET:@"users/profile_banner.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getUsersSuggestionsWithLang:(NSString * __nullable)lang
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable suggestions, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (lang) params[@"lang"] = lang;
    
    return [self GET:@"users/suggestions.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getUsersSuggestionsSlugWithSlug:(NSString *)slug
                                                      lang:(NSString * __nullable)lang
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable suggestedUsers, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (lang) params[@"lang"] = lang;
    
    return [self GET:[NSString stringWithFormat:@"users/suggestions/%@.json", slug]
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getUsersSuggestionsSlugMembersWithSlug:(NSString *)slug
                                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    
    return [self GET:[NSString stringWithFormat:@"users/suggestions/%@/members.json", slug]
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postUsersReportSpamWithUserID:(int64_t)userID
                                              screenName:(NSString * __nullable)screenName
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"users/report_spam.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark - Account

- (TWAPIRequestOperation *)postAccountUpdateProfileWithName:(NSString * __nullable)name
                                                        url:(NSString * __nullable)url
                                                   location:(NSString * __nullable)location
                                                description:(NSString * __nullable)description
                                           profileLinkColor:(NSString * __nullable)profileLinkColor
                                            includeEntities:(BOOL)includeEntities
                                                 skipStatus:(BOOL)skipStatus
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) params[@"name"] = name;
    if (url) params[@"url"] = url;
    if (location) params[@"location"] = location;
    if (description) params[@"description"] = description;
    if (profileLinkColor) params[@"profile_link_color"] = profileLinkColor;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self POST:@"account/update_profile.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
    
}

- (TWAPIRequestOperation *)postAccountUpdateProfileImageWithImage:(NSData *)image
                                                  includeEntities:(BOOL)includeEntities
                                                       skipStatus:(BOOL)skipStatus
                                                   uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(image);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kTWPostData] = [[TWPostData alloc] initWithData:image
                                                      name:@"image"
                                                  fileName:@"image.jpg"];
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self POST:@"account/update_profile.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
       uploadProgress:uploadProgress
           completion:completion];
}

- (TWAPIRequestOperation *)postAccountUpdateProfileBackgroundImageWithImage:(NSData * __nullable)image
                                                            includeEntities:(BOOL)includeEntities
                                                                 skipStatus:(BOOL)skipStatus
                                                                        use:(BOOL)use
                                                             uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (image) {
        params[kTWPostData] = [[TWPostData alloc] initWithData:image
                                                          name:@"image"
                                                      fileName:@"image.jpg"];
    }
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    if (use) params[@"use"] = tw_boolStr(use);
    
    return [self POST:@"account/update_profile_background_image.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
       uploadProgress:uploadProgress
           completion:completion];
}

- (TWAPIRequestOperation *)postAccountUpdateProfileBannerWithBanner:(NSData *)banner
                                                              width:(NSString * __nullable)width
                                                             height:(NSString * __nullable)height
                                                         offsetLeft:(NSString * __nullable)offsetLeft
                                                          offsetTop:(NSString * __nullable)offsetTop
                                                     uploadProgress:(void (^ __nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) uploadProgress
                                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kTWPostData] = [[TWPostData alloc] initWithData:banner
                                                      name:@"banner"
                                                  fileName:@"banner.jpg"];
    if (width) params[@"width"] = width;
    if (height) params[@"height"] = height;
    if (offsetLeft) params[@"offset_left"] = offsetLeft;
    if (offsetTop) params[@"offset_top"] = offsetTop;
    
    return [self POST:@"account/update_profile_banner.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
       uploadProgress:uploadProgress
           completion:completion];
}

- (TWAPIRequestOperation *)postAccountRemoveProfileBannerWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    return [self POST:@"account/remove_profile_banner.json"
           parameters:nil
           completion:completion];
}

- (TWAPIRequestOperation *)getAccountSettingsWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable settings, NSError * __nullable error))completion
{
    return [self GET:@"account/settings.json"
          parameters:nil
          completion:completion];
}

- (TWAPIRequestOperation *)postAccountSettingsWithSleepTimeEnabled:(BOOL)sleepTimeEnabled
                                                    startSleepTime:(NSString * __nullable)startSleepTime
                                                      endSleepTime:(NSString * __nullable)endSleepTime
                                                          timeZone:(NSString * __nullable)timeZone
                                                trendLocationWOEID:(int32_t)trendLocationWOEID
                                           allowContributorRequest:(NSString * __nullable)allowContributorRequest
                                                              lang:(NSString * __nullable)lang
                                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable settings, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sleep_time_enabled"] = tw_boolStr(sleepTimeEnabled);
    if (startSleepTime) params[@"start_sleep_ime"] = startSleepTime;
    if (endSleepTime) params[@"end_sleep_time"] = endSleepTime;
    if (timeZone) params[@"time_zone"] = timeZone;
    if (trendLocationWOEID) params[@"trend_location_woeid"] = tw_int32Str(trendLocationWOEID);
    if (allowContributorRequest) params[@"allow_contributor_equest"] = allowContributorRequest;
    if (lang) params[@"lang"] = lang;
    
    return [self POST:@"users/report_spam.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postAccountUpdateDeliveryDeviceWithDevice:(NSString *)device
                                                      includeEntites:(BOOL)includeEntities
                                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable json, NSError * __nullable error))completion
{
    NSParameterAssert(device);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (device) params[@"device"] = device;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self POST:@"account/update_delivery_device.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)getAccountVerifyCredentialsWithIncludeEntites:(BOOL)includeEntities
                                                              skipStatus:(BOOL)skipStatus
                                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    return [self.auth getAccountVerifyCredentialsWithIncludeEntites:includeEntities
                                                         skipStatus:skipStatus
                                                         completion:completion];
}

#pragma mark - Friendships

- (TWAPIRequestOperation *)getFriendshipsShowWithSourceID:(int64_t)sourceID
                                       orSourceScreenName:(NSString * __nullable)sourceScreenName
                                                 targetID:(int64_t)targetID
                                       orTargetScreenName:(NSString * __nullable)targetScreenName
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable friendship, NSError * __nullable error))completion
{
    NSParameterAssert(sourceID || sourceScreenName);
    NSParameterAssert(targetID || targetScreenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (sourceID) params[@"source_id"] = tw_int64Str(sourceID);
    if (sourceScreenName) params[@"source_screen_name"] = sourceScreenName;
    if (targetID) params[@"target_id"] = tw_int64Str(targetID);
    if (targetScreenName) params[@"target_screen_name"] = targetScreenName;
    
    return [self GET:@"friendships/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getFriendshipsLookupWithUserIDs:(NSArray * __nullable)userIDs
                                             orScreenNames:(NSArray * __nullable)screenNames
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable friendships, NSError * __nullable error))completion
{
    NSParameterAssert(userIDs || screenNames);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userIDs) params[@"user_id"] = [userIDs componentsJoinedByString:@","];
    if (screenNames) params[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    
    return [self GET:@"friendships/lookup.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postFriendshipsCreateWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    /**
     *  Turn on mobile notifications in Officail Twitter app.
     *  https://support.twitter.com/articles/20169920-receiving-sms-notifications-for-tweets-and-interactions#tweet-notifications
     */
    // if (follow) params[@"follow"] = tw_boolStr(follow);
    
    return [self POST:@"friendships/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postFriendshipsDestroyWithUserID:(int64_t)userID
                                               orScreenName:(NSString * __nullable)screenName
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"friendships/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postFriendshipsUpdateWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                    device:(NSNumber *)deviceBoolNum
                                                  retweets:(NSNumber *)retweetsBoolNum
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable relationship, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (deviceBoolNum) params[@"device"] = deviceBoolNum.stringValue;
    if (retweetsBoolNum) params[@"retweets"] = retweetsBoolNum.stringValue;
    
    return [self POST:@"friendships/update"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)getFriendshipsNoRetweetsIDsWithStringifyIDs:(BOOL)stringifyIDs
                                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable userIDs, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (stringifyIDs) params[@"stringify_ids"] = tw_boolStr(stringifyIDs);
    
    return [self GET:@"friendships/no_retweets/ids.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getFriendshipsIncomingWithCursor:(int64_t)cursor
                                               stringifyIDs:(BOOL)stringifyIDs
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (stringifyIDs) params[@"stringify_ids"] = tw_boolStr(stringifyIDs);
    
    return [self GET:@"friendships/incoming.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getFriendshipsOutgoingWithCursor:(int64_t)cursor
                                               stringifyIDs:(BOOL)stringifyIDs
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (stringifyIDs) params[@"stringify_ids"] = tw_boolStr(stringifyIDs);
    
    return [self GET:@"friendships/outgoing.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark - Friends

- (TWAPIRequestOperation *)getFriendsIDsWithUserID:(int64_t)userID
                                      orScreenName:(NSString * __nullable)screenName
                                             count:(NSUInteger)count
                                            cursor:(int64_t)cursor
                                      stringifyIDs:(BOOL)stringifyIDs
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (stringifyIDs) params[@"stringify_ids"] = tw_boolStr(stringifyIDs);
    
    return [self GET:@"friends/ids.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getFriendsListWithUserID:(int64_t)userID
                                       orScreenName:(NSString * __nullable)screenName
                                              count:(NSUInteger)count
                                             cursor:(int64_t)cursor
                                         skipStatus:(BOOL)skipStatus
                                includeUserEntities:(BOOL)includeUserEntities
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    if (includeUserEntities) params[@"include_user_entities"] = tw_boolStr(includeUserEntities);
    
    return [self GET:@"friends/list.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark - Followers

- (TWAPIRequestOperation *)getFollowersIDsWithUserID:(int64_t)userID
                                        orScreenName:(NSString * __nullable)screenName
                                               count:(NSUInteger)count
                                              cursor:(int64_t)cursor
                                        stringifyIDs:(BOOL)stringifyIDs
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (stringifyIDs) params[@"stringify_ids"] = tw_boolStr(stringifyIDs);
    
    return [self GET:@"followers/ids.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getFollowersListWithUserID:(int64_t)userID
                                         orScreenName:(NSString * __nullable)screenName
                                                count:(NSUInteger)count
                                               cursor:(int64_t)cursor
                                           skipStatus:(BOOL)skipStatus
                                  includeUserEntities:(BOOL)includeUserEntities
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    if (includeUserEntities) params[@"include_user_entities"] = tw_boolStr(includeUserEntities);
    
    return [self GET:@"followers/list.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark - Lists

- (TWAPIRequestOperation *)getListsStatusesWithListID:(int64_t)listID
                                                count:(NSUInteger)count
                                              sinceID:(int64_t)sinceID
                                                maxID:(int64_t)maxID
                                      includeEntities:(BOOL)includeEntities
                                           includeRTs:(BOOL)includeRTs
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (includeRTs) params[@"include_rts"] = tw_boolStr(includeRTs);
    
    return [self GET:@"lists/statuses.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsStatusesWithSlug:(NSString *)slug
                                            ownerID:(int64_t)ownerID
                                  orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                              count:(NSUInteger)count
                                            sinceID:(int64_t)sinceID
                                              maxID:(int64_t)maxID
                                    includeEntities:(BOOL)includeEntities
                                         includeRTs:(BOOL)includeRTs
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable tweets, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (includeRTs) params[@"include_rts"] = tw_boolStr(includeRTs);
    
    return [self GET:@"lists/statuses.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getListsShowWithListID:(int64_t)listID
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    
    return [self GET:@"lists/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsShowWithSlug:(NSString *)slug
                                        ownerID:(int64_t)ownerID
                              orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    
    return [self GET:@"lists/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postListsCreateWithName:(NSString *)name
                                              mode:(NSString * __nullable)mode
                                       description:(NSString * __nullable)description
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    NSParameterAssert(name);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) params[@"name"] = name;
    if (mode) params[@"mode"] = mode;
    if (description) params[@"description"] = description;
    
    return [self POST:@"lists/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsUpdateWithListID:(int64_t)listID
                                                name:(NSString * __nullable)name
                                                mode:(NSString * __nullable)mode
                                         description:(NSString * __nullable)description
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (name) params[@"name"] = name;
    if (mode) params[@"mode"] = mode;
    if (description) params[@"description"] = description;
    
    return [self POST:@"lists/update.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsUpdateWithSlug:(NSString *)slug
                                           ownerID:(int64_t)ownerID
                                 orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                              name:(NSString * __nullable)name
                                              mode:(NSString * __nullable)mode
                                       description:(NSString * __nullable)description
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (name) params[@"name"] = name;
    if (mode) params[@"mode"] = mode;
    if (description) params[@"description"] = description;
    
    return [self POST:@"lists/update.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsDestroyWithListID:(int64_t)listID
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    
    return [self POST:@"lists/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
    
}

- (TWAPIRequestOperation *)postListsDestroyWithSlug:(NSString *)slug
                                            ownerID:(int64_t)ownerID
                                  orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable list, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    
    return [self POST:@"lists/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getListsMembersWithListID:(int64_t)listID
                                               count:(NSUInteger)count
                                              cursor:(int64_t)cursor
                                     includeEntities:(BOOL)includeEntities
                                          skipStatus:(BOOL)skipStatus
                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/members.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
    
}

- (TWAPIRequestOperation *)getListsMembersWithSlug:(NSString *)slug
                                           ownerID:(int64_t)ownerID
                                 orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                             count:(NSUInteger)count
                                            cursor:(int64_t)cursor
                                   includeEntities:(BOOL)includeEntities
                                        skipStatus:(BOOL)skipStatus
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/members.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsMembersShowWithListID:(int64_t)listID
                                                  userID:(int64_t)userID
                                            orScreenName:(NSString * __nullable)screenName
                                         includeEntities:(BOOL)includeEntities
                                              skipStatus:(BOOL)skipStatus
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/members/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsMembersShowWithSlug:(NSString *)slug
                                               ownerID:(int64_t)ownerID
                                     orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                userID:(int64_t)userID
                                          orScreenName:(NSString * __nullable)screenName
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/members/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postListsMembersCreateWithListID:(int64_t)listID
                                                     userID:(int64_t)userID
                                               orScreenName:(NSString * __nullable)screenName
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/members/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsMembersCreateWithSlug:(NSString *)slug
                                                  ownerID:(int64_t)ownerID
                                        orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                   userID:(int64_t)userID
                                             orScreenName:(NSString * __nullable)screenName
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/members/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsMembersCreateAllWithListID:(int64_t)listID
                                                       userIDs:(NSArray * __nullable)userIDs
                                                 orScreenNames:(NSArray * __nullable)screenNames
                                                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userIDs || screenNames);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userIDs) params[@"user_id"] = [userIDs componentsJoinedByString:@","];
    if (screenNames) params[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    
    return [self POST:@"lists/members/create_all.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
    
}

- (TWAPIRequestOperation *)postListsMembersCreateAllWithSlug:(NSString *)slug
                                                     ownerID:(int64_t)ownerID
                                           orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                     userIDs:(NSArray * __nullable)userIDs
                                               orScreenNames:(NSArray * __nullable)screenNames
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userIDs || screenNames);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userIDs) params[@"user_id"] = [userIDs componentsJoinedByString:@","];
    if (screenNames) params[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    
    return [self POST:@"lists/members/create_all.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsMembersDestroyWithListID:(int64_t)listID
                                                      userID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/members/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsMembersDestroyWithSlug:(NSString *)slug
                                                   ownerID:(int64_t)ownerID
                                         orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                    userID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/members/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsMembersDestroyAllWithListID:(int64_t)listID
                                                        userIDs:(NSArray * __nullable)userIDs
                                                  orScreenNames:(NSArray * __nullable)screenNames
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userIDs || screenNames);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userIDs) params[@"user_id"] = [userIDs componentsJoinedByString:@","];
    if (screenNames) params[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    
    return [self POST:@"lists/members/destroy_all.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsMembersDestroyAllWithSlug:(NSString *)slug
                                                      ownerID:(int64_t)ownerID
                                            orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                      userIDs:(NSArray * __nullable)userIDs
                                                orScreenNames:(NSArray * __nullable)screenNames
                                                   completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userIDs || screenNames);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userIDs) params[@"user_id"] = [userIDs componentsJoinedByString:@","];
    if (screenNames) params[@"screen_name"] = [screenNames componentsJoinedByString:@","];
    
    return [self POST:@"lists/members/destroy_all.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getListsSubscribersWithListID:(int64_t)listID
                                                   count:(NSUInteger)count
                                                  cursor:(int64_t)cursor
                                         includeEntities:(BOOL)includeEntities
                                              skipStatus:(BOOL)skipStatus
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/subscribers.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
    
}

- (TWAPIRequestOperation *)getListsSubscribersWithSlug:(NSString *)slug
                                               ownerID:(int64_t)ownerID
                                     orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                 count:(NSUInteger)count
                                                cursor:(int64_t)cursor
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/subscribers.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsSubscribersShowWithListID:(int64_t)listID
                                                      userID:(int64_t)userID
                                                orScreenName:(NSString * __nullable)screenName
                                             includeEntities:(BOOL)includeEntities
                                                  skipStatus:(BOOL)skipStatus
                                                  completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/subscribers/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsSubscribersShowWithSlug:(NSString *)slug
                                                   ownerID:(int64_t)ownerID
                                         orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                    userID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                           includeEntities:(BOOL)includeEntities
                                                skipStatus:(BOOL)skipStatus
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"lists/subscribers/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postListsSubscribersCreateWithListID:(int64_t)listID
                                                         userID:(int64_t)userID
                                                   orScreenName:(NSString * __nullable)screenName
                                                     completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/subscribers/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsSubscribersCreateWithSlug:(NSString *)slug
                                                      ownerID:(int64_t)ownerID
                                            orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                       userID:(int64_t)userID
                                                 orScreenName:(NSString * __nullable)screenName
                                                   completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/subscribers/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsSubscribersDestroyWithListID:(int64_t)listID
                                                          userID:(int64_t)userID
                                                    orScreenName:(NSString * __nullable)screenName
                                                      completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(listID);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (listID) params[@"list_id"] = tw_int64Str(listID);
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/subscribers/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postListsSubscribersDestroyWithSlug:(NSString *)slug
                                                       ownerID:(int64_t)ownerID
                                             orOwnerScreenName:(NSString * __nullable)ownerScreenName
                                                        userID:(int64_t)userID
                                                  orScreenName:(NSString * __nullable)screenName
                                                    completion:(void (^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    NSParameterAssert(slug);
    NSParameterAssert(ownerID || ownerScreenName);
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (slug) params[@"slug"] = slug;
    if (ownerID) params[@"owner_id"] = tw_int64Str(ownerID);
    if (ownerScreenName) params[@"owner_screen_name"] = ownerScreenName;
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"lists/subscribers/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getListsListWithUserID:(int64_t)userID
                                     orScreenName:(NSString * __nullable)screenName
                                          reverse:(BOOL)reverse
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable lists, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (reverse) params[@"reverse"] = tw_boolStr(reverse);
    
    return [self GET:@"lists/list.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsOwnershipsWithUserID:(int64_t)userID
                                           orScreenName:(NSString * __nullable)screenName
                                                  count:(NSUInteger)count
                                                 cursor:(int64_t)cursor
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    
    return [self GET:@"lists/ownerships.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsSubscriptionsWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                     count:(NSUInteger)count
                                                    cursor:(int64_t)cursor
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    
    return [self GET:@"lists/subscriptions.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getListsMembershipsWithUserID:(int64_t)userID
                                            orScreenName:(NSString * __nullable)screenName
                                                   count:(NSUInteger)count
                                                  cursor:(int64_t)cursor
                                      filterToOwnedLists:(BOOL)filterToOwnedLists
                                              completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable lists, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (filterToOwnedLists) params[@"filter_to_owned_lists"] = tw_boolStr(filterToOwnedLists);
    
    return [self GET:@"lists/memberships.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark - Blocks

- (TWAPIRequestOperation *)getBlocksListWithCursor:(int64_t)cursor
                                   includeEntities:(BOOL)includeEntities
                                        skipStatus:(BOOL)skipStatus
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"blocks/list.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getBlocksIDsWithCursor:(int64_t)cursor
                                     stringifyIDs:(BOOL)stringifyIDs
                                       completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (stringifyIDs) params[@"stringify_ids"] = tw_boolStr(stringifyIDs);
    
    return [self GET:@"blocks/ids.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postBlocksCreateWithUserID:(int64_t)userID
                                         orScreenName:(NSString * __nullable)screenName
                                      includeEntities:(BOOL)includeEntities
                                           skipStatus:(BOOL)skipStatus
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self POST:@"blocks/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postBlocksDestroyWithUserID:(int64_t)userID
                                          orScreenName:(NSString * __nullable)screenName
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self POST:@"blocks/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark - Mutes

- (TWAPIRequestOperation *)getMutesUsersListWithCursor:(int64_t)cursor
                                       includeEntities:(BOOL)includeEntities
                                            skipStatus:(BOOL)skipStatus
                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable users, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"mutes/users/list.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getMutesUsersIDsWithCursor:(int64_t)cursor
                                         stringifyIDs:(BOOL)stringifyIDs
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable identifiers, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (cursor) params[@"cursor"] = tw_int64Str(cursor);
    if (stringifyIDs) params[@"stringify_ids"] = tw_boolStr(stringifyIDs);
    
    return [self GET:@"mutes/users/ids.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postMutesUsersCreateWithUserID:(int64_t)userID
                                             orScreenName:(NSString * __nullable)screenName
                                               completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    
    return [self POST:@"mutes/users/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postMutesUsersDestroyWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                           includeEntities:(BOOL)includeEntities
                                                skipStatus:(BOOL)skipStatus
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable user, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self POST:@"mutes/users/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark - Saved Searches

- (TWAPIRequestOperation *)getSavedSearchesListWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable savedSearches, NSError * __nullable error))completion
{
    return [self GET:@"saved_searches/list.json"
          parameters:nil
          completion:completion];
}

- (TWAPIRequestOperation *)getSavedSearchesShowIDWithSavedSearchID:(int64_t)savedSearchID
                                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable savedSearche, NSError * __nullable error))completion
{
    NSParameterAssert(savedSearchID);
    
    NSString *savedSearchIDStr = tw_int64Str(savedSearchID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (savedSearchID) params[@"id"] = savedSearchIDStr;
    
    return [self GET:[NSString stringWithFormat:@"saved_searches/show/%@.json]", savedSearchIDStr]
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postSavedSearchesCreateWithQuery:(NSString *)query
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable savedSearche, NSError * __nullable error))completion
{
    NSParameterAssert(query);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (query) params[@"query"] = query;
    
    return [self POST:@"saved_searches/create.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postSavedSearchesDestroyIDWithSavedSearchID:(int64_t)savedSearchID
                                                            completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable savedSearche, NSError * __nullable error))completion
{
    NSParameterAssert(savedSearchID);
    
    NSString *savedSearchIDStr = tw_int64Str(savedSearchID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (savedSearchID) params[@"id"] = savedSearchIDStr;
    
    return [self POST:[NSString stringWithFormat:@"saved_searches/destroy/%@.json]", savedSearchIDStr]
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark - Trends

- (TWAPIRequestOperation *)getTrendsPlaceWithWOEID:(int32_t)woeid
                                        completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trends, NSError * __nullable error))completion
{
    NSParameterAssert(woeid);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (woeid) params[@"id"] = tw_int32Str(woeid);
    
    return [self GET:@"trends/place.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getTrendsAvailableWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trendLocations, NSError * __nullable error))completion
{
    return [self GET:@"trends/available.json"
          parameters:nil
          completion:completion];
}

- (TWAPIRequestOperation *)getTrendsClosestWithLatitude:(NSString *)latitude
                                              longitude:(NSString *)longitude
                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable trendLocations, NSError * __nullable error))completion
{
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (latitude) params[@"lat"] = latitude;
    if (longitude) params[@"long"] = longitude;
    
    return [self GET:@"trends/closest.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark - Geo

- (TWAPIRequestOperation *)getGeoIDPlaceIDWithPlaceID:(NSString *)placeID
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable place, NSError * __nullable error))completion
{
    NSParameterAssert(placeID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (placeID) params[@"place_id"] = placeID;
    
    return [self GET:[NSString stringWithFormat:@"geo/id/%@.json", placeID]
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getGeoReverseGeocodeWithLatitude:(NSString *)latitude
                                                  longitude:(NSString *)longitude
                                                   accuracy:(NSString * __nullable)accuracy
                                                granularity:(NSString * __nullable)granularity
                                                 maxResults:(NSUInteger)maxResults
                                                   callback:(NSString * __nullable)callback
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion
{
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (latitude) params[@"lat"] = latitude;
    if (longitude) params[@"long"] = longitude;
    if (accuracy) params[@"accuracy"] = accuracy;
    if (granularity) params[@"granularity"] = granularity;
    if (maxResults) params[@"max_results"] = tw_uintegerStr(maxResults);
    if (callback) params[@"callback"] = callback;
    
    return [self GET:@"geo/reverse_geocode.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark -

- (TWAPIRequestOperation *)getGeoSearchWithLatitude:(NSString * __nullable)latitude
                                          longitude:(NSString * __nullable)longitude
                                               orIP:(NSString * __nullable)ip
                                            orQuery:(NSString * __nullable)query
                                           accuracy:(NSString * __nullable)accuracy
                                        granularity:(NSString * __nullable)granularity
                                         maxResults:(NSUInteger)maxResults
                                    containedWithin:(NSString * __nullable)containedWithin
                             attributeStreetAddress:(NSString * __nullable)attributeStreetAddress
                                           callback:(NSString * __nullable)callback
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion
{
    NSParameterAssert((latitude && longitude) || ip || query);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (latitude) params[@"lat"] = latitude;
    if (longitude) params[@"long"] = longitude;
    if (ip) params[@"ip"] = ip;
    if (query) params[@"query"] = query;
    if (accuracy) params[@"accuracy"] = accuracy;
    if (granularity) params[@"granularity"] = granularity;
    if (maxResults) params[@"max_results"] = tw_uintegerStr(maxResults);
    if (containedWithin) params[@"contained_within"] = containedWithin;
    // TODO: Investigate specifications
    // if (attributeStreetAddress) params[@""] = attributeStreetAddress;
    if (callback) params[@"callback"] = callback;
    
    return [self GET:@"geo/search.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getGeoSearchWithLatitude:(NSString *)latitude
                                          longitude:(NSString *)longitude
                                           accuracy:(NSString * __nullable)accuracy
                                        granularity:(NSString * __nullable)granularity
                                         maxResults:(NSUInteger)maxResults
                                    containedWithin:(NSString * __nullable)containedWithin
                             attributeStreetAddress:(NSString * __nullable)attributeStreetAddress
                                           callback:(NSString * __nullable)callback
                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion
{
    return [self getGeoSearchWithLatitude:latitude
                                longitude:longitude
                                     orIP:nil
                                  orQuery:nil
                                 accuracy:accuracy
                              granularity:granularity
                               maxResults:maxResults
                          containedWithin:containedWithin
                   attributeStreetAddress:attributeStreetAddress
                                 callback:callback
                               completion:completion];
}

- (TWAPIRequestOperation *)getGeoSearchWithIP:(NSString *)ip
                                     accuracy:(NSString * __nullable)accuracy
                                  granularity:(NSString * __nullable)granularity
                                   maxResults:(NSUInteger)maxResults
                              containedWithin:(NSString * __nullable)containedWithin
                       attributeStreetAddress:(NSString * __nullable)attributeStreetAddress
                                     callback:(NSString * __nullable)callback
                                   completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion
{
    return [self getGeoSearchWithLatitude:nil
                                longitude:nil
                                     orIP:ip
                                  orQuery:nil
                                 accuracy:accuracy
                              granularity:granularity
                               maxResults:maxResults
                          containedWithin:containedWithin
                   attributeStreetAddress:attributeStreetAddress
                                 callback:callback
                               completion:completion];
}

- (TWAPIRequestOperation *)getGeoSearchWithQuery:(NSString *)query
                                        accuracy:(NSString * __nullable)accuracy
                                     granularity:(NSString * __nullable)granularity
                                      maxResults:(NSUInteger)maxResults
                                 containedWithin:(NSString * __nullable)containedWithin
                          attributeStreetAddress:(NSString * __nullable)attributeStreetAddress
                                        callback:(NSString * __nullable)callback
                                      completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable geoResult, NSError * __nullable error))completion
{
    return [self getGeoSearchWithLatitude:nil
                                longitude:nil
                                     orIP:nil
                                  orQuery:query
                                 accuracy:accuracy
                              granularity:granularity
                               maxResults:maxResults
                          containedWithin:containedWithin
                   attributeStreetAddress:attributeStreetAddress
                                 callback:callback
                               completion:completion];
}

#pragma mark - Direct Messages

- (TWAPIRequestOperation *)getDirectMessagesWithCount:(NSUInteger)count
                                              sinceID:(int64_t)sinceID
                                                maxID:(int64_t)maxID
                                      includeEntities:(BOOL)includeEntities
                                           skipStatus:(BOOL)skipStatus
                                           completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable messages, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (count) params[@"count"] = tw_uintegerStr(count);
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    if (skipStatus) params[@"skip_status"] = tw_boolStr(skipStatus);
    
    return [self GET:@"direct_messages.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getDirectMessagesSentWithSinceID:(int64_t)sinceID
                                                      maxID:(int64_t)maxID
                                                       Page:(NSUInteger)page
                                            includeEntities:(BOOL)includeEntities
                                                 completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable messages, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (sinceID) params[@"since_id"] = tw_int64Str(sinceID);
    if (maxID) params[@"max_id"] = tw_int64Str(maxID);
    if (page) params[@"page"] = tw_uintegerStr(page);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self GET:@"direct_messages/sent.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)getDirectMessagesShowWithDirectMessageID:(int64_t)directMessageID
                                                         completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable message, NSError * __nullable error))completion
{
    NSParameterAssert(directMessageID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (directMessageID) params[@"id"] = tw_int64Str(directMessageID);
    
    return [self GET:@"direct_messages/show.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

- (TWAPIRequestOperation *)postDirectMessagesNewWithUserID:(int64_t)userID
                                              orScreenName:(NSString * __nullable)screenName
                                                      text:(NSString *)text
                                                completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable message, NSError * __nullable error))completion
{
    NSParameterAssert(userID || screenName);
    NSParameterAssert(text);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userID) params[@"user_id"] = tw_int64Str(userID);
    if (screenName) params[@"screen_name"] = screenName;
    if (text) params[@"text"] = text;
    
    return [self POST:@"direct_messages/new.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

- (TWAPIRequestOperation *)postDirectMessagesDestroyWithDirectMessageID:(int64_t)directMessageID
                                                        includeEntities:(BOOL)includeEntities
                                                             completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable message, NSError * __nullable error))completion
{
    NSParameterAssert(directMessageID);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (directMessageID) params[@"id"] = tw_int64Str(directMessageID);
    if (includeEntities) params[@"include_entities"] = tw_boolStr(includeEntities);
    
    return [self POST:@"direct_messages/destroy.json"
           parameters:[NSDictionary dictionaryWithDictionary:params]
           completion:completion];
}

#pragma mark - Application

- (TWAPIRequestOperation *)getApplicationRateLimitStatusWithResource:(NSString * __nullable)resource
                                                          completion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable rateLimitStatus, NSError * __nullable error))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (resource) params[@"resource"] = resource;
    
    return [self GET:@"application/rate_limit_status.json"
          parameters:[NSDictionary dictionaryWithDictionary:params]
          completion:completion];
}

#pragma mark - Help

- (TWAPIRequestOperation *)getHelpLanguagesWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSArray * __nullable languages, NSError * __nullable error))completion
{
    return [self GET:@"help/languages.json"
          parameters:nil
          completion:completion];
}

- (TWAPIRequestOperation *)getHelpConfigurationWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable configuration, NSError * __nullable error))completion
{
    return [self GET:@"help/configuration.json"
          parameters:nil
          completion:completion];
}

- (TWAPIRequestOperation *)getHelpPrivacyWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable privacy, NSError * __nullable error))completion
{
    return [self GET:@"help/privacy.json"
          parameters:nil
          completion:completion];
}

- (TWAPIRequestOperation *)getHelpToSWithCompletion:(void (^)(TWAPIRequestOperation * __nullable operation, NSDictionary * __nullable tos, NSError * __nullable error))completion
{
    return [self GET:@"help/tos.json"
          parameters:nil
          completion:completion];
}

#pragma mark - Public Streams

- (TWAPIRequestOperation *)getStatusesSampleWithStream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                               failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    return [self sendRequestStreamWithHTTPMethod:kTWHTTPMethodGET
                                   baseURLString:kTWBaseURLString_Stream_1_1
                               relativeURLString:@"statuses/sample.json"
                                      parameters:nil
                                          stream:stream
                                         failure:failure];
}


- (TWAPIRequestOperation *)postStatusesFilterWithKeywords:(NSArray *)keywords
                                            followUserIDs:(NSArray * __nullable)followUserIDs
                                                locations:(NSString * __nullable)locations
                                                   stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                  failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    NSParameterAssert(keywords);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (keywords) params[@"track"] = [keywords componentsJoinedByString:@","];
    if (followUserIDs) params[@"follow"] = [followUserIDs componentsJoinedByString:@","];
    if (locations) params[@"locations"] = locations;
    
    return [self sendRequestStreamWithHTTPMethod:kTWHTTPMethodPOST
                                   baseURLString:kTWBaseURLString_Stream_1_1
                               relativeURLString:@"statuses/filter.json"
                                      parameters:[NSDictionary dictionaryWithDictionary:params]
                                          stream:stream
                                         failure:failure];
}

- (TWAPIRequestOperation *)postStatusesFilterWithKeywords:(NSArray *)keywords
                                                   stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                  failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    return [self postStatusesFilterWithKeywords:keywords
                                  followUserIDs:nil
                                      locations:nil
                                         stream:stream
                                        failure:failure];
}

#pragma mark - User Streams

- (TWAPIRequestOperation *)getUserWithUserOnly:(BOOL)userOnly
                                    allReplies:(BOOL)allReplies
                                     locations:(NSString * __nullable)locations
                            stringifyFriendIDs:(BOOL)stringifyFriendIDs
                                        stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                       failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userOnly) params[@"with"] = @"user";
    if (allReplies) params[@"replies"] = @"all";
    if (locations) params[@"locations"] = locations;
    if (stringifyFriendIDs) params[@"stringify_friend_ids"] = tw_boolStr(stringifyFriendIDs);
    
    return [self sendRequestStreamWithHTTPMethod:kTWHTTPMethodGET
                                   baseURLString:kTWBaseURLString_UserStream_1_1
                               relativeURLString:@"user.json"
                                      parameters:[NSDictionary dictionaryWithDictionary:params]
                                          stream:stream
                                         failure:failure];
}

- (TWAPIRequestOperation *)getUserWithStringifyFriendIDs:(BOOL)stringifyFriendIDs
                                                  stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                                 failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    return [self getUserWithUserOnly:NO
                          allReplies:NO
                           locations:nil
                  stringifyFriendIDs:stringifyFriendIDs
                              stream:stream
                             failure:failure];
}

- (TWAPIRequestOperation *)getUserWithStream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                     failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    return [self getUserWithUserOnly:NO
                          allReplies:NO
                           locations:nil
                  stringifyFriendIDs:YES
                              stream:stream
                             failure:failure];
}

#pragma mark - Site Streams

- (TWAPIRequestOperation *)getSiteWithFollowUserIDs:(NSArray *)followUserIDs
                                         followings:(BOOL)followings
                                         allReplies:(BOOL)allReplies
                                          locations:(NSString * __nullable)locations
                                 stringifyFriendIDs:(BOOL)stringifyFriendIDs
                                             stream:(void (^)(TWAPIRequestOperation *operation, NSDictionary *json, TWStreamJSONType type))stream
                                            failure:(void (^)(TWAPIRequestOperation *operation, NSError *error))failure
{
    NSParameterAssert(followUserIDs);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (followUserIDs) params[@"follow"] = [followUserIDs componentsJoinedByString:@","];
    if (followings) params[@"with"] = @"followings";
    if (allReplies) params[@"replies"] = @"all";
    if (locations) params[@"locations"] = locations;
    if (stringifyFriendIDs) params[@"stringify_friend_ids"] = tw_boolStr(stringifyFriendIDs);
    
    return [self sendRequestStreamWithHTTPMethod:kTWHTTPMethodGET
                                   baseURLString:kTWBaseURLString_SiteStream_1_1
                               relativeURLString:@"site.json"
                                      parameters:[NSDictionary dictionaryWithDictionary:params]
                                          stream:stream
                                         failure:failure];
}

#pragma mark - Firehose

@end
NS_ASSUME_NONNULL_END