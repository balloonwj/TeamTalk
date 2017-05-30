//
//  DDIntranetMessageEntity.h
//  Duoduo
//
//  Created by 独嘉 on 14-7-2.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDIntranetMessageEntity : NSObject
@property (nonatomic,readonly)NSString* author;
@property (nonatomic,readonly)NSString* content;
@property (nonatomic,readonly)NSUInteger time;
@property (nonatomic,readonly)NSString* fromUserID;

- (id)initWithAuthor:(NSString*)author content:(NSString*)content time:(NSUInteger)time fromUserID:(NSString*)fromUserID;
@end
