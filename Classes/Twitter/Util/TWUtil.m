//
//  TWUtil.m
//  Develop
//
//  Created by Yu Sugawara on 2016/01/18.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import "TWUtil.h"

NSString *TWTweetURLString(NSString *screenName, NSNumber *tweetID)
{
    return [NSString stringWithFormat:@"https://twitter.com/%@/status/%@", screenName, tweetID];
}

@implementation TWUtil

@end
