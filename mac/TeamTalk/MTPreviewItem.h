//
//  MTPreviewItem.h
//  Duoduo
//
//  Created by 独嘉 on 15/2/2.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
@interface MTPreviewItem : NSObject<QLPreviewItem>

- (instancetype)initWithItemURL:(id)url title:(NSString*)title;

@end
