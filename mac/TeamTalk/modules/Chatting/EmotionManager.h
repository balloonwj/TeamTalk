//
//  EmotionManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmotionManager : NSObject
+ (EmotionManager*)instance;
- (NSString *)getFileFrom:(NSString *)text;
- (NSString *)getTextFrom:(NSString *)file;

@end
