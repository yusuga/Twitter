//
//  TWPostData.h
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TWPostData : NSObject

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name;

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString * __nullable)fileName;

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString * __nullable)fileName
                    mimeType:(NSString * __nullable)mimeType;

@property (nonatomic, readonly) NSData *data;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *fileName; // Default: image.jpg
@property (copy, nonatomic, readonly) NSString *mimeType; // Default: @"application/octet-stream"

@end
NS_ASSUME_NONNULL_END