/************************************************************
 * @file         DDCommonApi.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       公共工具函数库
 ************************************************************/

#import <Foundation/Foundation.h>

@interface DDCommonApi : NSObject

//播放消息、系统声音等
+(void) playSound:(NSString*)path;

@end
