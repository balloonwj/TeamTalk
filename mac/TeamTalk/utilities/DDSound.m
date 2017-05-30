/************************************************************
 * @file         DDSound.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       播放声音相关
 ************************************************************/

#import "DDSound.h"

@implementation DDSound

+(instancetype)instance
{
    static DDSound* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

-(id)init
{
    if(self = [super init])
    {
        soundCachedDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) playSoundByPath:(NSString*)path
{
    NSSound* sound = [soundCachedDict valueForKey:path];
    if(!sound)
    {
        NSString* absolutePath = [[NSBundle mainBundle] pathForResource:path ofType:@""];
        sound = [[NSSound alloc] initWithContentsOfFile:absolutePath byReference:NO];
        //sound = [[NSSound alloc] initWithContentsOfFile: path byReference: YES];
        //sound = [NSSound soundNamed:path];
        if(sound)
        {
            [soundCachedDict setObject:sound forKey:path];
        }
    }
    [sound setCurrentTime:0.0];
    [sound play];
}

@end
