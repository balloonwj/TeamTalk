//
//  DDImageMessage.h
//  Duoduo
//
//  Created by zuoye on 14-1-13.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDImageMessage : NSObject{
    NSMutableString *textMsg;
    NSMutableDictionary *imagesUrl;
    NSInteger imageCount;
}

@property (readonly) NSMutableDictionary *imagesUrl;
@property (strong) NSMutableString *textMsg;
@property NSInteger imageCount;

-(NSString *)getSendMessage;
@end
