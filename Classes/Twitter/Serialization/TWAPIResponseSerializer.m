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
        self.acceptableContentTypes = [self.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html", @"text/plain"]];
    }
    return self;
}

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError *__autoreleasing  __nullable * __nullable)error
{
    if ([[response MIMEType] isEqualToString:@"text/html"]) {
        return nil;
    } else if ([[response MIMEType] isEqualToString:@"text/plain"]) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return [super responseObjectForResponse:response
                                       data:data
                                      error:error];
}

@end
NS_ASSUME_NONNULL_END
