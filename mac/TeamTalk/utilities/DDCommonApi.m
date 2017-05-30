/************************************************************
 * @file         DDCommonApi.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       公共工具函数库
 ************************************************************/

#import "DDCommonApi.h"
#import "DDSound.h"

@implementation DDCommonApi

+(void) playSound:(NSString*)path
{
    [[DDSound instance] playSoundByPath:path];
}

@end
