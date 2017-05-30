//
//  MTUserModule.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import "DDRootModule.h"
#import "DDOriginModuleProtocol.h"
@interface MTGroupModule :DDRootModule <DDOriginModuleProtocol>
+ (MTGroupModule*)shareInsatnce;

- (void)updateTempGroupInfoFromSessions:(NSArray*)groupIDs;
@end
