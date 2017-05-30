/************************************************************
 * @file         NSDictionary+MGJ.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       NSNotification扩展 用于DDLogic notify监听函数可以方便的去处userid
 ************************************************************/

#import "NSNotification+DDLogic.h"

@implementation NSNotification (DDLogic)

-(void)setSessionId:(NSString*)uId
{
    [self.userInfo setValue:uId forKey:USERINFO_SID];
}

-(NSString*)sessionId
{
    return [self.userInfo valueForKey:USERINFO_SID];
}

@end
