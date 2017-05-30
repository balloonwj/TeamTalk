//
//  DDChattingViewModule.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DDChattingViewModuleDataSource<NSObject>

- (NSAttributedString*)getCurrentAttribute;

@end
@class MTSessionEntity,MessageEntity;
@interface DDChattingViewModule : NSObject<EGOImageViewDelegate>
@property (nonatomic,readonly)MTSessionEntity* session;
@property (nonatomic,assign)NSUInteger firstMessageID;
@property (nonatomic,assign)NSUInteger inputHistoryMessageIndex;
@property (nonatomic,assign)id<DDChattingViewModuleDataSource> dataSource;
@property (nonatomic,assign)BOOL loadingHistoryMessage;
@property (nonatomic,assign)BOOL firstTimeToLoadMessage;
- (id)initWithSession:(MTSessionEntity*)session;


- (NSAttributedString*)getAttributedStringFromInputContent:(NSAttributedString*)inputContent compress:(BOOL)compress;

/**
 *  获取上一条输入框的历史消息
 *
 *  @return 消息内容
 */
- (NSAttributedString*)getLastInputHistoryMessages;

/**
 *  获取下一条输入框的历史消息
 *
 *  @return 消息内容
 */
- (NSAttributedString*)getNextInputHistoryMessages;

@end
