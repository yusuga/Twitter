//
//  XMLParserTests.m
//  Develop
//
//  Created by Yu Sugawara on 9/28/15.
//  Copyright © 2015 Yu Sugawara. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWXMLParser.h"

@interface XMLParserTests : XCTestCase

@end

@implementation XMLParserTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseErrorXML
{
    NSString *xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><errors><error code=\"350\">Error processing your OAuth request: invalid signature or token</error></errors>";
    NSNumber *xmlCode = @(350);
    NSString *xmlMessage = @"Error processing your OAuth request: invalid signature or token";
    
    NSNumber *code;
    NSString *message;
    
    [TWXMLParser parseErrorXML:xml
                          code:&code
                       message:&message];
    
    XCTAssertEqualObjects(code, xmlCode);
    XCTAssertEqualObjects(message, xmlMessage);
}

@end
