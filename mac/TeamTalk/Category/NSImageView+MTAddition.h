//
//  NSImageView+MTAddition.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/24.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImageView (MTAddition)
- (void)setImageWithURL:(NSString*)url placeholderImage:(NSString*)placeholder;
@end
