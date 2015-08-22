//
//  NSError+TWTwitter.m
//
//  Created by Yu Sugawara on 4/11/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "NSError+TWTwitter.h"
#import "TWLocalization.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const TWAPIErrorDomain = @"TWAPIErrorDomain";
NSString * const TWOperationErrorDomain = @"TWOperationErrorDomain";
NSString * const TWAccountErrorDomain = @"TWAccountErrorDomain";

NSString * const TWErrorErrors = @"errors";
NSString * const TWErrorIsCancelledKey = @"TWErrorIsCancelledKey";
NSString * const TWErrorUnderlyingStringKey = @"TWErrorUnderlyingStringKey";
NSString * const TWErrorInvalidAuthorizationString = @"TWErrorInvalidAuthorizationString";
NSString * const TWErrorRateLimit = @"TWErrorRateLimit";

@implementation NSError (TWTwitter)

#pragma mark - API

+ (NSError * __nullable)tw_localizedAPIErrorWithHTTPOperation:(AFHTTPRequestOperation *)operation
                                              underlyingError:(NSError *)underlyingError
                                                   screenName:(NSString * __nullable)screenName
{
    if ((!operation || !operation.request)) return nil;
    
    if ([operation.request.URL.path isEqualToString:@"/oauth/access_token"]) {
        if (!operation.responseObject && operation.response.statusCode == 401 && !underlyingError && operation.responseString) {
            return [self tw_apiErrorWithCode:TWAPIErrorCodeAuthenticationInvalidUserNameOrPassword
                                 description:operation.responseString
                               failureReason:nil
                           appendingUserInfo:nil];
        }
    }
    
    if (!underlyingError) return nil;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:underlyingError.userInfo];
    info[NSUnderlyingErrorKey] = underlyingError;
    info[NSURLErrorFailingURLErrorKey] = ^NSURL *{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSURL *url = underlyingError.userInfo[NSErrorFailingURLStringKey];
#pragma clang diagnostic pop
        if (url) return url;
        url = underlyingError.userInfo[NSURLErrorFailingURLErrorKey];
        if (url) return url;
        return operation.response.URL ?: operation.request.URL;
    }();
    info[TWErrorIsCancelledKey] = @(operation.isCancelled);
    
    NSDictionary *json = operation.responseObject;
    if([json isKindOfClass:[NSDictionary class]]) {
        NSArray *errors = json[@"errors"];
        if ([errors isKindOfClass:[NSArray class]] && [errors count]) {
            /**
             *  {"errors":[{"message":"Sorry, that page does not exist","code":34}]}
             */
            NSDictionary *errorDict = [errors lastObject];
            if([errorDict isKindOfClass:[NSDictionary class]]) {
                NSError *error = [self tw_localizedAPIErrorWithOperation:operation
                                                         errorDictionary:errorDict
                                                              screenName:screenName
                                                       appendingUserInfo:[NSDictionary dictionaryWithDictionary:info]];
                if (error) return error;
            }
        } else if (json[@"error"]) {
            NSLog(@"%s, Note error(json[@\"error\"]),  underlyingError = %@, operation.responseObject = %@, operation.responseString = %@;", __func__, underlyingError, operation.responseObject, operation.responseString);
            NSString *error = json[@"error"];
            if (![error isKindOfClass:[NSString class]]) return underlyingError;
            
            NSError *originalError = [self tw_protectedUserTimeLineErrorWithHTTPOperation:operation];
            if (originalError) return originalError;
            
            return [self tw_apiErrorWithCode:TWAPIErrorCodeUnknown
                                 description:error
                               failureReason:nil
                           appendingUserInfo:[NSDictionary dictionaryWithDictionary:info]];
        } else if ([errors isKindOfClass:[NSString class]]) {
            NSLog(@"%s, Note error(errors == [NSString class]),  underlyingError = %@, operation.responseObject = %@, operation.responseString = %@;", __func__,  underlyingError, operation.responseObject, operation.responseString);
            return [self tw_apiErrorWithCode:TWAPIErrorCodeUnknown
                                 description:(NSString *)errors
                               failureReason:nil
                           appendingUserInfo:[NSDictionary dictionaryWithDictionary:info]];
        }
    }
    
    if (![underlyingError.domain isEqualToString:NSURLErrorDomain]) {
        NSLog(@"%s, Unknown error,  underlyingError = %@, operation.responseObject = %@, operation.responseString = %@;", __func__, underlyingError, operation.responseObject, operation.responseString);
    }
    
    if (underlyingError.localizedDescription) info[NSLocalizedDescriptionKey] = underlyingError.localizedDescription;
    if (underlyingError.localizedRecoverySuggestion) info[NSLocalizedRecoverySuggestionErrorKey] = underlyingError.localizedRecoverySuggestion;
    if (underlyingError.localizedRecoveryOptions) info[NSLocalizedRecoveryOptionsErrorKey] = underlyingError.localizedRecoveryOptions;
    if (underlyingError.localizedFailureReason) info[NSLocalizedFailureReasonErrorKey] =underlyingError.localizedFailureReason;
    if (underlyingError.recoveryAttempter) info[NSRecoveryAttempterErrorKey] =underlyingError.recoveryAttempter;
    if (underlyingError.helpAnchor) info[NSHelpAnchorErrorKey] =underlyingError.helpAnchor;
    
    return [NSError errorWithDomain:underlyingError.domain
                               code:underlyingError.code
                           userInfo:[NSDictionary dictionaryWithDictionary:info]];
}

