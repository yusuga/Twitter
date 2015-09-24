//
//  OAuth1WebViewController.m
//
//  Created by Yu Sugawara on 4/14/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "OAuth1WebViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OAuth1WebViewControllerCompletion)(TWAuth * __nullable auth, NSError * __nullable error);

@interface OAuth1WebViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) OAuth1WebViewControllerCompletion completion;

@end

@implementation OAuth1WebViewController

- (void)configureWithConsumerKey:(NSString *)consumerKey
                  consumerSecret:(NSString *)consumerSecret
                      completion:(void (^)(TWAuth * __nullable auth, NSError * __nullable error))completion
{
    self.consumerKey = consumerKey;
    self.consumerSecret = consumerSecret;
    self.completion = completion;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self displayOAuthWebView];
}

- (void)displayOAuthWebView
{
    TWAuth *auth = [TWAuth userAuthWithConsumerKey:self.consumerKey
                                    consumerSecret:self.consumerSecret
                                     oauthCallback:[self callbackURLString]
                    serviceProviderRequestHandler:^(NSURL * __nonnull url) {
                        self.title = url.absoluteString;
                        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
                    }];
    
    [auth authorizeWithCompletion:^(TWAuth * __nonnull auth, NSError * __nullable error) {
        [self popViewControllerWithAuth:auth error:error];
    }];
}

- (void)popViewControllerWithAuth:(TWAuth * __nullable)auth
                            error:(NSError * __nullable)error
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.completion(auth, error);
    }];
    [self.navigationController popViewControllerAnimated:YES];
    [CATransaction commit];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:[self callbackURLString]]) {
        [TWAuth postAuthorizeNotificationWithCallbackURL:request.URL];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    [self popViewControllerWithAuth:nil error:error];
}

#pragma mark - Utility

- (NSString*)callbackURLString
{
    return [[NSString stringWithFormat:@"%@://success", NSStringFromClass([self class])] lowercaseString];
}

@end
NS_ASSUME_NONNULL_END