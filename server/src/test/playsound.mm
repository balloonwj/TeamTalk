#import <Cocoa/Cocoa.h>
#import "playsound.h"
@interface Delegate : NSObject { }
@end

@implementation Delegate
- (void) sound: (NSSound *) sound didFinishPlaying: (BOOL) aBool
{
//  [[NSApplication sharedApplication] terminate: nil];
}
@end


void play(const char* pFileName)
{
    [[NSAutoreleasePool alloc] init];
  
    NSSound *sound = [[NSSound alloc]
                      initWithContentsOfFile:
                      [NSString stringWithCString: pFileName]
                      byReference: YES];
  
    [sound setDelegate: [[[Delegate alloc] init] autorelease]];
    [sound play];
//    [[NSRunLoop currentRunLoop] run];
}
