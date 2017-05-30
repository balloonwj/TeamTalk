//
//  DDChattingViewController.m
//  Duoduo
//
//  Created by zuoye on 13-12-2.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDChattingViewController.h"
#import "EGOImageView.h"
#import "MTUserEntity.h"
#import "MTUserModule.h"
#import "MTMessageModule.h"
#import "MTSessionModule.h"
#import "EGOCache.h"
#import "AIImageAdditions.h"
#import "NSImage+Stretchable.h"
#import "EmotionViewController.h"
#import "DDEmotionAttachment.h"
#import "DDUserPreferences.h"
#import "NSString+DDStringAdditions.h"
#import "DDGroupInfoManager.h"
#import "DDUserInfoManager.h"
#import "MTGroupModule.h"
#import "DDChattingViewModule.h"
#import "MessageViewFactory.h"
#import "MTDatabaseUtil.h"
#import "MTSessionModule.h"
#import "DDMessageSendManager.h"
#import "MTGroupEntity.h"
#import "NSImage+Stretchable.h"
#import "AvatorImageView.h"
#import "StateMaintenanceManager.h"
#import "NSView+LayerAddition.h"
#import "DDSendP2PCmdAPI.h"
#import "DDServiceAccountModule.h"
#import "MessageDate.h"
#import "MTMessageEntity.h"
#import "MTImageDownload.h"
#import "MTImageCache.h"
#import "MTScreenCaptureModule.h"
#import "MTPreviewItem.h"
#define IMAGE_MARK_START @"&$#@~^@[{:"
#define IMAGE_MARK_END @":}]&$~@#@"

static EmotionViewController *emotionViewController = nil;

@interface DDChattingViewController(privateAPI)

- (void)p_updateWebView;
- (void)receiveTheGroupMemberNotification:(NSNotification*)notification;
- (void)receiveMsgSendAckNotification:(NSNotification*)notification;

/**
 *  在WebView 上插入消息
 *
 *  @param messages 待插入的消息
 *  @param bottom   在底部插入还是顶部
 */
- (void)p_addMessagesOnWebView:(NSArray*)messages top:(BOOL)top;

- (void)p_receiveBoundsChanged:(NSNotification*)notification;

//webview 里面调用

- (NSString*)x_getUserInfoWithUserID:(NSString*)userID;

- (WebScriptObject*)x_getInitialMessage:(WebScriptObject*)sender;

//- (WebScriptObject*)x_getMoreMessage:(WebScriptObject*)sender;

- (WebScriptObject*)x_loadMoreHistoryMessage:(WebScriptObject*)sender;

- (void)x_getHistoryMessageBeforeMessageID:(NSUInteger)messageID;

- (void)x_previewImagesForURL:(NSString*)url;

- (void)x_chatWithUserID:(NSString*)userID;

- (void)x_previewUserInfoWithUserID:(NSString*)userID;

- (void)x_updateMessageForMessageID:(NSUInteger)messageID state:(MTMessageSendState)state;

- (void)x_openURL:(NSString*)url;

//----------------
- (void)p_receiveMessageNotification:(NSNotification*)notification;
@end

@implementation DDChattingViewController
{
    NSPopover* _popover;
    NSString* _currentURL;
    NSUInteger _lastInputTime;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _configureTextEntryView];
    }
    return self;
}

- (void)setModule:(DDChattingViewModule *)module
{
    if (_module)
    {
        //将输入框内容加入到草稿箱
        NSAttributedString* text = _inputView.textStorage;
        if (_module.session)
        {
            [[MTMessageModule shareInstance] setDraft:text forSessionID:_module.session.sessionID];
        }
        
        _module = nil;
    }
    _module = module;
    //读草稿
    _module.dataSource = self;
    NSAttributedString* draft = [[MTMessageModule shareInstance] getDraftForSessionID:module.session.sessionID];
    if (draft)
    {
        [_inputView.textStorage setAttributedString:draft];
    }
    else
    {
        [_inputView setString:@""];
    }
}

