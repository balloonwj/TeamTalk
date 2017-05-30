//
//  MTChattingInputView.m
//  Duoduo
//
//  Created by zuoye on 15/1/23.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTChattingInputView.h"

@implementation MTChattingInputView{
    BOOL isAt;
}



-(void)awakeFromNib{
    isAt=YES;
    [self setAllowsUndo:YES];
}


-(void)keyDown:(NSEvent *)theEvent{
    if (isAt &&  [[theEvent characters] isEqualToString:@"@"]) {
         NSLog(@"可以@出一个人");
    }
    if([[theEvent characters] isEqualToString:@" "]){
        isAt= YES;
    }else{
        isAt=NO;
    }
    [super keyDown:theEvent];
}


#pragma tableview delegate


@end
