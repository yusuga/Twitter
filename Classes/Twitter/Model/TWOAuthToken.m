//
//  TWOAuthToken.m
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWOAuthToken.h"
#import "NSString+TWTwitter.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWOAuthToken ()

@property (copy, nonatomic, readwrite) NSString *consumerKey;
@property (copy, nonatomic, readwrite) NSString *consumerSecret;

@end

@implementation TWOAuthToken

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                       consumerKey:(NSString *)consumerKey
                    consumerSecret:(NSString *)consumerSecret
{
    if (self = [super initWithDictionary:dictionary]) {
        self.consumerKey = consumerKey;
        self.consumerSecret = consumerSecret;
    }
    return self;
}

- (BOOL)isValid
{
    return (self.consumerKey && self.consumerSecret);
}

- (NSString *)description
{
    return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSUInteger)level
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ {\n", [super description]];
    NSString *indent = tw_indent(level + 1);
    
    [desc appendFormat:@"%@consumerKey = %@;\n", indent, [self consumerKey]];
    [desc appendFormat:@"%@consumerSecret = %@;\n", indent, [self consumerSecret]];
    
    return [NSString stringWithString:desc];
}

#pragma mark - NSSecureCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.consumerKey = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(consumerKey))];
        self.consumerSecret = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(consumerSecret))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.consumerKey forKey:NSStringFromSelector(@selector(consumerKey))];
    [aCoder encodeObject:self.consumerSecret forKey:NSStringFromSelector(@selector(consumerSecret))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithDictionary:self.dictionary
                                                     consumerKey:self.consumerKey
                                                  consumerSecret:self.consumerSecret];
}

@end
NS_ASSUME_NONNULL_END