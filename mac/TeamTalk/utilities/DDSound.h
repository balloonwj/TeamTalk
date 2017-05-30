/************************************************************
 * @file         DDSound.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       播放声音相关
 ************************************************************/

#import <Foundation/Foundation.h>

#define MESSAGE_SOUND @"message.wav"

@interface DDSound : NSObject
{
    NSMutableDictionary* soundCachedDict;
}

+(instancetype)instance;
-(void) playSoundByPath:(NSString*)path;

@end
