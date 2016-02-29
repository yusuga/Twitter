//
//  TWAPIRequestOperationProtocol.h
//  Develop
//
//  Created by Yu Sugawara on 2016/02/28.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWAPIRequestOperationProtocol <NSObject>

- (void)cancel;
- (BOOL)isCancelled;

@end
