//
//  NSString+TWTwitter.m
//  Develop
//
//  Created by Yu Sugawara on 4/21/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "NSString+TWTwitter.h"

NSString *tw_indent(NSUInteger level)
{
    NSMutableString *indent = [NSMutableString string];
    for (NSUInteger i = 0; i < level; i++) {
        [indent appendString:@"  "];
    }
    return [NSString stringWithString:indent];
};

@implementation NSString (TWTwitter)



@end
