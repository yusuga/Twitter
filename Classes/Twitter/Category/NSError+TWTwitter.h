//
//  NSError+TWTwitter.h
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@import Accounts;
@class TWRateLimit;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TWAPIErrorDomain;
extern NSString * const TWOperationErrorDomain;
extern NSString * const TWAccountErrorDomain;

extern NSString * const TWErrorErrors;
extern NSString * const TWErrorIsCancelledKey;
extern NSString * const TWErrorUnderlyingStringKey;
extern NSString * const TWErrorInvalidAuthorizationString;
extern NSString * const TWErrorRateLimit;

/**
 *  https://dev.twitter.com/overview/api/response-codes
 */
typedef NS_ENUM(NSInteger, TWAPIErrorCode) {
    TWAPIErrorCodeUnknown = 0,
    TWAPIErrorCodeMultipleErrors = 1,
    
    /**
     *  No user matches for specified terms.
     *  
     *  # ex
     *  - users/lookup
     */
    TWAPIErrorCodeNoUserMatchesForSpecifiedTerms = 17,
    
    /**
     *  Your call could not be completed as dialed.
     *
     *  ex:
     *  - Invalid consumerKey, consumerSecret or access token secret.
     */
    TWAPIErrorCodeCouldNotAuthenticate = 32,
    
    /**
     *  Corresponds with an HTTP 404 - the specified resource was not found.
     */
    TWAPIErrorCodePageNotExist = 34,
    
    /**
     *  Media parameter is missing.
     */
    TWAPIErrorCodeMediaParameterIsMissing = 38,
    
    /**
     *  Attachment_url parameter is invalid.
     *
     *  Old specifications: Media parameter is invalid.
     */
    TWAPIErrorCodeAttachmentURLParameterIsInvalid = 44,
    
    /**
     *  User not found.
     */
    TWAPIErrorCodeUserNotFound = 50,
    
    /**
     *  Not authorized to use this endpoint.
     */
    TWAPIErrorCodeNotAuthorizedForEndpoint = 37,
    
    /**
     *  User has been suspended.
     */
    TWAPIErrorCodeUserHasBeenSuspended = 63,
    
    /**
     *  Corresponds with an HTTP 403 — the access token being used belongs to a suspended user and they can't complete the action you're trying to take
     */
    TWAPIErrorCodeAccountSuspended = 64,
    
    /**
     *  Corresponds to a HTTP request to a retired v1-era URL.
     */
    TWAPIErrorCodeAPIVersionRetired = 68,
    
    /**
     *  Bad HTTPMethod
     */
    TWAPIErrorCodeThisMethodRequiresAGETOrHEAD = 86,
    
    /**
     *  The request limit for this resource has been reached for the current rate limit window.
     */
    TWAPIErrorCodeRateLimitExceeded = 88,
    
    /**
     *  The access token used in the request is incorrect or has expired. Used in API v1.1.
     *  https://dev.twitter.com/oauth/application-only
     *
     *  ex:
     *  - Invalid access token.
     */
    TWAPIErrorCodeInvalidOrExpiredToken = 89,
    
    /**
     *  Only SSL connections are allowed in the API, you should update your request to a secure connection. See [how to connect using SSL](https://dev.twitter.com/docs/security/using-ssl).
     */
    TWAPIErrorCodeSSLInvalid = 92,
    
    /**
     *  ( https://dev.twitter.com/oauth/overview/application-permission-model )
     */
    
    TWAPIErrorCodeApplicationIsNotAllowedToAccessOrDeleteYourDirectMessages = 93,
    
    /**
     *  Invalid requests to obtain or revoke bearer tokens
     *  Attempts to:
     *  - Obtain a bearer token with an invalid request (for example, leaving out grant_type=client_credentials).
     *  - Obtain or revoke a bearer token with incorrect or expired app credentials.
     *  - Invalidate an incorrect or revoked bearer token.
     *  - Obtain a bearer token too frequently in a short period of time.
     *  https://dev.twitter.com/oauth/application-only
     */
    TWAPIErrorCodeUnableToVerifyYourCredentials = 99,
    
    /**
     *  Corresponds with an HTTP 503 - Twitter is temporarily over capacity.
     */
    TWAPIErrorCodeOverCapacity = 130,
    
    /**
     *  Corresponds with an HTTP 500 - An unknown internal error occurred.
     */
    TWAPIErrorCodeInternalError = 131,
    
    /**
     *  Corresponds with a HTTP 401 - it means that your oauth_timestamp is either ahead or behind our acceptable range.
     */
    TWAPIErrorCodeCouldNotAuthenticateTimestampOutOfRange = 135,
    
    /**
     *  You have already favorited this status.
     */
    TWAPIErrorCodeAlreadyFavorited = 139,
    
    /**
     *  No status found with that ID.
     */
    TWAPIErrorCodeNoStatusFoundWithThatID = 144,
    
    /**
     *  Corresponds with HTTP 403 — returned when a user cannot follow another user due to some kind of limit.
     */
    TWAPIErrorCodeCannotFollowOverLimit = 161,
    
    /**
     *  Missing required parameter
     *
     *  ex:
     *  - Missing required parameter: status.
     */
    TWAPIErrorCodeMissingRequiredParameter = 170,
    
    /**
     *  Corresponds with HTTP 403 — returned when a Tweet cannot be viewed by the authenticating user, usually due to the Tweet's author having protected their Tweets.
     */
    TWAPIErrorCodeNotAuthorizedToSeeStatus = 179,
    
    /**
     *  Corresponds with HTTP 403 — returned when a Tweet cannot be posted due to the user having no allowance remaining to post. Despite the text in the error message indicating that this error is only returned when a daily limit is reached, this error will be returned whenever a posting limitation has been reached. Posting allowances have roaming windows of time of unspecified duration.
     */
    TWAPIErrorCodeOverDailyStatusUpdateLimit = 185,
    
    /**
     *  The status text has been Tweeted already by the authenticated account.
     */
    TWAPIErrorCodeStatusIsDuplicate = 187,
    
    /**
     *  Typically sent with 1.1 responses with HTTP code 400. The method requires authentication but it was not presented or was wholly invalid.
     *
     *  ex:
     *  - Authorization is missing in the HTTP header field.
     */
    TWAPIErrorCodeBadAuthenticationData = 215,
    
    /**
     *  Bearer token used on endpoint which doesn’t support application-only auth.
     *  https://dev.twitter.com/oauth/application-only
     */
    TWAPIErrorCodeAppAuthDoesNotSupportedThisEndpoint = 220,
    
    /**
     *  We constantly monitor and adjust our filters to block spam and malicious activity on the Twitter platform. These systems are tuned in real-time. If you get this response our systems have flagged the Tweet or DM as possibly fitting this profile. If you feel that the Tweet or DM you attempted to create was flagged in error, please report the details around that to us by filing a ticket at https://support.twitter.com/forms/platform
     */
    TWAPIErrorCodeRequestIsAutomated = 226,
    
    /**
     *  Returned as a challenge in xAuth when the user has login verification enabled on their account and needs to be directed to twitter.com to [generate a temporary password]( https://twitter.com/settings/applications ).
     */
    TWAPIErrorCodeUserMustVerifyLogin = 231,
    
    /**
     *  Corresponds to a HTTP request to a retired URL.
     */
    TWAPIErrorCodeEndpointRetired = 251,
    
    /**
     *  Corresponds with HTTP 403 — returned when the application is restricted from POST, PUT, or DELETE actions. See [How to appeal application suspension and other disciplinary actions]( https://support.twitter.com/articles/72585 ).
     */
    TWAPIErrorCodeApplicationCannotPerformWriteAction = 261,
    
    /**
     *  Corresponds with HTTP 403. The authenticated user account cannot mute itself.
     */
    TWAPIErrorCodeCannotMuteSelf = 271,
    
    /**
     *  Corresponds with HTTP 403. The authenticated user account is not muting the account a call is attempting to unmute.
     */
    TWAPIErrorCodeCannotMuteSpecifiedUser = 272,
    
    /**
     *  The validation of media ids failed.
     *
     *  ex:
     *  - Request containing an invalid MediaID.
     *  - MediaIDs exceeds four.
     */
    TWAPIErrorCodeValidationOfMediaIDsFailed = 324,
    
    /**
     *  You have already retweeted this tweet.
     */
    TWAPIErrorCodeAlreadyRetweeted = 327,
    
    /**
     *  Error processing your OAuth request: invalid signature or token
     */
    TWAPIErrorCodeErrorProcessingYourOAuthRequestInvalidSignatureOrToken = 350,
    
    /**
     *  Corresponds with HTTP 403. A reply can only be sent with reference to an existing public Tweet.
     */
    TWAPIErrorCodeErrorYouAttemptedToReplyToTweetThatIsDeletedOrNotVisibleToYou = 385,
    
    /**
     *  Corresponds with HTTP 403. A Tweet is limited to a single attachment resource (media, Quote Tweet, etc.)
     */
    TWAPIErrorCodeErrorTweetExceedsTheNumberOfAllowedAttachmentTypes = 386,
    
    /**
     *  HTTP Status Code
     *  Returned in API v1.1 when a request cannot be served due to the application's rate limit having been exhausted for the resource. See [Rate Limiting in API v1.1]( https://dev.twitter.com/docs/rate-limiting/1.1 ).
     */
    TWAPIErrorCodeTooManyRequests = 429,
    
    
    ///-------------------------------
    /// Undefined Error in the Twitter
    ///-------------------------------
    
    /**
     *  Access to protected user.
     *
     *  HTTP Status: 401
     *  Respons JSON
     *  {
     *      error: "Not authorized.",
     *      request: "/1.1/statuses/user_timeline.json"
     *  }
     */
    TWAPIErrorCodeAccessToProtectedUser = 1001,
    
    /**
     *  Streaming is disconnected.
     */
    TWAPIErrorCodeStreamingIsDisconnected = 1101,
    
    /**
     *  Authentication error.
     *
     *  - /oauth/access_token
     */
    TWAPIErrorCodeAuthenticationInvalidUserNameOrPassword = 1002,
};

