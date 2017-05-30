//
//  MTScreenCaptureModule.h
//  Duoduo
//
//  Created by zuoye on 15/1/15.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MTScreenCaptureModule : NSObject

+(instancetype) shareInstance;
- (void)capture:(id)sender;

@end
