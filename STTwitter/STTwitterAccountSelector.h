//
//  STTwitterAccountSelector.h
//  TwitterTest
//
//  Created by Govi on 30/04/2013.
//  Copyright (c) 2013 Genie-Connect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

#define kLastSelectedTwitterUsername @"lastSelectedUsernane"
#define kSTTwitterRegCompleteNotification @"reg complete"

typedef enum {
    STTwitterAccountConfigStatusUnknown,
    STTwitterAccountConfigStatusNoAccounts,
    STTwitterAccountConfigStatusSelected
} STTwitterAccountConfigStatus;

@interface STTwitterAccountSelector : NSObject <UIActionSheetDelegate> {
    void(^onSelect)(ACAccount *selectedAccount);
    void(^onCancel)(NSError *error);
    ACAccountStore *accountStore;
    STTwitterAccountConfigStatus lastStatus;
}

@property (nonatomic, strong) ACAccount *currentAccount;
@property (nonatomic, strong) NSArray *shownAccounts;

+(void) getCurrentAccount:(void(^)(ACAccount *account))selected cancelled:(void(^)(NSError *error))cancelled;
+(void)selectAccount:(void(^)(ACAccount *account))selected cancelled:(void(^)(NSError *error))cancelled;
+(STTwitterAccountSelector *)sharedSelector;
-(STTwitterAccountConfigStatus)hasConfiguredAccounts;
-(void)requestAccess;

@end