- (void)awakeFromNib{
    [self updateUI];
    _observerClientState=YES;
    [[StateMaintenanceManager instance] addObserver:self
                                    forKeyPath:DD_USER_ONLINE_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveBoundsChanged:) name:NSViewFrameDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_receiveMessageNotification:) name:DD_MESSAGE_MODULE_RECEIVE_MESSAGE object:nil];
    

}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_USER_ONLINE_STATE_KEYPATH]) {
        DDUserStateEntity *userStateEntity = [change valueForKey:@"new"];
        
        if ( [userStateEntity.userId isEqualToString:self.module.session.sessionID]) {
            [self setStateImage];
        }
    }
}

-(void)setStateImage{
    UserStatType stateType = [[StateMaintenanceManager instance]getUserStateForUserID:self.module.session.sessionID];
    if(stateType== UserStatTypeUserStatusOffline || stateType == UserStatTypeUserStatusLeave) {
        NSImage* image = [NSImage imageNamed:@"state-offline"];
        [self.chattingHeadViewController.state setImage:image];
    }else if(stateType == UserStatTypeUserStatusOnline){
        NSImage* image = [NSImage imageNamed:@"state-online"];
        [self.chattingHeadViewController.state setImage:image];
    }
}

- (void)dealloc
{
    if (_observerClientState) {
        [[StateMaintenanceManager instance] removeObserver:self forKeyPath:DD_USER_STATE_KEYPATH];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)makeInputViewFirstResponder{
    [[DDMainWindowController instance].window makeFirstResponder:_inputView];
}

- (void)_configureTextEntryView{
    egoImageViews =[[NSMutableDictionary alloc] init];
}


- (NSPopover*)popover
{
    if (!_popover)
    {
        _popover = [[NSPopover alloc] init];
        _popover.animates = YES;
        _popover.appearance = NSPopoverAppearanceMinimal;
        _popover.behavior = NSPopoverBehaviorTransient;
    }
    return _popover;
}

- (IBAction)emotionClick:(id)sender {
    if (!emotionViewController) {
        emotionViewController = [[EmotionViewController alloc] initWithNibName:@"EmotionPopover" bundle:nil];
    }
    self.popover.contentViewController = emotionViewController;
    [self.popover showRelativeToRect:[sender bounds]
                              ofView:sender
                       preferredEdge:NSMinYEdge];
    emotionViewController.delegate = self;
}



- (IBAction)screenCaptureClick:(NSButton *)sender {

    [[MTScreenCaptureModule shareInstance] capture:sender];
    [self makeInputViewFirstResponder];
}

- (IBAction)clickTheUserIcon:(id)sender
{
    if ([self.module.session.sessionID hasPrefix:@"group"])
    {
        //群成员查看
        MTGroupEntity* groupEntity = (MTGroupEntity*)[[MTGroupModule shareInsatnce]getOriginEntityWithOriginID:self.module.session.originID];
        [[DDGroupInfoManager instance] showGroup:groupEntity context:self];
    }
    else
    {
        //个人信息查看
        
        MTUserEntity* showUser = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:self.module.session.originID];
        [[DDUserInfoManager instance] showUser:showUser forContext:self];
    }
}

- (IBAction)sendWindowshake:(id)sender
{
    DDSendP2PCmdAPI* p2pAPI = [[DDSendP2PCmdAPI alloc] init];
    NSString *fromUserId = [[DDClientState shareInstance] userID];
    NSString *toId = self.module.session.originID;
    NSString* content = [DDSendP2PCmdAPI contentFor:SHAKE_WINDOW_SERVICEID commandID:SHAKE_WINDOW_COMMAND content:SHAKE_WINDOW];
    NSArray* object = @[fromUserId,toId,content,@(1000)];
    log4CInfo(@"message ack from userID：%@",fromUserId);
    [p2pAPI requestWithObject:object Completion:nil];
    [[DDMainWindowController instance] shakeTheWindow];
    
    [sender setEnabled:NO];
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender setEnabled:YES];
    });
}

- (IBAction)almanceClick:(id)sender
{
    [[DDServiceAccountModule shareInstance] sendAlmanac];
}

