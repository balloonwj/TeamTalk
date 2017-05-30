//
//  DDHttpUtil.h
//  Duoduo
//
//  Created by maye on 13-11-10.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDHttpUtil : NSObject

+(NSMutableDictionary *)sendRequestWithParam:(NSString *)postText action:(NSString *)actionName;

@end
