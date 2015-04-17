//
//  AuthViewController.m
//
//  Created by Yu Sugawara on 4/12/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "AuthViewController.h"
#import "Twitter.h"
#import "OAuth1WebViewController.h"
#import "Constants.h"
#import <RMUniversalAlert/RMUniversalAlert.h>

NS_ASSUME_NONNULL_BEGIN
@interface AuthViewController ()

@property (nonatomic) NSMutableSet *successes;
@property (nonatomic) NSMutableSet *failures;
@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation AuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.successes = [NSMutableSet set];
    self.failures = [NSMutableSet set];
    self.accountStore = [[ACAccountStore alloc] init];
}

- (NSString *)consumerKey
{
    return [Constants consumerKey];
}

- (NSString *)consumerSecret
{
    return [Constants consumerSecret];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OAuth1WebViewController *vc = segue.destinationViewController;
    if ([vc isKindOfClass:[OAuth1WebViewController class]]) {
        [vc configureWithConsumerKey:[self consumerKey]
                      consumerSecret:[self consumerSecret]
                          completion:^(TWAuth * __nullable auth, NSError * __nullable error) {
                              if (error) {
                                  NSLog(@"OAuth 1.0 in App UIWebView; error = %@", error);
                              } else {
                                  NSLog(@"Success OAuth 1.0 in App UIWebView; auth = %@", auth);
                                  NSAssert(auth.oauth1Token, nil);
                              }
                              [self updateCellWithError:error indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                          }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
    UIColor *color;
    if ([self.successes containsObject:indexPath]) {
        text = @"OK";
        color = [UIColor greenColor];
    } else if ([self.failures containsObject:indexPath]) {
        text = @"Error";
        color = [UIColor redColor];
    } else {
        text = @"-";
        color = [UIColor lightGrayColor];
    }
    cell.detailTextLabel.text = text;
    cell.detailTextLabel.textColor = color;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self startAuthWithIndexPath:indexPath completion:^(NSError * __nullable error) {
        [self updateCellWithError:error indexPath:indexPath];
    }];
}

#pragma mark -

- (void)startAuthWithIndexPath:(NSIndexPath *)indexPath completion:(void (^)(NSError * __nullable))completion
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    break;
                case 1:
                {
                    TWAuth *auth = [TWAuth userAuthWithConsumerKey:[self consumerKey]
                                                    consumerSecret:[self consumerSecret]
                                                     oauthCallback:@"yusuga-twitter://oauth"];
                    [auth authorizeWithCompletion:^(TWAuth * __nonnull auth, NSError * __nullable error) {
                        if (error) {
                            NSLog(@"OAuth 1.0 in Safari; error = %@", error);
                        } else {
                            NSLog(@"Success OAuth 1.0 in Safari; auth = %@", auth);
                            NSAssert(auth.oauth1Token, nil);
                        }
                        completion(error);
                    }];
                    break;
                }
                default:
                    abort();
            }
            break;
        case 1:
            [self startReverseAuthWithCompletion:completion];
            break;
        case 2:
        {
            TWAuth *auth = [TWAuth appAuthWithConsumerKey:[self consumerKey]
                                           consumerSecret:[self consumerSecret]];
            
            [auth authorizeWithCompletion:^(TWAuth * __nonnull auth, NSError * __nullable error) {
                if (error) {
                    NSLog(@"OAuth 2.0; error = %@", error);
                } else {
                    NSLog(@"Success OAuth 2.0; auth = %@", auth);
                    NSAssert(auth.oauth2Token, nil);
                }
                completion(error);
            }];
            break;
        }
        default:
            abort();
    }
}

- (void)updateCellWithError:(NSError *)error indexPath:(NSIndexPath *)indexPath
{
    if (error) {
        [self.failures addObject:indexPath];
        [self.successes removeObject:indexPath];
        [self.tableView reloadData];
    } else {
        [self.successes addObject:indexPath];
        [self.failures removeObject:indexPath];
        [self.tableView reloadData];
    }
    [self.tableView reloadData];
}

#pragma mark - AuthOS

- (void)startReverseAuthWithCompletion:(void (^)(NSError * __nullable))completion
{
    ACAccountType *type = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    __weak typeof(self) wself = self;
    [self.accountStore requestAccessToAccountsWithType:type
                                               options:nil
                                            completion:^(BOOL granted, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (!wself) return ;
             
             if (error) {
                 NSLog(@"error = %@", error);
             } else if (!granted) {
                 NSLog(@"granted == NO");
             } else {
                 NSArray *accounts = [wself.accountStore accountsWithAccountType:type];
                 
                 [RMUniversalAlert showActionSheetInViewController:wself
                                                         withTitle:nil
                                                           message:nil
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:^NSArray*
                  {
                      NSMutableArray *names = [NSMutableArray arrayWithCapacity:[accounts count]];
                      for (ACAccount *account in accounts) {
                          [names addObject:[NSString stringWithFormat:@"@%@", account.username]];
                      }
                      return [NSArray arrayWithArray:names];
                  }() popoverPresentationControllerBlock:^(RMPopoverPresentationController *popover) {
                      popover.sourceView = self.tableView;
                  } tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                      if (buttonIndex == alert.cancelButtonIndex) return ;
                      
                      ACAccount *account = accounts[buttonIndex - alert.firstOtherButtonIndex];
                      NSLog(@"Selected account, account.userID = %@", [account valueForKeyPath:@"properties.user_id"]);
                      
                      TWAuth *auth = [TWAuth userAuthWithAccount:account];
                      
                      [auth reverseAuthWithConsumerKey:[self consumerKey]
                                        consumerSecret:[self consumerSecret]
                                            completion:^(TWAuth * __nonnull auth, TWOAuth1Token * __nullable authToken, NSError * __nullable error)
                       {
                           if (error) {
                               NSLog(@"Revese Auth; error = %@", error);
                           } else {
                               NSLog(@"Success Reverse Auth; auth = %@", auth);
                           }
                           completion(error);
                       }];
                  }];
             }
         });
     }];
}


@end
NS_ASSUME_NONNULL_END