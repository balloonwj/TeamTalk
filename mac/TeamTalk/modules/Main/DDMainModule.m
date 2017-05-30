/************************************************************
 * @file         DDMainModule.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       主窗口业务模块
 ************************************************************/

#import "DDMainModule.h"
#import "DDMainWindowController.h"

DDMainModule* getDDMainModule()
{
    return (DDMainModule*)[[DDLogic instance] queryModuleByID:MODULE_ID_MAIN];
}

@interface DDMainModule()


@end

@implementation DDMainModule

-(id) initModule
{
    if(self = [super initModule:MODULE_ID_MAIN])
    {
    }
    return self;
}

-(void) showMainWindow
{
    if(!_mainWindowController)
    {
        _mainWindowController = [[DDMainWindowController alloc] init];
    }
    [_mainWindowController showWindowInFrontIfAllowed:YES];
}


@end
