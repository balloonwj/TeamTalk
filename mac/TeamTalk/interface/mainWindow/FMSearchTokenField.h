//
//  FMSearchTokenField.h
//  Duoduo
//
//  Created by zuoye on 13-12-23.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMSearchTokenField : NSTokenField{
    BOOL sendActionWhenEditing;
}

@property (assign) BOOL sendActionWhenEditing;
@property (assign) BOOL alwaysSendActionWhenPressEnter;
@property (assign) unichar m_tokenizingChar;

+(void)initialize ;
@end
