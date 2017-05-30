//
//  DDGroupDataModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-3.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTGroupEntity;
@interface DDGroupDataModule : NSObject

@property (nonatomic,retain)MTGroupEntity* showGroup;

- (NSString*)windowTitle;
- (NSInteger)rowNumber;
- (NSArray*)usersForRow:(NSInteger)row;
@end