- (IBAction)bangClick:(id)sender
{
    [[DDMainWindowController instance] shakeTheWindow];
    [[DDServiceAccountModule shareInstance] sendBang];
    [sender setEnabled:NO];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender setEnabled:YES];
    });
}

- (void)updateUI
{
    if (self.module.session.sessionType == SessionTypeSessionTypeGroup)
    {
        MTGroupEntity* group = (MTGroupEntity*)[[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:self.module.session.originID];
        
        [[self.chattingHeadViewController sendFilesButton] setHidden:YES];
        if (group.groupType == DDTmpGroupType)
        {
            //临时群
            
            NSString *sid = self.module.session.originID;
            MTGroupEntity *groupEntity =(MTGroupEntity *) [[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:sid];
            
            self.chattingContactListViewController.groupEntity =groupEntity;
            [self.chattingContactListViewController updateTitle];
            
            [[self.chattingHeadViewController addParticipantButton] setEnabled:YES ];
            [self.chattingHeadViewController setAddParticipantType:1];
            [[self.chattingHeadViewController sendFilesButton] setHidden:YES];
        }
        else if (group.groupType == DDNormalGroupType)
        {
            //固定群
            NSString *sid = self.module.session.originID;
            MTGroupEntity *groupEntity =(MTGroupEntity *) [[MTGroupModule shareInsatnce] getOriginEntityWithOriginID:sid];
            
            self.chattingContactListViewController.groupEntity =groupEntity;
            [self.chattingContactListViewController updateTitle];
            
            [[self.chattingHeadViewController addParticipantButton] setEnabled:NO ];
            [[self.chattingHeadViewController sendFilesButton] setHidden:YES];
        }
        [[self bottomRightView] setHidden:NO];
        

        [_chatSplitView setFrame:CGRectMake(0, 0, _bottomMainView.frame.size.width - self.bottomRightView.bounds.size.width, _bottomMainView.frame.size.height)];
    }
    else if(SessionTypeSessionTypeSingle == [self.module.session sessionType])
    {
        [[self bottomRightView] setHidden:YES];



        [_chatSplitView setFrame:_bottomMainView.frame];
        MTUserEntity* user =(MTUserEntity* )[[MTUserModule shareInstance] getOriginEntityWithOriginID:self.module.session.originID];
        _chattingHeadViewController.userEntity = user;
        [[self.chattingHeadViewController addParticipantButton] setEnabled:![user.ID isEqualToString:@"99999999"] ];
        
        [self.chattingHeadViewController setAddParticipantType:0];
    }
    
    [self.chattingHeadViewController.nametextField setStringValue:self.module.session.name?self.module.session.name:@""];
    [self.chattingHeadViewController setSessionName:self.module.session.name?self.module.session.name:@""];
    [self.chattingHeadViewController setSessionID:self.module.session.sessionID];

    switch (self.module.session.sessionType)
    {
        case SessionTypeSessionTypeSingle:
        {
//            [self.chattingHeadViewController.iconImage setType:UserAvator];
            [self.chattingHeadViewController.iconImage setSession:self.module.session];
            [self.chattingHeadViewController.state setHidden:NO];
            [self setStateImage];
        }
            break;
        case SessionTypeSessionTypeGroup:
        {
//            [self.chattingHeadViewController.iconImage setType:GroupAvator];
            [self.chattingHeadViewController.iconImage setSession:self.module.session];
            [self.chattingHeadViewController.state setHidden:YES];
        }
            break;
    }
    
    if (self.module.session.sessionType != SessionTypeSessionTypeSingle)
    {
        [self.shakeButton setHidden:YES];

    }else{
        [self.shakeButton setHidden:NO];
    }
    
    //    [_inputView setTarget:self action:@selector(sendMsgToServer:)];
    //tt_3.0
  //  [_inputView setSessionEntity:self.module.session];
    
    
    //加载历史消息

    
    
    if (![[DDServiceAccountModule shareInstance] isServiceAccount:self.module.session.sessionID])
    {
        [self.almanceButton setHidden:YES];
        [self.bangButton setHidden:YES];
    }
    

    
    [[self.shakeButton cell] setHighlightsBy:NSContentsCellMask];
    [[self.screenButton cell] setHighlightsBy:NSContentsCellMask];
    [[self.emotionButton cell] setHighlightsBy:NSContentsCellMask];
    [[self.almanceButton cell] setHighlightsBy:NSContentsCellMask];
    [[self.bangButton cell] setHighlightsBy:NSContentsCellMask];
    
    [_chattingContactListViewController updateTitle];
    [_chattingContactListViewController reloadContactListTableView];
    [self p_updateWebView];
    [self makeInputViewFirstResponder];
}

#pragma mark TextView Delegate
- (void)textView:(NSTextView *)textView
   clickedOnCell:(id<NSTextAttachmentCell>)cell
          inRect:(NSRect)cellFrame
         atIndex:(NSUInteger)charIndex
{
    //    selectImageRect = cellFrame;
    //tt_3.0
    //self.inputView.currentIndex = charIndex;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray *)affectedRanges replacementStrings:(NSArray *)replacementStrings
{
    if(self.module.session.sessionType==SessionTypeSessionTypeSingle) {
        //控制发送限制
        NSUInteger nowTime = [[NSDate date] timeIntervalSince1970];
        
        if ((nowTime - _lastInputTime) > 3)
        {
            _lastInputTime = nowTime;
            DDSendP2PCmdAPI* p2pAPI = [[DDSendP2PCmdAPI alloc] init];
            NSString *fromUserId = [[DDClientState shareInstance] userID];
            NSString *toId = self.module.session.originID;
            NSString* content = [DDSendP2PCmdAPI contentFor:INPUTING_SERVICEID commandID:INPUTING_COMMAND content:INPUTING];
            NSArray* object = @[fromUserId,toId,content,@(1000)];
            [p2pAPI requestWithObject:object Completion:nil];
        }
    }
    return YES;
}

-(BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector{
    NSEvent *currentEvent = [[self.inputView window] currentEvent];
    unichar character = [[currentEvent charactersIgnoringModifiers] characterAtIndex:0];
    NSUInteger flags = [currentEvent modifierFlags];
    
    if (flags & NSAlternateKeyMask)
    {
        //按了alt
        if (commandSelector == @selector(moveForward:))
        {
            //往下翻
            NSAttributedString* content = [self.module getNextInputHistoryMessages];
            if (content)
            {
                [_inputView.textStorage setAttributedString:content];
            }
        }
        else if (commandSelector == @selector(moveBackward:))
        {
            //往上翻
            NSAttributedString* content = [self.module getLastInputHistoryMessages];
            if (content)
            {
                [_inputView.textStorage setAttributedString:content];
            }
        }
    }
    
    if ((@selector(insertNewline:) !=commandSelector) && @selector(insertLineBreak:) != commandSelector) {
        if ((@selector(insertNewlineIgnoringFieldEditor:) != commandSelector) && (character != 0x3)){
            commandSelector = nil;
            if (character != 0xd){
                return NO;
            }
        }
    }
    if([[DDUserPreferences defaultInstance] msgSendKey]==1){       //commond + enter
        if ((((character == 0x3) || (character == 0xd))) && ((flags & 0x100000) != 0x0)) {
           [self sendMsgToServer:nil];
            return YES;
        }
        [self.inputView insertLineBreak:nil];
        commandSelector=nil;
        return YES;
    }else{      //enter
        if ((((character == 0x3) || (character == 0xd))) && ((flags & 0x1e0000) == 0x0)) {
            [self sendMsgToServer:nil];
            return YES;
        }
        [self.inputView insertLineBreak:nil];
        commandSelector=nil;
        return YES;
    }
    return NO;
}

-(void)sendMsgToServer:(id)sender
{
    NSAttributedString* text = _inputView.textStorage;
    if ([[text string] allSpaceAllNewLine])
    {
        DDLog(@"不能发送全部是空格或者换行的内容哦");
        return;
    }
    
    //加入到发送历史记录
    __block BOOL shouldAppearOnWebView = YES;
    [[MTMessageModule shareInstance] addInputHistory:text forSessionID:self.module.session.sessionID];
    self.module.inputHistoryMessageIndex = 0;
    NSAttributedString* showInContentViewAttribute = [self.module getAttributedStringFromInputContent:text compress:YES];
    MTMessageEntity* message = [[MTMessageModule shareInstance] sendMessage:showInContentViewAttribute forSession:self.module.session.sessionID completion:^(MTMessageEntity *message, NSError *error) {
        //更新聊天界面的某条消息
        [self x_updateMessageForMessageID:message.messageID state:message.sendState];
        if (error.code == 1002)
        {
            //消息内容太长了
            shouldAppearOnWebView = NO;
            NSAlert *alert = [NSAlert alertWithMessageText:@"发送失败" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"消息内容太长了，请分多次发送~"];
            if ([alert runModal]!=NSAlertDefaultReturn){
                NSLog(@"cancel");
            }
            else{
                NSLog(@"ok");
            }
        }
    }];
    if (shouldAppearOnWebView)
    {
        [self p_addMessagesOnWebView:@[message] top:NO];
        [_inputView setString:@""];
        MTSessionEntity* session = self.module.session;
        [session updateUpdateTime:[[NSDate date] timeIntervalSince1970]];
        [[NSNotificationCenter defaultCenter] postNotificationName:DD_RECENT_CONTACTS_VIEW_RELOAD_NOTIFICATION object:nil];
    }
}


-(void)imageViewLoadedImage:(EGOImageView *)imageView{
//    [_txtContent replaceImage:imageView.imageLocalPath atIndex:imageView.imageIndex fromUser:imageView.fromUserId];
    [egoImageViews removeObjectForKey:[NSString stringWithFormat:@"%ld", imageView.imageIndex]];
}
-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error{
    DDLog(@"  \n\n\n\n  imageViewFailedToLoadImage:%@ \nerror:%@\n\n\n",imageView,error);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMinimumPosition + (_chatSplitView.frame.size.height-160);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMaximumPosition - 80;
}

#pragma mark -
#pragma mark EmotionViewCOntroller Delegate
- (void)emotionViewController:(EmotionViewController*)emotionViewCOntroller selectEmotionFile:(NSString*)emotionFile
{
    [self makeInputViewFirstResponder];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:emotionFile
                                                          ofType:nil];
    DDLog(@"emotion file: %@ imagePath:%@", emotionFile,imagePath);
    NSImage *image =[NSImage imageNamed:emotionFile];
    //
    if (!image) {
        return;
    }
    
    NSURL *fileUrl = [NSURL fileURLWithPath:imagePath];
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initSymbolicLinkWithDestinationURL:fileUrl];
    [fileWrapper setIcon:image];
    [fileWrapper setPreferredFilename:imagePath];
    DDEmotionAttachment *attachment = [[DDEmotionAttachment alloc] init];
    [attachment setFileWrapper:fileWrapper];
    [attachment setEmotionFileName:emotionFile];
    [attachment setEmotionPath:imagePath];
    [attachment setEmotionText:[emotionViewController getTextFrom:emotionFile]];
    
    NSMutableAttributedString *attachmentString = (NSMutableAttributedString*)[NSMutableAttributedString attributedStringWithAttachment:attachment];
    NSTextStorage* textStorage = [_inputView textStorage];
    [textStorage appendAttributedString:attachmentString];
    
    [self.popover close];
}

#pragma mark -
#pragma mark WebFrameLoadDelegate

//通过此回调，将self传递给JS环境
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [windowObject setValue:self forKey:@"native"];
    [windowObject setValue:@(_webView.bounds.size.height) forKey:@"bounds"];
}

#pragma mark privateAPI

- (void)p_updateWebView
{
    _webView.frameLoadDelegate = self;
    NSString* filePath = [[NSBundle mainBundle]pathForResource:@"message" ofType:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    [_webView.mainFrame loadRequest:request];
}

/*
 返回是否阻止响应该方法,
 返回NO即能响应该方法
 */
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(x_getInitialMessage:) || selector == @selector(x_getUserInfoWithUserID:) || selector == @selector(x_getOwnerInfo) || selector == @selector(x_getHistoryMessageBeforeMessageID:) || selector == @selector(x_loadMoreHistoryMessage:) || selector == @selector(x_previewImagesForURL:) || selector == @selector(x_chatWithUserID:) || selector == @selector(x_previewUserInfoWithUserID:) || selector == @selector(x_openURL:))
    {
        return NO;
    }
    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel
{
    if (sel == @selector(x_getInitialMessage:))
    {
        return @"getInitMsg";
    }
    else if (sel == @selector(x_getUserInfoWithUserID:))
    {
        return @"getUserById";
    }
    else if (sel == @selector(x_getOwnerInfo))
    {
        return @"getOwnInfo";
    }
    else if (sel == @selector(x_getOwnerInfo))
    {
        return @"getOwnInfo";
    }
    else if(sel == @selector(x_getHistoryMessageBeforeMessageID:))
    {
        return @"getHistoryMsg";
    }
    else if (sel == @selector(x_loadMoreHistoryMessage:))
    {
        return @"loadMoreHistoryMessage";
    }
    else if (sel == @selector(x_previewImagesForURL:))
    {
        return @"previewImagesForURL";
    }
    else if (sel == @selector(x_chatWithUserID:))
    {
        return @"chatWithUid";
    }
    else if (sel == @selector(x_previewUserInfoWithUserID:))
    {
        return @"viewInfoWithUid";
    }
    else if (sel == @selector(x_updateMessageForMessageID:state:))
    {
        return @"updateStatus";
    }
    else if (sel == @selector(x_openURL:))
    {
        return @"openURL";
    }
    return nil;
}

- (void)p_addMessagesOnWebView:(NSArray*)messages top:(BOOL)top
{
    NSMutableArray* jsons = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < [messages count]; index ++)
    {
        MTMessageEntity* messageEntity = messages[index];
        
        NSString* messageJson = [messageEntity toJson];
        [jsons addObject:messageJson];
        //如果消息中有图片，需要去下载网络图片
        NSArray* imageURLs = [messageEntity imageURL];
        for (NSInteger index = 0; index < [imageURLs count]; index ++)
        {
            NSString* imageURL = imageURLs[index];
            [[MTImageDownload shareInstance] loadFileWithURL:imageURL completion:^(NSString *targetFilePath, NSError *error) {
            }];
        }
    }
    
    NSError *err = nil;
    NSData *historyData = [NSJSONSerialization dataWithJSONObject:jsons
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&err];
    NSString *historyJson = [[NSString alloc] initWithData:historyData
                                                  encoding:NSUTF8StringEncoding];
    
    [[_webView windowScriptObject] callWebScriptMethod:@"renderMessage" withArguments:@[historyJson,@(top)]];

}

