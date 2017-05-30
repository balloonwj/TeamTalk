//
//  DDChangableAttactment.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@interface DDChangableAttactment : NSTextAttachment<QLPreviewItem>
@property (nonatomic,readonly)NSString* realURL;
- (id)initWithRealURL:(NSString*)sender;

@end
