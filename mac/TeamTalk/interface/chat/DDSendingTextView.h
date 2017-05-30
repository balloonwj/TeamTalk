//
//  DDSendingTextView.h
//  Duoduo
//
//  Created by zuoye on 13-12-4.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDSendingTextView : NSTextView{
    BOOL			nextIsReturn;
	BOOL			nextIsEnter;
    BOOL			optionPressedWithNext;
    BOOL			sendingEnabled;
    id				target;
	SEL			selector;

}

@property (readwrite, nonatomic) BOOL sendingEnabled;


- (IBAction)sendContent:(id)sender;
- (void)setTarget:(id)inTarget action:(SEL)inSelector;
//-(void)paste:(id)sender;
@end