+ (NSError * __nullable)tw_errorFromErrors:(NSArray * __nonnull)errors
{
    if (![errors count]) return nil;
    if ([errors count] == 1) return [errors firstObject];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[TWErrorErrors] = errors;
    
    info[NSLocalizedDescriptionKey] = TWLocalizedString(@"Multiple Errors");
    
    NSString *failureReason = ^NSString *{
        NSMutableString *failureReason = [NSMutableString string];
        for (NSError *error in errors) {
            NSMutableString *str = [NSMutableString string];
            if (error.localizedDescription) {
                [str appendString:error.localizedDescription];
            }
            if (error.localizedFailureReason) {
                [str appendFormat:@"(%@)", error.localizedFailureReason];
            }
            if (str.length) {
                if (failureReason.length) {
                    [failureReason appendString:@"\n"];
                }
                [failureReason appendString:str];
            }
        }
        return failureReason.length ? [NSString stringWithString:failureReason] : nil;
    }();
    if (failureReason) {
        info[NSLocalizedFailureReasonErrorKey] = failureReason;
    }
    
    return [NSError errorWithDomain:TWAPIErrorDomain
                               code:TWAPIErrorCodeMultipleErrors
                           userInfo:[NSDictionary dictionaryWithDictionary:info]];
}

- (BOOL)tw_isEqualToTwitterAPIErrorCode:(TWAPIErrorCode)code
{
    return [self.domain isEqualToString:TWAPIErrorDomain] && self.code == code;
}

- (NSURL * __nullable)tw_failingURL
{
    NSURL *url = self.userInfo[NSURLErrorFailingURLErrorKey];
    NSParameterAssert(!url || [url isKindOfClass:[NSURL class]]);
    return [url isKindOfClass:[NSURL class]] ? url : nil;
}

- (NSHTTPURLResponse * __nullable)tw_failingURLResponse
{
    NSHTTPURLResponse *response = self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    NSParameterAssert(!response || [response isKindOfClass:[NSHTTPURLResponse class]]);
    return [response isKindOfClass:[NSHTTPURLResponse class]] ? response : nil;
}

- (NSError * __nullable)tw_underlyingError
{
    NSError *error = self.userInfo[NSUnderlyingErrorKey];
    NSParameterAssert(!error || [error isKindOfClass:[NSError class]]);
    return [error isKindOfClass:[NSError class]] ? error : nil;
}

- (NSInteger)tw_HTTPStatusCode
{
    NSInteger code = [self tw_failingURLResponse].statusCode;
    if (code == 0 && [[self tw_underlyingError].domain isEqualToString:NSURLErrorDomain]) {
        code = [self tw_underlyingError].code;
    }
    return code;
}

