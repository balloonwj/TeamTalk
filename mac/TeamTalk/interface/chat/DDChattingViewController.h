//
//  DDChattingViewController.h
//  Duoduo
//
//  Created by zuoye on 13-12-2.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDChattingInputView.h"
#import "MessageEntity.h"
#import "EGOImageLoader.h"
#import "MTSessionEntity.h"
#import "DDChattingContactListViewController.h"
#import "DDChattingHeadViewController.h"
#import "PullToRefreshScrollView.h"
#import "DrawView.h"
#import "WhiteBackgroundView.h"
#import "EmotionViewController.h"
#import "DDChattingViewModule.h"
@class MessageEntity,EGOImageView,DDGroupDataWindow,DDChattingViewModule,AvatorImageView;
@interface DDChattingViewController : NSViewController<NSTextViewDelegate,NSSplitViewDelegate,EGOImageViewDelegate,EmotionViewControllerDelegate, QLPreviewPanelDataSource,DDChattingViewModuleDataSource>{
    
    
    NSMutableDictionary *egoImageViews;
    DDUserDataWindowController* userDatawindowController;
    DDGroupDataWindow* groupDataWindow;
    IBOutlet WebView* _webView;
}

@property (nonatomic,retain)DDChattingViewModule* module;
@property (nonatomic,retain)NSPopover* popover;
@property (nonatomic,strong) IBOutlet DDChattingInputView *inputView;
@property (nonatomic,weak) IBOutlet NSSplitView *chatSplitView;
@property (nonatomic,strong) IBOutlet WhiteBackgroundView *userTypingView;
@property (nonatomic,weak) IBOutlet NSImageView *bottomRightView;
@property (nonatomic,weak) IBOutlet NSView *bottomMainView;
@property (nonatomic,weak) IBOutlet DDChattingContactListViewController *chattingContactListViewController;
@property(nonatomic,weak) IBOutlet NSImageView *inputBgView;
@property (nonatomic,weak) IBOutlet DDChattingHeadViewController *chattingHeadViewController;
@property (nonatomic,weak) IBOutlet DrawView* drawView;
@property (nonatomic,weak) IBOutlet NSButton* shakeButton;
@property (nonatomic,weak) IBOutlet NSButton * screenButton;
@property (nonatomic,weak) IBOutlet NSButton * emotionButton;
@property (nonatomic,weak) IBOutlet NSButton* almanceButton;
@property (nonatomic,weak) IBOutlet NSButton* bangButton;
@property (nonatomic,assign,readonly)BOOL observerClientState;

- (IBAction)emotionClick:(id)sender;
- (IBAction)screenCaptureClick:(NSButton *)sender;
- (IBAction)almanceClick:(id)sender;
- (IBAction)bangClick:(id)sender;

-(void)makeInputViewFirstResponder;

- (IBAction)clickTheUserIcon:(id)sender;

- (void)updateUI;
@end
