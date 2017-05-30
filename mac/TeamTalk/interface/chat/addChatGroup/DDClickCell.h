//
//  DDClickCell.h
//  Duoduo
//
//  Created by zuoye on 14-2-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDClickCell : NSTextFieldCell{
    
}
@property (readwrite,strong) NSImage *clickImage;           //没选中图像?
@property (readwrite,strong) NSImage *alterClickImage;      //checkBox图像
@property (strong) NSColor *bShowHighlightColor;
@property SEL clickAction;
@property SEL clickOtherAreaAction;
@property (assign) BOOL canSelect;
@property int clickType;
@property int cellType;         //type=0 有圆圈 ,type=1 为叉叉
@end