- (BOOL)tw_isCancelled
{
    NSNumber *num = self.userInfo[TWErrorIsCancelledKey];
    NSParameterAssert(!num || [num isKindOfClass:[NSNumber class]]);
    return [num isKindOfClass:[NSNumber class]] ? num.boolValue : NO;
}

- (NSString * __nullable)tw_invalidAuthorizationString
{
    NSString *str = self.userInfo[TWErrorInvalidAuthorizationString];
    NSParameterAssert(!str || [str isKindOfClass:[NSString class]]);
    return [str isKindOfClass:[NSString class]] ? str : nil;
}

- (TWRateLimit * __nullable)tw_rateLimit
{
    TWRateLimit *rateLimit = self.userInfo[TWErrorRateLimit];
    NSParameterAssert(!rateLimit || [rateLimit isKindOfClass:[TWRateLimit class]]);
    return [rateLimit isKindOfClass:[TWRateLimit class]] ? rateLimit : nil;
}

#pragma mark - Operation

+ (NSError *)tw_badArgumentErrorWithFailureReason:(NSString * __nonnull)failureReason
{
    return [self tw_operationErrorWithCode:TWOperationErrorCodeBadArgument
                               description:@"Bad argument"
                             failureReason:failureReason
                         appendingUserInfo:nil];;
}

+ (NSError *)tw_parseFailedErrorWithUnderlyingString:(NSString * __nonnull)underlyingString
{
    return [self tw_operationErrorWithCode:TWOperationErrorCodeParseFailed
                               description:@"Parse failed"
                             failureReason:nil
                         appendingUserInfo:underlyingString ? @{TWErrorUnderlyingStringKey : underlyingString} : nil];
}

- (NSString *)tw_underlyingString
{
    return self.userInfo[TWErrorUnderlyingStringKey];
}

+ (NSError *)tw_unsupportedAuthenticationErrorWithDescription:(NSString * __nonnull)description
                                                failureReason:(NSString * __nullable)failureReason
{
    return [self tw_operationErrorWithCode:TWOperationErrorCodeUnsupportedAuthentication
                               description:description
                             failureReason:failureReason
                         appendingUserInfo:nil];
}

+ (NSError *)tw_unexpectedBranchErrorWithDescription:(NSString *)description
{
    return [self tw_operationErrorWithCode:TWOperationErrorCodeUnexpectedBranch
                               description:description
                             failureReason:nil
                         appendingUserInfo:nil];
}

#pragma mark - Account

+ (NSError *)tw_twitterPrivacyAccessError
{
    // TODO: There is error code into ACErrorCode?
    return [self tw_accountErrorWithCode:TWAccountErrorCodePrivacyAccess
                             description:@"Privacy access is denied"
                           failureReason:nil];
}

+ (NSError *)tw_accountAuthenticationFailed
{
    return [NSError errorWithDomain:ACErrorDomain
                               code:ACErrorAccountAuthenticationFailed
                           userInfo:@{NSLocalizedDescriptionKey : @"ACErrorAccountAuthentication failed"}];
    
}

#pragma mark - Private

+ (NSError *)tw_apiErrorWithCode:(TWAPIErrorCode)code
                     description:(NSString *)description
                   failureReason:(NSString * __nullable)failureReason
               appendingUserInfo:(NSDictionary * __nullable)appendingUserInfo
{
    return [self tw_errorWithDomain:TWAPIErrorDomain
                               code:code
                        description:description
                      failureReason:failureReason
                  appendingUserInfo:appendingUserInfo];
}

+ (NSError *)tw_operationErrorWithCode:(TWOperationErrorCode)code
                           description:(NSString *)description
                         failureReason:(NSString * __nullable)failureReason
                     appendingUserInfo:(NSDictionary * __nullable)appendingUserInfo
{
    return [self tw_errorWithDomain:TWOperationErrorDomain
                               code:code
                        description:description
                      failureReason:failureReason
                  appendingUserInfo:appendingUserInfo];
}

+ (NSError *)tw_accountErrorWithCode:(TWAccountErrorCode)code
                         description:(NSString *)description
                       failureReason:(NSString * __nullable)failureReason
{
    return [self tw_errorWithDomain:TWAccountErrorDomain
                               code:code
                        description:description
                      failureReason:failureReason];
}

#pragma mark -

