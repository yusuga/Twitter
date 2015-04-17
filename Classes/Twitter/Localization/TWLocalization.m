//
//  TWLocalization.m
//
//  Created by Yu Sugawara on 4/24/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWLocalization.h"

NSString *TWLocalizedString(NSString *key)
{
    return NSLocalizedStringFromTable(key, @"TWLocalizable", nil);
}

NSString *TWLocalizedTimeString(NSUInteger time)
{
    static NSUInteger const kSecondsPerMinutes = 60;
    
    NSMutableString *timeStr = [NSMutableString string];
    NSUInteger minutes = time/kSecondsPerMinutes;
    if (minutes) {
        [timeStr appendFormat:@"%zd%@", minutes, TWLocalizedString(@"Minutes short")];
    }
    NSUInteger seconds = time%kSecondsPerMinutes;
    [timeStr appendFormat:@"%zd%@", seconds, TWLocalizedString(@"Seconds short")];
    
    return [NSString stringWithString:timeStr];
}