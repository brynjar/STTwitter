//
//  MGTwitterEngine+TH.m
//  TwitHunter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import "STTwitterOAuthOSX.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "STTwitterAccountSelector.h"

@implementation STTwitterOAuthOSX

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    [self requestAccessWithCompletionBlock:^(ACAccount *twitterAccount) {
        successBlock(twitterAccount.username);
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (NSString *)username {
    if(_selectedAccount)
        return _selectedAccount.username;
    else {//TODO: what the hell??
        [self requestAccessWithCompletionBlock:nil errorBlock:nil];
        return _selectedAccount.username;
    }
}

- (void)requestAccessWithCompletionBlock:(void(^)(ACAccount *twitterAccount))completionBlock errorBlock:(void(^)(NSError *))errorBlock {
    [STTwitterAccountSelector getCurrentAccount:^(ACAccount *account) {
        completionBlock(account);
    } cancelled:^(NSError *error){
        NSError *e = error;
        if(e == nil) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Cannot access iOS Twitter account." };
            e = [NSError errorWithDomain:@"STTwitterOAuthOSX" code:0 userInfo:userInfo];
        }
        errorBlock(e);
    }];
}

- (void)fetchAPIResource:(NSString *)resource httpMethod:(int)httpMethod parameters:(NSDictionary *)params completionBlock:(STTE_completionBlock_t)completionBlock errorBlock:(STTE_errorBlock_t)errorBlock {

    NSData *mediaData = [params valueForKey:@"media[]"];
    
    NSMutableDictionary *paramsWithoutMedia = [params mutableCopy];
    [paramsWithoutMedia removeObjectForKey:@"media[]"];
    
    [self requestAccessWithCompletionBlock:^(ACAccount *twitterAccount) {
        NSString *urlString = [@"https://api.twitter.com/1.1/" stringByAppendingString:resource];
        NSURL *url = [NSURL URLWithString:urlString];
        //SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:httpMethod URL:url parameters:paramsWithoutMedia];
        TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:paramsWithoutMedia requestMethod:httpMethod];
        request.account = twitterAccount;
        
        if(mediaData) {
            //[request addMultipartData:mediaData withName:@"media[]" type:@"application/octet-stream" filename:@"media.jpg"];
            [request addMultiPartData:mediaData withName:@"media[]" type:@"application/octet-stream"];
        }
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if(responseData == nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(nil);
                }];
                return;
            }
            
            NSError *jsonError = nil;
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if(json == nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonError);
                }];
                return;
            }
            
            /**/
            
            if([json isKindOfClass:[NSArray class]] == NO && [json valueForKey:@"error"]) {
                
                NSString *message = [json valueForKey:@"error"];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
                NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonErrorFromResponse);
                }];
                
                return;
            }
            
            /**/
            
            id jsonErrors = [json valueForKey:@"errors"];
            
            if(jsonErrors != nil && [jsonErrors isKindOfClass:[NSArray class]] == NO) {
                if(jsonErrors == nil) jsonErrors = @"";
                jsonErrors = [NSArray arrayWithObject:@{@"message":jsonErrors, @"code" : @(0)}];
            }
            
            if([jsonErrors count] > 0 && [[jsonErrors lastObject] isEqual:[NSNull null]] == NO) {
                
                NSDictionary *jsonErrorDictionary = [jsonErrors lastObject];
                NSString *message = jsonErrorDictionary[@"message"];
                NSInteger code = [jsonErrorDictionary[@"code"] intValue];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
                NSError *jsonErrorFromResponse = [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:userInfo];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonErrorFromResponse);
                }];
                
                return;
            }
            
            /**/
            
            if(json) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock((NSArray *)json);
                }];
                
            } else {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    errorBlock(jsonError);
                }];
            }
        }];
        
    } errorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}

- (BOOL)canVerifyCredentials {
    return YES;
}

- (void)getResource:(NSString *)resource parameters:(NSDictionary *)params successBlock:(STTE_completionBlock_t)completionBlock errorBlock:(STTE_errorBlock_t)errorBlock {
    
    int HTTPMethod = TWRequestMethodGET;
    
    [self fetchAPIResource:resource httpMethod:HTTPMethod parameters:params completionBlock:completionBlock errorBlock:errorBlock];
}

- (void)postResource:(NSString *)resource parameters:(NSDictionary *)params successBlock:(STTE_completionBlock_t)completionBlock errorBlock:(STTE_errorBlock_t)errorBlock {
    
    int HTTPMethod = TWRequestMethodPOST;
    
    NSDictionary *d = params ? params : @{};
    
    [self fetchAPIResource:resource httpMethod:HTTPMethod parameters:d completionBlock:completionBlock errorBlock:errorBlock];
}

@end

