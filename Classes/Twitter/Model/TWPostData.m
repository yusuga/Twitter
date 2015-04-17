//
//  TWPostData.m
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWPostData.h"

NS_ASSUME_NONNULL_BEGIN
@interface TWPostData ()

@property (nonatomic, readwrite) NSData *data;
@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *fileName;
@property (copy, nonatomic, readwrite) NSString *mimeType;

@end

@implementation TWPostData

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
{
    return [self initWithData:data
                         name:name];
}

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString * __nullable)fileName
{
    return [self initWithData:data
                         name:name
                     fileName:fileName
                     mimeType:nil];
}

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString * __nullable)fileName
                    mimeType:(NSString * __nullable)mimeType;
{
    if (self = [super init]) {
        self.data = data;
        self.name = name;
        self.fileName = fileName ?: @"image.jpg";
        self.mimeType = mimeType ?: @"application/octet-stream";
    }
    return self;
}

@end
NS_ASSUME_NONNULL_END