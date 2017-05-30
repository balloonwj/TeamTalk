//
//  EmotionCellView.h
//  Duoduo
//
//  Created by jianqing.du on 14-1-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EmotionCellView;
@protocol EmotionCellViewDelegate <NSObject>

- (void)selectEmotion:(EmotionCellView*)emotionCellView;
- (void)mouseEnterEmotion:(EmotionCellView*)emotionCellView;
- (void)mouseExitEmotion:(EmotionCellView*)emotionCellView;
@end

@class EmotionViewController;
@interface EmotionCellView : NSTableCellView {
    NSString *emotionFile;
}
@property(nonatomic,assign)NSInteger colTag;
@property(nonatomic,strong) NSString *emotionFile;
@property(nonatomic,weak)id<EmotionCellViewDelegate> delegate;
@end