+ (NSError*)tw_errorWithDomain:(NSString *)domain
                          code:(NSInteger)code
                   description:(NSString *)description
                 failureReason:(NSString * __nullable)failureReason
{
    return [self tw_errorWithDomain:domain
                               code:code
                        description:description
                      failureReason:failureReason
                  appendingUserInfo:nil];
}

+ (NSError*)tw_errorWithDomain:(NSString *)domain
                          code:(NSInteger)code
                   description:(NSString *)description
                 failureReason:(NSString * __nullable)failureReason
             appendingUserInfo:(NSDictionary * __nullable)appendingUserInfo
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:appendingUserInfo];
    if (description) {
        userInfo[NSLocalizedDescriptionKey] = description;
    }
    if (failureReason) {
        userInfo[NSLocalizedFailureReasonErrorKey] = failureReason;
    }
    
    return [NSError errorWithDomain:domain
                               code:code
                           userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

#pragma mark - Utility

+ (NSError * __nullable)tw_localizedAPIErrorWithOperation:(AFHTTPRequestOperation *)operation
                                          errorDictionary:(NSDictionary *)errorDectionary
                                               screenName:(NSString *)screenName
                                        appendingUserInfo:(NSDictionary *)appendingUserInfo
{
    /**
     *  {"message":"Sorry, that page does not exist","code":34}
     */
    NSString *message = errorDectionary[@"message"];
    NSInteger code = [errorDectionary[@"code"] integerValue];
    if (!message || !code) return nil;
    
    NSHTTPURLResponse *response = operation.response;
    
    NSString *desc = message;
    NSString *failureReason, *recoverySuggestion;
    NSMutableDictionary *userInfo = appendingUserInfo ? appendingUserInfo.mutableCopy : [NSMutableDictionary dictionary];
    
    // TODO: Localize
    
    switch (code) {
        case TWAPIErrorCodeCouldNotAuthenticate: // 32
        case TWAPIErrorCodeInvalidOrExpiredToken: // 89
        case TWAPIErrorCodeBadAuthenticationData: // 215
        {
            if (screenName) {
                desc = [NSString stringWithFormat:TWLocalizedString(@"Authentication failed format with screenName"), screenName];
            } else {
                desc = TWLocalizedString(@"Authentication failed");
            }
            
            userInfo[TWErrorInvalidAuthorizationString] = operation.request.allHTTPHeaderFields[@"Authorization"] ?: @"";
            break;
        }
        case TWAPIErrorCodePageNotExist: // 34
            break;
        case TWAPIErrorCodeNotAuthorizedForEndpoint: // 37
            break;
        case TWAPIErrorCodeUserNotFound: // 50
            desc = TWLocalizedString(message);
            break;
        case TWAPIErrorCodeAccountSuspended: // 64
            break;
        case TWAPIErrorCodeAPIVersionRetired: // 68
            break;
        case TWAPIErrorCodeThisMethodRequiresAGETOrHEAD: // 86
            break;
        case TWAPIErrorCodeTooManyRequests: // 429 (HTTP Status Code)
        case TWAPIErrorCodeRateLimitExceeded: // 88
        {
            TWRateLimit *rateLimit = [TWRateLimit rateLimitWithResponse:response];
            NSParameterAssert(rateLimit);
            if (!rateLimit) break;
            
            userInfo[TWErrorRateLimit] = rateLimit;
            NSString *timeStr = [rateLimit localizedTimeString];
            
            if (screenName) {
                desc = [NSString stringWithFormat:TWLocalizedString(@"Error 88 format with screenName"), screenName, timeStr];
            } else {
                desc = [NSString stringWithFormat:TWLocalizedString(@"Error 88 format"), timeStr];
            }
            break;
        }
        case TWAPIErrorCodeSSLInvalid: // 92
            break;
        case TWAPIErrorCodeUnableToVerifyYourCredentials: // 99
            break;
        case TWAPIErrorCodeOverCapacity: // 130
            break;
        case TWAPIErrorCodeInternalError: // 131
            break;
        case TWAPIErrorCodeCouldNotAuthenticateTimestampOutOfRange: // 135
            break;
        case TWAPIErrorCodeAlreadyFavorited: // 139
            break;
        case TWAPIErrorCodeNoStatusFoundWithThatID: // 144
            break;
        case TWAPIErrorCodeCannotFollowOverLimit: // 161
            break;
        case TWAPIErrorCodeNotAuthorizedToSeeStatus: // 179
            break;
        case TWAPIErrorCodeOverDailyStatusUpdateLimit: // 185
            break;
        case TWAPIErrorCodeStatusIsDuplicate: // 187
            break;
        case TWAPIErrorCodeAppAuthDoesNotSupportedThisEndpoint: // 220
            failureReason = @"AppAuth(Application-only authentication) does not support this endpoint.";
            break;
        case TWAPIErrorCodeRequestIsAutomated: // 226
            break;
        case TWAPIErrorCodeUserMustVerifyLogin: // 231
            break;
        case TWAPIErrorCodeEndpointRetired: // 251
            break;
        case TWAPIErrorCodeApplicationCannotPerformWriteAction: // 261
            break;
        case TWAPIErrorCodeCannotMuteSelf: // 271
            break;
        case TWAPIErrorCodeCannotMuteSpecifiedUser: // 272
            break;
        case TWAPIErrorCodeAlreadyRetweeted: // 327
            break;
        default:
            NSLog(@"%s Unknown Twitter Error {\n\tTwitter error code = %zd\n\toperation = %@;\n\tresponseString = %@;\n}", __func__, code, operation, operation.responseString);
            break;
    }
    
    if (recoverySuggestion) {
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion;
    }
    
    return [self tw_apiErrorWithCode:code
                         description:desc
                       failureReason:failureReason
                   appendingUserInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

+ (NSError *)tw_protectedUserTimeLineErrorWithHTTPOperation:(AFHTTPRequestOperation *)operation
{
    /**
     *  HTTP Status: 401
     *  Respons JSON
     *  {
     *      error: "Not authorized.",
     *      request: "/1.1/statuses/user_timeline.json"
     *  }
     */
    if (operation.response.statusCode != 401) return nil;
    
    NSDictionary *responseObject = operation.responseObject;
    if (![responseObject isKindOfClass:[NSDictionary class]]) return nil;
    
    NSString *error = responseObject[@"error"];
    NSString *request = responseObject[@"request"];
    
    BOOL (^containsProtectedUserRequest)(NSString *request) = ^BOOL(NSString *request) {
        NSArray *endPoints = @[@"/1.1/statuses/user_timeline.json",
                               @"/1.1/friends/list.json",
                               @"/1.1/followers/list.json"];
        
        for (NSString *endPoint in endPoints) {
            if ([request isEqualToString:endPoint]) {
                return YES;
            }
        }
        return NO;
    };
    
    if ([error isEqualToString:@"Not authorized."] &&
        containsProtectedUserRequest(request))
    {
        return [self tw_apiErrorWithCode:TWAPIErrorCodeAccessToProtectedUser
                             description:TWLocalizedString(@"Error 1001")
                           failureReason:nil
                       appendingUserInfo:nil];
    }
    return nil;
}

@end

@implementation TWRateLimit

+ (TWRateLimit * __nullable)rateLimitWithResponse:(NSHTTPURLResponse *)response
{
    NSNumber *unixNum = response.allHeaderFields[@"x-rate-limit-reset"];
    if (unixNum == nil) return nil;
    
    return [[self alloc] initWithResetDate:[NSDate dateWithTimeIntervalSince1970:[unixNum doubleValue]]];
}

- (instancetype)initWithResetDate:(NSDate *)resetDate
{
    if (self = [super init]) {
        self.resetDate = resetDate;
    }
    return self;
}

- (NSTimeInterval)remainingTime
{
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0.];
    NSTimeInterval time = [self.resetDate timeIntervalSinceDate:currentDate];
    return time < 0. ? 0. : time;
}

- (NSString *)localizedTimeString
{
    return TWLocalizedTimeString([self remainingTime]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, resetDate = %@, remainingTime = %f, localizedTimeString = %@;", [super description], self.resetDate, [self remainingTime], [self localizedTimeString]];
}

@end
NS_ASSUME_NONNULL_END
