//
//  FMSearchTokenFieldCell.h
//  Duoduo
//
//  Created by zuoye on 14-1-23.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMSearchTokenFieldCell : NSTokenFieldCell


-(void)divideFrame:(NSRect)frame ToImageRect:(NSRect *)imageFrame textRect:(NSRect*)textFrame buttonRect:(NSRect*)buttonFrame callFromView:(BOOL)callFromView ;

@property (assign) BOOL buttonPressed;
@end
