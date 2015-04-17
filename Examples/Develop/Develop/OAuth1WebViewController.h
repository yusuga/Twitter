//
//  OAuth1WebViewController.h
//
//  Created by Yu Sugawara on 4/14/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Twitter.h"

NS_ASSUME_NONNULL_BEGIN
@interface OAuth1WebViewController : UIViewController

- (void)configureWithConsumerKey:(NSString *)consumerKey
                  consumerSecret:(NSString *)consumerSecret
                      completion:(void (^)(TWAuth * __nullable auth, NSError * __nullable error))completion;

@end
NS_ASSUME_NONNULL_END