typedef NS_ENUM(NSInteger, TWOperationErrorCode) {
    TWOperationErrorCodeBadArgument,
    TWOperationErrorCodeParseFailed,
    TWOperationErrorCodeUnsupportedAuthentication,
    TWOperationErrorCodeUnexpectedBranch,
};

typedef NS_ENUM(NSInteger, TWAccountErrorCode) {
    TWAccountErrorCodePrivacyAccess,
};

@interface NSError (TWTwitter)

#pragma mark - API

+ (NSError * __nullable)tw_localizedAPIErrorWithHTTPOperation:(AFHTTPRequestOperation *)operation
                                              underlyingError:(NSError *)underlyingError
                                                   screenName:(NSString * __nullable)screenName;
+ (NSError * __nullable)tw_errorFromErrors:(NSArray *)errors;

+ (NSError *)tw_streamingIsDisconnectedError;

- (BOOL)tw_isEqualToTwitterAPIErrorCode:(TWAPIErrorCode)code;

- (NSURL * __nullable)tw_failingURL;
- (NSHTTPURLResponse * __nullable)tw_failingURLResponse;
- (NSError * __nullable)tw_underlyingError;
- (NSInteger)tw_HTTPStatusCode;
- (BOOL)tw_isCancelled;
- (NSString * __nullable)tw_invalidAuthorizationString;
- (TWRateLimit * __nullable)tw_rateLimit;

#pragma mark - Operation

+ (NSError *)tw_badArgumentErrorWithFailureReason:(NSString *)failureReason;

+ (NSError *)tw_parseFailedErrorWithUnderlyingString:(NSString *)underlyingString;
- (NSString *)tw_underlyingString;

+ (NSError *)tw_unsupportedAuthenticationErrorWithDescription:(NSString *)description
                                                failureReason:(NSString * __nullable)failureReason;
+ (NSError *)tw_unexpectedBranchErrorWithDescription:(NSString *)description;

#pragma mark - Account

+ (NSError *)tw_twitterPrivacyAccessError;
+ (NSError *)tw_accountAuthenticationFailed;

#pragma mark - Code

+ (NSArray<NSNumber *> *)tw_authenticationFailedErrorCodes;

@end

@interface TWRateLimit : NSObject

+ (TWRateLimit * __nullable)rateLimitWithResponse:(NSHTTPURLResponse *)response;

@property (nonatomic) NSDate *resetDate;
- (NSTimeInterval)remainingTime;
- (NSString *)localizedTimeString;      // e.g. 10m5s, 10分5秒

@end

NS_ASSUME_NONNULL_END
