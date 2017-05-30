/************************************************************
 * @file         DDModuleDataManager.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       基于module的业务层数据的序列化、反序列化
 ************************************************************/

#import "DDModuleDataManager.h"
#import "DDModuleManager.h"


@interface DDModuleDataManager()

-(NSString*)getDataPath;

@end

@implementation DDModuleDataManager

-(NSString*)getDataPath
{
    NSString* filePath = [[duoduo applicationSupportDirectory] stringByAppendingPathComponent:@"DuoDuoModuleData"];
    return filePath;
}

-(id)initModuleData:(NSArray*)moduleArray
{
    if(self = [super init])
    {
        _moduleArray = moduleArray;
    }
    return self;
}

-(BOOL)archive
{
    @autoreleasepool
    {
        NSMutableData* dataArchiver = [[NSMutableData alloc] init];
        NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataArchiver];
        for (DDModule* module in _moduleArray)
        {
            if([module conformsToProtocol:@protocol(NSCoding)])
            {
                NSString* key = [NSString stringWithFormat:@"%d",module.moduleId];
                [archiver encodeObject:module forKey:key];
            }
        }
        [archiver finishEncoding];
        NSString* filePath = [self getDataPath];
        return [dataArchiver writeToFile:filePath atomically:YES];
    }
}

-(BOOL)unArchive
{
    @autoreleasepool
    {
        NSString* filePath = [self getDataPath];
        NSData* dataUnArchiver = [[NSData alloc] initWithContentsOfFile:filePath];
        if(!dataUnArchiver)
            return NO;
        NSKeyedUnarchiver* unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:dataUnArchiver];
        if(!unArchiver)
            return NO;

        for (DDModule* module in _moduleArray)
        {
            if([module conformsToProtocol:@protocol(NSCoding)])
            {
                NSString* key = [NSString stringWithFormat:@"%d",module.moduleId];
                [unArchiver decodeObjectForKey:key];
            }
        }
        [unArchiver finishDecoding];
    }
    
    return YES;
}

@end
