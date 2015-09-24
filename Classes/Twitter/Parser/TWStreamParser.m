//
//  TWStreamParser.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWStreamParser.h"

NS_ASSUME_NONNULL_BEGIN
NSString *NSStringFromTWStreamJSONType(TWStreamJSONType type) {
    switch (type) {
        case TWStreamJSONTypeTweet:
            return @"TWStreamJSONTypeTweet";
        case TWStreamJSONTypeFriendsLists:
            return @"TWStreamJSONTypeFriendsLists";
        case TWStreamJSONTypeDelete:
            return @"TWStreamJSONTypeDelete";
        case TWStreamJSONTypeScrubGeo:
            return @"TWStreamJSONTypeScrubGeo";
        case TWStreamJSONTypeLimit:
            return @"TWStreamJSONTypeLimit";
        case TWStreamJSONTypeDisconnect:
            return @"TWStreamJSONTypeDisconnect";
        case TWStreamJSONTypeWarning:
            return @"TWStreamJSONTypeWarning";
        case TWStreamJSONTypeEventBlock:
            return @"TWStreamJSONTypeEventBlock";
        case TWStreamJSONTypeEventUnblock:
            return @"TWStreamJSONTypeEventUnblock";
        case TWStreamJSONTypeEventFavorite:
            return @"TWStreamJSONTypeEventFavorite";
        case TWStreamJSONTypeEventUnfavorite:
            return @"TWStreamJSONTypeEventUnfavorite";
        case TWStreamJSONTypeEventFollow:
            return @"TWStreamJSONTypeEventFollow";
        case TWStreamJSONTypeEventUnfollow:
            return @"TWStreamJSONTypeEventUnfollow";
        case TWStreamJSONTypeEventUserUpdate:
            return @"TWStreamJSONTypeEventUserUpdate";
        case TWStreamJSONTypeEventListCreated:
            return @"TWStreamJSONTypeEventListCreated";
        case TWStreamJSONTypeEventListDestroyed:
            return @"TWStreamJSONTypeEventListDestroyed";
        case TWStreamJSONTypeEventListUpdated:
            return @"TWStreamJSONTypeEventListUpdated";
        case TWStreamJSONTypeEventListMemberAdded:
            return @"TWStreamJSONTypeEventListMemberAdded";
        case TWStreamJSONTypeEventListMemberRemoved:
            return @"TWStreamJSONTypeEventListMemberRemoved";
        case TWStreamJSONTypeEventListUserSubscribed:
            return @"TWStreamJSONTypeEventListUserSubscribed";
        case TWStreamJSONTypeEventListUserUnsubscribed:
            return @"TWStreamJSONTypeEventListUserUnsubscribed";
        case TWStreamJSONTypeEventAccessRevoked:
            return @"TWStreamJSONTypeEventAccessRevoked";
        case TWStreamJSONTypeEventUnsupported:
            return @"TWStreamJSONTypeEventUnsupported";
        case TWStreamJSONTypeStatusWithheld:
            return @"TWStreamJSONTypeStatusWithheld";
        case TWStreamJSONTypeUserWithheld:
            return @"TWStreamJSONTypeUserWithheld";
        case TWStreamJSONTypeControl:
            return @"TWStreamJSONTypeControl";
        case TWStreamJSONTypeInvalidJSON:
            return @"TWStreamJSONTypeInvalidJSON";
        case TWStreamJSONTypeTimeout:
            return @"TWStreamJSONTypeTimeout";
        default:
        case TWStreamJSONTypeUnsupported:
            return @"TWStreamJSONTypeUnsupported";
    }
}

static inline BOOL isDigitsOnlyString(NSString *str) {
    static NSCharacterSet *__notDigits;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    });
    return str.length && [str rangeOfCharacterFromSet:__notDigits].location == NSNotFound;
}

@interface TWStreamParser ()

@property (nonatomic, nullable) NSMutableString *receivedMessage;
@property (nonatomic) NSInteger bytesExpected;

@end


@implementation TWStreamParser

