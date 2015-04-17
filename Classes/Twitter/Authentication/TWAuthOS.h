//
//  TWAuthOS.h
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWAuth.h"
#import "TWAuthProtocol.h"
@import Accounts;

NS_ASSUME_NONNULL_BEGIN
@interface TWAuthOS : TWAuth <TWAuthProtocol>

/**
 *  Twitter account in iOS
 *
 *  https://support.apple.com/en-us/HT202605
 */
- (instancetype)initWithAccount:(ACAccount *)account;

@end
NS_ASSUME_NONNULL_END