- (void)p_receiveBoundsChanged:(NSNotification*)notification
{
    NSRect webViewFrame = _webView.frame;
    [[_webView windowScriptObject] callWebScriptMethod:@"webViewBoundChange" withArguments:@[@(webViewFrame.size.height)]];
}

#pragma mark -
#pragma mark QLPreviewPanelDataSource
- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    MTPreviewItem* previewItem = [[MTPreviewItem alloc] initWithItemURL:_currentURL title:_currentURL];
    return previewItem;
}

#pragma mark -
#pragma mark DDChattingViewModuleDataSource
- (NSAttributedString*)getCurrentAttribute
{
    return [_inputView.textStorage copy];
}

#pragma mark -
#pragma mark WebView

- (NSString*)x_getOwnerInfo
{
    NSString* myUserID = [DDClientState shareInstance].userID;
    MTUserEntity* my = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:myUserID];
    return [my toJson];
}

- (NSString*)x_getUserInfoWithUserID:(NSString*)userID
{
    MTUserEntity* user = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:userID];
    return [user toJson];
}


- (WebScriptObject *)x_getInitialMessage:(WebScriptObject *)jsObject
{
//    NSUInteger lastMessageID = [[MTMessageModule shareInstance] getLastMessageIDForSessionID:self.module.session.sessionID];
//    [self x_getHistoryMessageBeforeMessageID:lastMessageID];
    return jsObject;
}

