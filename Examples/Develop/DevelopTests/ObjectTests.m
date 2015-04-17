//
//  PrimitiveTests.m
//  Develop
//
//  Created by Yu Sugawara on 4/20/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Twitter.h"
#import "Constants.h"
#import "TWOAuth1.h"

@interface ObjectTests : XCTestCase

@end

@implementation ObjectTests

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

#pragma mark - Equal

- (void)testEqualWithAuth
{
    NSString *consumerKey = @"key";
    NSString *consumerSecret = @"secret";
    NSString *accessToken = @"token";
    NSString *accessTokenSecret = @"token-secret";
    
    TWAuth *userAuth1 = [TWAuth userAuthWithConsumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken accessTokenSecret:accessTokenSecret];
    TWAuth *userAuth2 = [TWAuth userAuthWithConsumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken accessTokenSecret:accessTokenSecret];
    XCTAssertEqual(userAuth1.hash, userAuth2.hash);
    XCTAssertEqualObjects(userAuth1, userAuth2);
    
    /*---*/
    
    ACAccountStore *store = [[ACAccountStore alloc] init];
    NSMutableArray *auths = [NSMutableArray array];
    
    [auths addObject:[[TWAuth alloc] init]];
    [auths addObject:[TWAuth userAuthWithAccount:[[ACAccount alloc] initWithAccountType:[store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]]]];
    [auths addObject:[[TWOAuth1 alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret]];
    [auths addObject:[TWAuth userAuthWithConsumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken accessTokenSecret:accessTokenSecret]];
    [auths addObject:[TWAuth appAuthWithConsumerKey:consumerKey consumerSecret:consumerSecret]];
    [auths addObject:[TWAuth appAuthWithConsumerKey:consumerKey consumerSecret:consumerSecret bearerAccessToken:accessToken]];
    
    [auths enumerateObjectsUsingBlock:^(TWAuth *auth1, NSUInteger idx1, BOOL *stop) {
        [auths enumerateObjectsUsingBlock:^(TWAuth *auth2, NSUInteger idx2, BOOL *stop) {
            if (idx1 != idx2) {
                XCTAssertNotEqual(auth1.hash, auth2.hash);
                XCTAssertNotEqualObjects(auth1, auth2);                
            }
        }];
    }];
}

- (void)testEqualWithAuthObject
{
    NSString *key = @"key";
    NSString *value = @"value";
    
    TWAuthObject *obj1 = [[TWAuthObject alloc] initWithDictionary:@{key : value}];
    TWAuthObject *obj2 = [[TWAuthObject alloc] initWithDictionary:@{key : value}];
    
    XCTAssertEqual(obj1.hash, obj2.hash);
    XCTAssertEqualObjects(obj1, obj2);
}

- (void)testEqualWithOAuth1Token
{
    NSString *consumerKey = @"key";
    NSString *consumerSecret = @"secret";
    NSString *accessToken = @"token";
    NSString *accessTokenSecret = @"token-secret";
    NSString *userID = @"user-id";
    NSString *screenName = @"screen-name";
    
    TWOAuth1Token *token1 = [[TWOAuth1Token alloc] initWithConsumerKey:consumerKey
                                                        consumerSecret:consumerSecret
                                                           accessToken:accessToken
                                                     accessTokenSecret:accessTokenSecret
                                                                userID:userID
                                                            screenName:screenName];
    TWOAuth1Token *token2 = [[TWOAuth1Token alloc] initWithConsumerKey:consumerKey
                                                        consumerSecret:consumerSecret
                                                           accessToken:accessToken
                                                     accessTokenSecret:accessTokenSecret
                                                                userID:userID
                                                            screenName:screenName];
    XCTAssertEqual(token1.hash, token2.hash);
    XCTAssertEqualObjects(token1, token2);
    
    TWOAuth1Token *token3 = [[TWOAuth1Token alloc] initWithConsumerKey:consumerKey
                                                        consumerSecret:consumerSecret
                                                           accessToken:accessToken
                                                     accessTokenSecret:accessTokenSecret
                                                                userID:userID
                                                            screenName:@"other-name"];
    XCTAssertNotEqual(token1.hash, token3.hash);
    XCTAssertNotEqualObjects(token1, token3);
}

#pragma mark - Coding

- (void)testCodingWithTWOAuth1Token
{
    NSString *consumerKey = @"key";
    NSString *consumerSecret = @"secret";
    NSString *accessToken = @"token";
    NSString *accessTokenSecret = @"token-secret";
    NSString *userID = @"user-id";
    NSString *screenName = @"screen-name";
    
    TWOAuth1Token *token = [[TWOAuth1Token alloc] initWithConsumerKey:consumerKey
                                                       consumerSecret:consumerSecret
                                                          accessToken:accessToken
                                                    accessTokenSecret:accessTokenSecret
                                                               userID:userID
                                                           screenName:screenName];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    
    TWOAuth1Token *unarchivedToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqual(token.hash, unarchivedToken.hash);
    XCTAssertEqualObjects(token, unarchivedToken);
}

#pragma mark - Copying

- (void)testCopyingWithTWOAuth1Token
{
    NSString *consumerKey = @"key";
    NSString *consumerSecret = @"secret";
    NSString *accessToken = @"token";
    NSString *accessTokenSecret = @"token-secret";
    NSString *userID = @"user-id";
    NSString *screenName = @"screen-name";
    
    TWOAuth1Token *token = [[TWOAuth1Token alloc] initWithConsumerKey:consumerKey
                                                       consumerSecret:consumerSecret
                                                          accessToken:accessToken
                                                    accessTokenSecret:accessTokenSecret
                                                               userID:userID
                                                           screenName:screenName];
    
    TWOAuth1Token *copiedToken = [token copy];
    
    XCTAssertEqual(token.hash, copiedToken.hash);
    XCTAssertEqualObjects(token, copiedToken);
}

@end
