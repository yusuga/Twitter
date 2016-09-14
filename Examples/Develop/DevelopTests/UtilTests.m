//
//  UtilTests.m
//  Develop
//
//  Created by Yu Sugawara on 2016/01/22.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWUtil.h"

@interface UtilTests : XCTestCase

@end

@implementation UtilTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPercentEscapedURLQuery
{    
    XCTAssertEqualObjects([TWUtil percentEscapedURLQueryWithParameters:@{@":#[]@!$&'()*+,;=?/" : @":#[]@!$&'()*+,;=?/"}],
                          @"%3A%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D%3F%2F=%3A%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D%3F%2F");
    XCTAssertEqualObjects([TWUtil percentEscapedURLQueryWithParameters:@{@"キー" : @"バリュー"}],
                          @"%E3%82%AD%E3%83%BC=%E3%83%90%E3%83%AA%E3%83%A5%E3%83%BC");
    
    XCTAssertEqualObjects([TWUtil percentEscapedURLQueryWithParameters:(@{@"key1" : @"value1",
                                                                          @"key2" : @"value2"})],
                          @"key1=value1&key2=value2");
}

@end
