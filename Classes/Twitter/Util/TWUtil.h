//
//  TWUtil.h
//  Develop
//
//  Created by Yu Sugawara on 2016/01/18.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *TWTweetURLString(NSString *screenName, NSNumber *tweetID);

@interface TWUtil : NSObject

+ (NSString *)percentEscapedURLQueryWithParameters:(NSDictionary<NSString *, NSString *> *)parameters;

@end
