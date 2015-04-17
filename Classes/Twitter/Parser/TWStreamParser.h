//
//  TWStreamParser.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Streaming message types
 *  https://dev.twitter.com/streaming/overview/messages-types
 *
 *  Events
 *  https://dev.twitter.com/streaming/overview/messages-types#Events_event
 */

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, TWStreamJSONType) {
    TWStreamJSONTypeTweet,
    TWStreamJSONTypeFriendsLists,
    TWStreamJSONTypeDelete,
    TWStreamJSONTypeScrubGeo,
    TWStreamJSONTypeLimit,
    TWStreamJSONTypeDisconnect,
    TWStreamJSONTypeWarning,
    TWStreamJSONTypeEventBlock,
    TWStreamJSONTypeEventUnblock,
    TWStreamJSONTypeEventFavorite,
    TWStreamJSONTypeEventUnfavorite,
    TWStreamJSONTypeEventFollow,
    TWStreamJSONTypeEventUnfollow,
    TWStreamJSONTypeEventUserUpdate,
    TWStreamJSONTypeEventListCreated,
    TWStreamJSONTypeEventListDestroyed,
    TWStreamJSONTypeEventListUpdated,
    TWStreamJSONTypeEventListMemberAdded,
    TWStreamJSONTypeEventListMemberRemoved,
    TWStreamJSONTypeEventListUserSubscribed,
    TWStreamJSONTypeEventListUserUnsubscribed,
    TWStreamJSONTypeEventAccessRevoked,
    TWStreamJSONTypeEventUnsupported,
    TWStreamJSONTypeStatusWithheld,
    TWStreamJSONTypeUserWithheld,
    TWStreamJSONTypeControl,
    
    TWStreamJSONTypeInvalidJSON,
    TWStreamJSONTypeTimeout,
    TWStreamJSONTypeUnsupported,
};

extern NSString *NSStringFromTWStreamJSONType(TWStreamJSONType type) __attribute__((used));

@interface TWStreamParser : NSObject <NSSecureCoding, NSCopying>

- (void)parseWithStreamData:(NSData *)data
                     parsed:(void (^)(NSDictionary *json, TWStreamJSONType type))parsedJsonBlock;

@end
NS_ASSUME_NONNULL_END
