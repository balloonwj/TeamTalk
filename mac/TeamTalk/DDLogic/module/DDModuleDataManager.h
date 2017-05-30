/************************************************************
 * @file         DDModuleDataManager.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       基于module的业务层数据的序列化、反序列化
 ************************************************************/

#import <Foundation/Foundation.h>

@interface DDModuleDataManager : NSObject
{
    NSArray*                    _moduleArray;
}

-(id)initModuleData:(NSArray*)moduleArray;
-(BOOL)archive;
-(BOOL)unArchive;

@end
