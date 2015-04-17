//
//  TWAPIResponseSerializer.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAPIResponseSerializer.h"
#import "TWAuthModels.h"
#import "TWConstants.h"

NS_ASSUME_NONNULL_BEGIN
@implementation NSString (ta)

- (BOOL)tw_containSuffixes:(NSArray *)suffixes
{
    for (NSString *suffix in suffixes) {
        if ([self hasSuffix:suffix]) return YES;
    }
    return NO;
}

@end

@implementation TWAPIResponseSerializer

- (instancetype)init
{
    if (self = [super init]) {
        self.acceptableContentTypes = [self.acceptableContentTypes setByAddingObject:@"text/html"];
    }
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if ([[response MIMEType] isEqualToString:@"text/html"]) {
        return nil;
    }
    return [super responseObjectForResponse:response
                                       data:data
                                      error:error];
}

@end
NS_ASSUME_NONNULL_END