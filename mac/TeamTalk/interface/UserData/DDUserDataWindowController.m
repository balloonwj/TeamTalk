//
//  DDUserDataWindowController.m
//  Duoduo
//
//  Created by 独嘉 on 14-2-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserDataWindowController.h"
#import "DDUserDataModel.h"
#import "NSWindow+Addition.h"
#import "DDImageUploader.h"
#import "DDModifyUserAvatarAPI.h"
#import "MTSessionEntity.h"
#import "MTSessionModule.h"
#import "MTDatabaseUtil.h"
@interface DDUserDataWindowController ()

/**
 *  load the user info in model
 */
- (void)loadUserInfo;


- (void)setAllViewHidden:(BOOL)sender;


- (void)hidePanel;

- (void)n_receiveWindowResignKeyNotification:(NSNotification*)notification;
@end

@implementation DDUserDataWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    [self.window addCloseButtonAtTopLeft];
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setOpaque:NO];
    
    [_modifyAvatarButton setHidden:YES];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(n_receiveWindowResignKeyNotification:)
                                                 name:NSWindowDidResignMainNotification
                                               object:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setModel:(DDUserDataModel *)model
{
    if (_model)
    {
        _model = nil;
    }
    _model = model;
    [_model addObserver:self forKeyPath:@"showUser" options:0 context:nil];
}

- (IBAction)beginChat:(id)sender
{
    [[DDMainWindowController instance] openUserChatWithUser:self.model.showUser.ID];
    
    [self close];
}

- (IBAction)modifyUserAvater:(id)sender
{
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    
    /* set default image */
    [self p_setImageInputForPictureTaker:pictureTaker];
    
	/* configure the PictureTaker to show effects */
	[pictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
    
	/* other possible configurations (uncomments to try) */
	//[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerAllowsVideoCaptureKey];
	//[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerAllowsFileChoosingKey];
	//[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerShowRecentPictureKey];
	//[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerUpdateRecentPictureKey];
	//[pictureTaker setValue:[NSNumber numberWithBool:NO] forKey:IKPictureTakerAllowsEditingKey];
	//[pictureTaker setValue:[NSString stringWithString:@"Drop an Image Here"] forKey:IKPictureTakerInformationalTextKey];
	//[pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(256,256)] forKey:IKPictureTakerOutputImageMaxSizeKey];
	//[pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(100, 100)] forKey:IKPictureTakerCropAreaSizeKey];
    
	
	/* launch the PictureTaker as a panel */
	[pictureTaker beginPictureTakerWithDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
}

- (void)dealloc
{
    [_model removeObserver:self forKeyPath:@"showUser"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"showUser"])
    {
        [self loadUserInfo];
    }
}

#pragma mark Delegate
// -------------------------------------------------------------------------
//	pictureTakerValidated:code:contextInfo:
//
//  Invoked when the PictureTaker terminates.
//	Retrieves the output image and sets it on the view
// -------------------------------------------------------------------------
- (void) pictureTakerValidated:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf
{
    if(returnCode == NSOKButton){
		/* retrieve the output image */
        NSImage *outputImage = [pictureTaker outputImage];
        [self.model uploadAvatar:outputImage completion:^(NSString *url, NSError *error) {
            if (!error)
            {
                NSString* urlString = [url copy];
                if ([urlString rangeOfString:IMAGE_MARK_START].length > 0)
                {
                    urlString = [urlString stringByReplacingOccurrencesOfString:IMAGE_MARK_START withString:@""];
                    urlString = [urlString stringByReplacingOccurrencesOfString:IMAGE_MARK_END withString:@""];
                }
                DDModifyUserAvatarAPI* modifyUserAvatarAPI = [[DDModifyUserAvatarAPI alloc] init];
                
                NSString* myUserID = [[DDClientState shareInstance] userID];
                [modifyUserAvatarAPI requestWithObject:@[myUserID,urlString] Completion:^(id response, NSError *error) {
                    if (!error)
                    {
                        if ([response boolValue])
                        {
                            
                            DDLog(@"上传成功");
                            [[DDMainWindowController instance]leftChangeUseravatar:outputImage];
                        }
                        else
                        {
                            DDLog(@"上传失败");
                        }
                    }
                }];
            }
        }];
        [self hidePanel];
    }
	else{
		/* the user canceled => nothing to do here */
	}
}

#pragma mark privateAPI
- (void)loadUserInfo
{
    //头像
    NSString* avatar = _model.showUser.avatar;
    if ([avatar length] > 0)
    {
        if (avatar){
            NSURL* url = [NSURL URLWithString:avatar];
            [_userAvatar loadImageWithURL:url setplaceholderImage:@"avatar_default.jpg_48x48"];
        }
    }
    else
    {
        [_userAvatar setImage:[NSImage imageNamed:@"avatar_default.jpg_48x48"]];
    }
    
    //部门
    NSString* department = _model.showUser.departmentName;
    if (department)[_departmentTextField setStringValue:department];
    
    //性别
    NSUInteger gender = _model.showUser.gender;
    switch (gender)
    {
        case 1:
            [_userGenderTextField setStringValue:@"男"];
            break;
        case 2:
            [_userGenderTextField setStringValue:@"女"];
            break;
        default:
            break;
    }
    
    NSString* realName = _model.showUser.realName;
    if (realName) [_userNameTextField setStringValue:realName];
    
    NSString* name = _model.showUser.name;
    if (name) [_userNickTextField setStringValue:name];
    
    NSString* myUserID = [[DDClientState shareInstance] userID];
    [_modifyAvatarButton setHidden:![self.model.showUser.ID isEqualToString:myUserID]];
    
    
    NSString* tel = _model.showUser.tel;
    if(tel)
    {
        [_phoneTextField setStringValue:tel];
    }
    NSString *mail = _model.showUser.email;
    if (mail) {
        [_emailTextField setStringValue:mail];
    }
   
}


- (void)setAllViewHidden:(BOOL)sender
{
    for (NSView * subView in [[self.window contentView] subviews])
    {
        if (subView.tag < 10)
        {
            [subView setHidden:sender];
        }
    }
}

- (void)hidePanel
{
    [self.window orderOut:nil];
}

- (void)n_receiveWindowResignKeyNotification:(NSNotification*)notification
{
    NSWindow* window = [notification object];
    if ([window isEqual:self.window])
    {
        [self hidePanel];
    }
}

-(void)p_setImageInputForPictureTaker:(IKPictureTaker *)pictureTaker
{
    //retrieve example image
	NSURL *picURL = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle)
	{
		NSString *picPath = [bundle pathForResource:@"picture" ofType:@"jpg"];
		if (picPath)
		{
            /* set a default image to start with */
			picURL = [NSURL fileURLWithPath:picPath];
            [pictureTaker setInputImage:[[NSImage alloc] initByReferencingURL:picURL]];
		}
	}
}

@end
