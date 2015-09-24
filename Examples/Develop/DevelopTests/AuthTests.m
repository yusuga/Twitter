//
//  AuthTests.m
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Twitter.h"
#import "TWConstants.h"
#import "Constants.h"

@interface AuthTests : XCTestCase

@end

@implementation AuthTests

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

#pragma mark - User Auth

- (void)testAuthorizedUserAuth
{
    for (NSInteger i = 0; i < 2; i++) {
        NSString *consumerKey = [Constants consumerKey];
        NSString *consumerSecret = [Constants consumerSecret];
        NSString *accessToken = [Constants accessToken];
        NSString *accessTokenSecret = [Constants accessTokenSecret];
        TWAuth *auth;
        if (i) {
            auth = [TWAuth userAuthWithConsumerKey:consumerKey
                                    consumerSecret:consumerSecret
                                       accessToken:accessToken
                                 accessTokenSecret:accessTokenSecret];
            
        } else {
            auth = [TWAuth userAuthWithOAuth1Token:[[TWOAuth1Token alloc] initWithConsumerKey:consumerKey
                                                                               consumerSecret:consumerSecret
                                                                                  accessToken:accessToken
                                                                            accessTokenSecret:accessTokenSecret
                                                                                       userID:nil
                                                                                   screenName:nil]];
        }
        XCTAssertTrue([auth authorized]);
        XCTAssertNotNil([auth oauth1Token]);
        XCTAssertNil([auth oauth2Token]);
        
        /* Authorize */
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Authorize %s", __func__]];
        [auth authorizeWithCompletion:^(TWAuth * __nullable auth, NSError * __nullable error) {
            XCTAssertNotNil(auth);
            XCTAssertNil(error, @"error = %@", error);
            XCTAssertNotNil(auth.userID);
            XCTAssertNotNil(auth.screenName);
            XCTAssertNotNil(auth.accessToken);
            XCTAssertNotNil(auth.accessTokenSecret);
            XCTAssertNotNil([auth oauth1Token]);
            XCTAssertNil(auth.bearerAccessToken);
            XCTAssertNil([auth oauth2Token]);
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
        
        /* Validate authorized */
        
        expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Validate authorized %s", __func__]];
        [self requestForValidationWithAuth:auth completion:^(TWAPIRequestOperation * __nullable operation, id  __nullable responseObject, NSError * __nullable error) {
            XCTAssertNotNil(operation);
            XCTAssertNotNil(responseObject);
            XCTAssertNil(error, @"error = %@", error);
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }
}

- (void)testXAuth
{
    NSString *consumerKey = [Constants consumerKeyOfAllowedXAuth];
    NSString *consumerSecret = [Constants consumerSecretOfAllowedXAuth];
    if (!consumerKey || !consumerSecret) {
        NSLog(@"Could not run the %@.", NSStringFromSelector(_cmd));
        return;
    }
    
    TWAuth *auth = [TWAuth userAuthWithConsumerKey:consumerKey
                                    consumerSecret:consumerSecret
                                        screenName:[Constants screenName]
                                          password:[Constants password]];
    XCTAssertFalse([auth authorized]);
    XCTAssertNil([auth oauth1Token]);
    XCTAssertNil([auth oauth2Token]);
    
    /* Authorize */
    
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Authorize %s", __func__]];
    [auth authorizeWithCompletion:^(TWAuth * __nullable auth, NSError * __nullable error) {
        XCTAssertNotNil(auth);
        XCTAssertNil(error, @"error = %@", error);
        XCTAssertNotNil(auth.userID);
        XCTAssertNotNil(auth.screenName);
        XCTAssertNotNil(auth.accessToken);
        XCTAssertNotNil(auth.accessTokenSecret);
        XCTAssertNotNil([auth oauth1Token]);
        XCTAssertNil(auth.bearerAccessToken);
        XCTAssertNil([auth oauth2Token]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
    
    /* Validate Authorized */
    
    expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Validate authorized %s", __func__]];
    [self requestForValidationWithAuth:auth completion:^(TWAPIRequestOperation * __nullable operation, id  __nullable responseObject, NSError * __nullable error) {
        XCTAssertNotNil(operation);
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error, @"error = %@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark - App Auth
#if 0
- (void)testApplicationOnlyAuthentication
{
    NSString *consumerKey = [Constants consumerKey];
    NSString *consumerSecret = [Constants consumerSecret];
    
    TWAuth *auth = [TWAuth appAuthWithConsumerKey:consumerKey
                                   consumerSecret:consumerSecret];
    XCTAssertFalse([auth authorized]);
    XCTAssertNil([auth oauth1Token]);
    XCTAssertNil([auth oauth2Token]);
    
    /* Authorize */
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    [auth authorizeWithCompletion:^(TWAuth * __nullable auth, NSError * __nullable error) {
        XCTAssertNotNil(auth);
        XCTAssertNil(error, @"error = %@", error);
        XCTAssertNil(auth.userID);
        XCTAssertNil(auth.screenName);
        XCTAssertNil(auth.accessToken);
        XCTAssertNil(auth.accessTokenSecret);
        XCTAssertNil([auth oauth1Token]);
        XCTAssertNotNil([auth bearerAccessToken]);
        XCTAssertNotNil([auth oauth2Token]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
    
    /* Validate Authorized */
    
    expectation = [self expectationWithDescription:nil];
    [self requestForValidationWithAuth:auth completion:^(TWAPIRequestOperation * __nullable operation, id  __nullable responseObject, NSError * __nullable error) {
        XCTAssertNotNil(operation);
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error, @"error = %@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
    
    NSString *bearerAccessToken = auth.bearerAccessToken;
    XCTAssertNotNil(bearerAccessToken);
    NSLog(@"bearerAccessToken = %@", bearerAccessToken);
    
    /*---*/
    
    for (NSInteger i = 0; i < 2; i++) {
        TWAuth *auth;
        if (i) {
            auth = [TWAuth appAuthWithConsumerKey:consumerKey
                                   consumerSecret:consumerSecret
                                bearerAccessToken:bearerAccessToken];
            
        } else {
            auth = [TWAuth appAuthWithOAuth2Token:[[TWOAuth2Token alloc] initWithConsumerKey:consumerKey
                                                                              consumerSecret:consumerSecret
                                                                           bearerAccessToken:bearerAccessToken]];
        }
        XCTAssertTrue([auth authorized]);
        XCTAssertNil([auth oauth1Token]);
        XCTAssertNotNil([auth oauth2Token]);
        
        expectation = [self expectationWithDescription:nil];
        [self requestForValidationWithAuth:auth completion:^(TWAPIRequestOperation * __nullable operation, id  __nullable responseObject, NSError * __nullable error) {
            XCTAssertNotNil(operation);
            XCTAssertNotNil(responseObject);
            XCTAssertNil(error, @"error = %@", error);
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }
    
    /* Invalidate BearerAccessToken */
    
    expectation = [self expectationWithDescription:nil];
    [auth invalidateBearerAccessTokenWithCompletion:^(TWAuth * __nonnull auth, NSString * __nullable invalidateBearerAccessToken, NSError * __nullable error) {
        XCTAssertNotNil(auth);
        XCTAssertEqualObjects(bearerAccessToken, invalidateBearerAccessToken);
        XCTAssertNil(error, @"error = %@", error);
        
        XCTAssertNil(auth.bearerAccessToken);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}
#endif

#pragma mark - Parse

- (void)testParseOAuth1String
{
    NSString *oauthToken = @"OAUTH_TOKEN";
    NSString *oauthSecret = @"OAUTH_TOKEN_SECRET";
    NSString *userID = @"USERID";
    NSString *screenName = @"SCREEN_NAME";
    
    NSString *authStr = [NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@&user_id=%@&screen_name=%@", oauthToken, oauthSecret, userID, screenName];
    
    NSError *error = nil;
    TWOAuth1Token *token = [TWOAuth1Token tokenWithAmpersandSeparatedAuthenticationString:authStr
                                                                              consumerKey:@"consumerKey"
                                                                           consumerSecret:@"consumerSecret"
                                                                                    error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(token.accessToken, oauthToken);
    XCTAssertEqualObjects(token.accessTokenSecret, oauthSecret);
    XCTAssertEqualObjects(token.userID, userID);
    XCTAssertEqualObjects(token.screenName, screenName);
}

- (void)testParseRequestTokenString
{
    NSString *oauthToken = @"OAUTH_TOKEN";
    NSString *oauthVerifier = @"OAUTH_VERIFIER";
    
    NSString *tokenStr = [NSString stringWithFormat:@"oauth_token=%@&oauth_verifier=%@", oauthToken, oauthVerifier];
    
    NSError *error = nil;
    TWRequestToken *token = [TWRequestToken tokenWithAmpersandSeparatedRequestTokenString:tokenStr
                                                                                    error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(token.requestToken, oauthToken);
    XCTAssertEqualObjects(token.oauthVerifier, oauthVerifier);
}

- (TWAPIRequestOperation *)requestForValidationWithAuth:(TWAuth *)auth
                                             completion:(void(^)(TWAPIRequestOperation * __nullable operation, id __nullable responseObject, NSError * __nullable error))completion
{
    TWAPIRequestOperation *ope = [auth sendRequestWithHTTPMethod:kTWHTTPMethodGET
                                                   baseURLString:kTWBaseURLString_API_1_1
                                               relativeURLString:@"users/show.json"
                                                      parameters:@{@"user_id" : kTargetUserIDStr}
                                                     willRequest:nil
                                                  uploadProgress:nil
                                                downloadProgress:nil
                                                          stream:nil
                                                      completion:completion];
    XCTAssertNotNil(ope);
    return ope;
}

@end
