//
//  DDContactListImagePicker.h
//  Duoduo
//
//  Created by maye on 13-11-14.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDImageViewWithImagePicker.h"

@interface DDContactListImagePicker : DDImageViewWithImagePicker{
    BOOL hovered;
    NSTrackingRectTag trackingTag;
    
    NSMenu *imageMenu;
}

@end
