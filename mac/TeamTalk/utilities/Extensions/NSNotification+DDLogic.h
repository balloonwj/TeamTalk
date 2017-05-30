/************************************************************
 * @file         NSDictionary+MGJ.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       NSNotification扩展 用于DDLogic notify监听函数可以方便的去处userid
 ************************************************************/

#import <Foundation/Foundation.h>

static NSString* const USERINFO_SID = @"notification_sid";                   //NSNotification通知userinfo字典的sessionId
static 

@interface NSNotification (DDLogic)

-(void)setSessionId:(NSString*)uId;
-(NSString*)sessionId;

@end