//- (WebScriptObject*)x_getMoreMessage:(WebScriptObject*)sender
//{
//    [self x_getHistoryMessageBeforeMessageID:self.module.firstMessageID];
//    return sender;
//}

- (WebScriptObject*)x_loadMoreHistoryMessage:(WebScriptObject*)sender
{
    if (!self.module.loadingHistoryMessage)
    {
        [self x_getHistoryMessageBeforeMessageID:self.module.firstMessageID];
    }
    return sender;
}

- (void)x_getHistoryMessageBeforeMessageID:(NSUInteger)messageID
{
    self.module.loadingHistoryMessage = YES;
    [[MTMessageModule shareInstance] getHistoryMessage:self.module.session.sessionID fromMessageID:messageID count:20 Completion:^(NSArray *messages) {
        self.module.loadingHistoryMessage = NO;
        //在当前会话的话再加载数据，否则忽略
        if ([[MTSessionModule shareInstance].currentChatingSessionID isEqualToString:self.module.session.sessionID])
        {
            if ([messages count] > 0)
            {
                MTMessageEntity* firstMessage = [messages lastObject];
                if (![firstMessage.sessionID isEqualToString:self.module.session.sessionID])
                {
                    return;
                }
                self.module.firstMessageID = firstMessage.messageServerID - 1;
            }
            
//            if (self.module.firstTimeToLoadMessage)
//            {
//                self.module.firstTimeToLoadMessage = NO;
//                NSMutableArray* newSortMessage = [[NSMutableArray alloc] init];
//                for (NSInteger index = [messages count] - 1; index >= 0 ; index --)
//                {
//                    MTMessageEntity* message = messages[index];
//                    [newSortMessage addObject:message];
//                }
//                [self p_addMessagesOnWebView:newSortMessage top:NO];
//            }
//            else
//            {
                [self p_addMessagesOnWebView:messages top:YES];
//            }
        }
    }];
}

