/************************************************************
 * @file         DDCommonModule.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       多多项目使用的一些公共库 注：如果觉得这个可以积累下来作为以后其他项目公共库，请放到utilities下
 ************************************************************/

#import "DDCommonModule.h"

DDCommonModule* getDDCommonModule()
{
    return (DDCommonModule*)[[DDLogic instance] queryModuleByID:MODULE_ID_COMMON];
}

@implementation DDCommonModule

-(id) initModule
{
    if(self = [super initModule:MODULE_ID_COMMON])
    {
    }
    return self;
}

@end
