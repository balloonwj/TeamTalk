//
//  DrawView.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WhiteBackgroundView.h"

@protocol DrawViewDelegate;
@interface DrawView : WhiteBackgroundView<NSDraggingDestination>

@property (nonatomic,assign)id<DrawViewDelegate> delegate;
@end

@protocol DrawViewDelegate <NSObject>

- (void)drawFileInTo:(NSString*)file;

@end
