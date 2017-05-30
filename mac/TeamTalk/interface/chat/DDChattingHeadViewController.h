//
//  DDChattingHeadViewController.h
//  Duoduo
//
//  Created by zuoye on 14-1-10.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTUserEntity.h"
#import "DDAddChatGroupWindowController.h"
#import "DDChattingMyLine.h"
@class AvatorImageView;
@interface DDChattingHeadViewController : NSViewController{
    DDAddChatGroupWindowController *addGroupWndController;
    int addType;
}

@property (nonatomic,strong)MTUserEntity* userEntity;
@property (nonatomic,weak) IBOutlet AvatorImageView *iconImage;
@property (nonatomic,weak) IBOutlet NSTextField* nametextField;
@property (nonatomic,weak) IBOutlet NSButton *userIconButton;
@property(nonatomic,weak)IBOutlet NSImageView *test;
@property (weak) IBOutlet NSButton *addParticipantButton;
@property (weak) IBOutlet NSButton *sendFilesButton;
@property (nonatomic,strong) IBOutlet DDChattingMyLine *line;
@property (nonatomic,strong) IBOutlet NSImageView* state;
@property (nonatomic,strong) NSString* sessionName;
@property (nonatomic,strong) NSString* sessionID;
- (IBAction)addParticipantToSession:(id)sender;
- (IBAction)sendFile:(id)sender;

-(void)setAddParticipantType:(int)type;

-(void)setAddGroupId:(NSString *)sessionId;

@end
