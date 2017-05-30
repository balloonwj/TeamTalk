//
//  MessageShowView.h
//  ScrollViewChatDemo
//
//  Created by 独嘉 on 14-3-17.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PullToRefreshScrollView.h"
#import "DDMessageTextView.h"


typedef NS_ENUM(NSInteger, UserOperation){
    Chat,
    View
};

typedef NS_ENUM(NSInteger, ChatType)
{
    Group,
    User
};

@class MessageShowView;
@protocol MessageShowViewDelegate <NSObject>

- (void)touchToRefresh;
- (void)messageShowView:(MessageShowView*)messageView selectTheUserID:(NSString*)userID forOperation:(UserOperation)operation;

@end

@interface MessageShowView : PullToRefreshScrollView<DDMessageTextViewDelegate>
@property (nonatomic,readonly)CGFloat bottom;
@property (nonatomic,retain)NSMenu* userOperationMenu;
@property (nonatomic,strong)IBOutlet NSButton *showNewMsgBtn;
//@property (nonatomic,strong)NSProgressIndicator* progressIndicator;
@property (nonatomic,strong)NSButton* loadHistoryButton;
@property (nonatomic,assign)id<MessageShowViewDelegate>loadDelegate;
@property (nonatomic,assign)ChatType type;
/**
 *  在尾部添加新会话
 *
 *  @param view 会话视图
 *  @param left 释放靠左
 *  @param name 会话用户名（用户名为@””时不显示）
 *  @param time 会话时间（时间为@””时不显示）
 */
- (void)addMessageViewOnTail:(NSView*)view atLeft:(BOOL)left name:(NSString*)name time:(NSString*)time forceScroll:(BOOL)scroll userID:(NSString*)userID;
-(void)needShowNewMsgBtn:(BOOL)isNeed;


/**
 *  在顶部添加新会话集
 *
 *  @param views 会话视图集
 *  @param lefts 靠左
 *  @param names 名字
 *  @param times 时间
 */
- (void)addMessageViewOnHead:(NSArray*)views atLefts:(NSArray*)lefts names:(NSArray*)names times:(NSArray*)times userIDs:(NSArray*)userIDs;

/**
 *  添加提示信息，比如下线会发送失败之类
 *
 *  @param content 提示内容
 */
- (void)addHintWithContent:(NSString*)content;

/**
 *  滚动到文档底部
 */
- (void)scrollToDocumentEnd;

/**
 *  加载历史消息完成
 */
- (void)loadMessageFinishForCount:(NSInteger)count;

/**
 *  当前是否在文档底部
 */
-(BOOL)isScrollBottom;
-(IBAction)goToBottom:(id)sender;
@end
