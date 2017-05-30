//
//  DDRecentContactsModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-29.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LoadRecentContactsCompletion)(NSArray* contacts);

@interface DDRecentContactsModule : NSObject

- (void)loadRecentContacts:(LoadRecentContactsCompletion)completion;
- (void)saveRecentContacts;

@end
