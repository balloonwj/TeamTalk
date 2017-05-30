//
//  DDUserDataWindowController.h
//  Duoduo
//
//  Created by 独嘉 on 14-2-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@class DDUserDataModel;
@interface DDUserDataWindowController : NSWindowController
{
    __strong IBOutlet EGOImageView* _userAvatar;
    __weak IBOutlet NSTextField* _userNameTextField;
    __weak IBOutlet NSTextField* _userNickTextField;
    __weak IBOutlet NSTextField* _userGenderTextField;
    
    __weak IBOutlet NSTextField* _departmentTextField;
    __weak IBOutlet NSTextField* _jobTextField;
    __weak IBOutlet NSTextField* _emailTextField;
    __weak IBOutlet NSTextField* _phoneTextField;
    
    __weak IBOutlet NSButton* _modifyAvatarButton;
    
//    __weak IBOutlet NSProgressIndicator* _loadIndicator;

}
@property (nonatomic,retain)DDUserDataModel* model;

- (IBAction)beginChat:(id)sender;
- (IBAction)modifyUserAvater:(id)sender;
@end