- (void)parseWithStreamData:(NSData *)data
                     parsed:(void (^)(NSDictionary *json, TWStreamJSONType type))parsed
{
    static NSString * const kDelimiter = @"\r\n";
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    for (NSString* part in [response componentsSeparatedByString:kDelimiter]) {
        
        if (self.receivedMessage == nil) {
            if (isDigitsOnlyString(part)) {
                self.receivedMessage = [NSMutableString string];
                self.bytesExpected = [part intValue];
            }
        } else if (self.bytesExpected > 0) {
            if (self.receivedMessage.length < self.bytesExpected) {
                // Append the data
                if (part.length > 0) {
                    [self.receivedMessage appendString:part];
                } else {
                    [self.receivedMessage appendString:kDelimiter];
                }
                if (self.receivedMessage.length + kDelimiter.length == self.bytesExpected) {
                    [self.receivedMessage appendString:kDelimiter];
                    // Success!
                    NSError *error = nil;
                    id json = [NSJSONSerialization JSONObjectWithData:[self.receivedMessage dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:NSJSONReadingAllowFragments
                                                                error:&error];
                    if (error) {
                        parsed(@{@"json parsed error" : error}, TWStreamJSONTypeInvalidJSON);
                    } else {
                        parsed(json, [[self class] streamJSONTypeForJSON:json]);
                    }
                    
                    // Reset
                    self.receivedMessage = nil;
                    self.bytesExpected = 0;
                }
            } else {
                self.receivedMessage = nil;
                self.bytesExpected = 0;
            }
        } else {
            self.receivedMessage = nil;
            self.bytesExpected = 0;
        }
    }
}

+ (TWStreamJSONType)streamJSONTypeForJSON:(id)json
{
    if ([json isKindOfClass:[NSDictionary class]]) {
        if (json[@"source"] && json[@"text"]) {
            return TWStreamJSONTypeTweet;
        } else if (json[@"friends"] || json[@"friends_str"]) {
            return TWStreamJSONTypeFriendsLists;
        } else if (json[@"delete"]) {
            return TWStreamJSONTypeDelete;
        } else if (json[@"limit"]) {
            return TWStreamJSONTypeLimit;
        } else if (json[@"disconnect"]) {
            return TWStreamJSONTypeDisconnect;
        } else if (json[@"warning"]) {
            return TWStreamJSONTypeWarning;
        } else if (json[@"event"]) {
            NSString *event = json[@"event"];
            if ([event isEqualToString:@"block"]) {
                return TWStreamJSONTypeEventBlock;
            } else if ([event isEqualToString:@"unblock"]) {
                return TWStreamJSONTypeEventUnblock;
            } else if ([event isEqualToString:@"favorite"]) {
                return TWStreamJSONTypeEventFavorite;
            } else if ([event isEqualToString:@"unfavorite"]) {
                return TWStreamJSONTypeEventUnfavorite;
            } else if ([event isEqualToString:@"follow"]) {
                return TWStreamJSONTypeEventFollow;
            } else if ([event isEqualToString:@"unfollow"]) {
                return TWStreamJSONTypeEventUnfollow;
            } else if ([event isEqualToString:@"user_update"]) {
                return TWStreamJSONTypeEventUserUpdate;
            } else if ([event isEqualToString:@"list_created"]) {
                return TWStreamJSONTypeEventListCreated;
            } else if ([event isEqualToString:@"list_destroyed"]) {
                return TWStreamJSONTypeEventListDestroyed;
            } else if ([event isEqualToString:@"list_updated"]) {
                return TWStreamJSONTypeEventListUpdated;
            } else if ([event isEqualToString:@"list_member_added"]) {
                return TWStreamJSONTypeEventListMemberAdded;
            } else if ([event isEqualToString:@"list_member_removed"]) {
                return TWStreamJSONTypeEventListMemberRemoved;
            } else if ([event isEqualToString:@"list_user_subscribed"]) {
                return TWStreamJSONTypeEventListUserSubscribed;
            } else if ([event isEqualToString:@"list_user_unsubscribed"]) {
                return TWStreamJSONTypeEventListUserUnsubscribed;
            } else if ([event isEqualToString:@"access_revoked"]) {
                return TWStreamJSONTypeEventAccessRevoked;
            }
            return TWStreamJSONTypeEventUnsupported;
        } else if (json[@"scrub_geo"]) {
            return TWStreamJSONTypeScrubGeo;
        } else if (json[@"status_withheld"]) {
            return TWStreamJSONTypeStatusWithheld;
        } else if (json[@"user_withheld"]) {
            return TWStreamJSONTypeUserWithheld;
        } else if (json[@"control"]) {
            return TWStreamJSONTypeControl;
        }
    }
    return TWStreamJSONTypeUnsupported;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.receivedMessage = [aDecoder decodeObjectOfClass:[NSMutableString class] forKey:NSStringFromSelector(@selector(receivedMessage))];
        self.bytesExpected = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(bytesExpected))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.receivedMessage forKey:NSStringFromSelector(@selector(receivedMessage))];
    [aCoder encodeInteger:self.bytesExpected forKey:NSStringFromSelector(@selector(bytesExpected))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone
{
    typeof(self) obj = [[[self class] allocWithZone:zone] init];
    if (obj) {
        obj.receivedMessage = [self.receivedMessage mutableCopy];
        obj.bytesExpected = self.bytesExpected;
    }
    return obj;
}

@end
NS_ASSUME_NONNULL_END
