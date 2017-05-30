//
//  MTSysConfigEntity.h
//  Duoduo
//
//  Created by wj on 15/1/20.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTSysConfigEntity : NSObject

@property (nonatomic,retain)NSString* sysConfigName;
@property (nonatomic)NSInteger sysConfigValue;

- (id)initWithsysConfigName:(NSString*)sysConfigName sysConfigValue:(NSInteger)sysConfigValue;
@end
