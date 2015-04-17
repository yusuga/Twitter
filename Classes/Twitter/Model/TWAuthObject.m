//
//  TWAuthObject.m
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuthObject.h"

NS_ASSUME_NONNULL_BEGIN
@implementation TWAuthObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            _dictionary = dictionary;
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, dictionary = %@", [super description], self.dictionary];
}

#pragma mark - Equal

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TWAuthObject class]]) {
        return NO;
    }
    
    TWAuthObject *authObj = object;
    return [self.dictionary isEqualToDictionary:authObj.dictionary];
}

- (NSUInteger)hash
{
    return self.dictionary.hash;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _dictionary = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dictionary))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dictionary
                  forKey:NSStringFromSelector(@selector(dictionary))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) obj = [[[self class] allocWithZone:zone] initWithDictionary:self.dictionary];
    return obj;
}

@end
NS_ASSUME_NONNULL_END