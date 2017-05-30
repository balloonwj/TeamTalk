//
//  EmotionViewController.h
//  Duoduo
//
//  Created by jianqing.du on 14-1-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EmotionCellView.h"

@protocol EmotionViewControllerDelegate <NSObject>

- (void)emotionViewController:(EmotionViewController*)emotionViewCOntroller selectEmotionFile:(NSString*)emotionFile;

@end

@class DDChattingViewController;

@interface EmotionViewController : NSViewController<NSTabViewDelegate, NSTableViewDataSource, NSTableViewDelegate,EmotionCellViewDelegate>

@property (nonatomic, weak) IBOutlet NSTabView *emotionTabView;
@property (nonatomic,strong) IBOutlet NSTableView *yayaTableView;
@property(nonatomic,weak)IBOutlet NSTextField *emotionPreviewBG;
@property(nonatomic,weak)IBOutlet NSImageView *emotionPreview;
@property(nonatomic,weak)id<EmotionViewControllerDelegate> delegate;


// input: @"[呵呵]" output: @"0.gif"
- (NSString *)getFileFrom:(NSString *)text;

// input: @"0.gif" output: @"[呵呵]"
- (NSString *)getTextFrom:(NSString *)file;

@end