- (void)x_previewImagesForURL:(NSString*)url
{
    _currentURL = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if([_currentURL hasPrefix:@"http://"])
    {
        NSString* filePath = [[MTImageCache shareInstance] filePathWithKey:url];
        if (filePath)
        {
            _currentURL = [filePath copy];
        }
    }
    if ([_currentURL hasPrefix:@"file://"])
    {
        _currentURL = [_currentURL substringFromIndex:7];
    }
    
    if (_currentURL)
    {
        QLPreviewPanel *prePanel = [QLPreviewPanel sharedPreviewPanel];
        [prePanel setBecomesKeyOnlyIfNeeded:YES];
        if (prePanel) {
            [prePanel makeKeyAndOrderFront:nil];
        }
    }
}

- (void)x_chatWithUserID:(NSString*)userID
{
    [[DDMainWindowController instance] openUserChatWithUser:userID];
}

- (void)x_previewUserInfoWithUserID:(NSString*)userID
{
    MTUserEntity* user = (MTUserEntity*)[[MTUserModule shareInstance] getOriginEntityWithOriginID:userID];
    [[DDUserInfoManager instance] showUser:user forContext:nil];
}

- (void)x_updateMessageForMessageID:(NSUInteger)messageID state:(MTMessageSendState)state
{
    //更新消息发送状态
    [[_webView windowScriptObject] callWebScriptMethod:@"updateStatus" withArguments:@[@(messageID),@(state)]];
}

- (void)x_openURL:(NSString*)url
{
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL* theUrl = [NSURL URLWithString:url];
    [[NSWorkspace sharedWorkspace] openURL:theUrl];
}

//---------------------------------------------------------------------
- (void)p_receiveMessageNotification:(NSNotification*)notification
{
    MTMessageEntity* message = [notification object];
    if ([message.sessionID isEqualToString:[MTSessionModule shareInstance].currentChatingSessionID])
    {
        [self p_addMessagesOnWebView:@[message] top:NO];
        if ([[NSApplication sharedApplication] isActive]) {
            //发送已读确认
            [[MTSessionModule shareInstance] sendSessionReadACK:message.sessionID];
            //清除未读计数
            [[MTMessageModule shareInstance] clearUnreadMessagesForSessionID:message.sessionID];
        }
    }
}
@end
