//
//  DDSearchFieldResultCell.h
//  Duoduo
//
//  Created by 独嘉 on 14-2-19.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDSearchFieldResultCell : NSTableCellView
{
    __weak IBOutlet EGOImageView* _imageCell;
    __weak IBOutlet NSTextField* _nameTextField;
    IBOutlet NSTextField* _subTitleTextField;
}

- (void)setImageURL:(NSURL*)url;
- (void)setName:(NSString*)name;
@end
