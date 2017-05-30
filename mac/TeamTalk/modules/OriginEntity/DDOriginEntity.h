//
//  DDOriginEntity.h
//  Duoduo
//
//  Created by 独嘉 on 15/1/11.
//  Copyright (c) 2015年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDOriginEntity : NSObject
{
    NSString* _ID;
    NSString* _name;
    NSString* _avatar;
}
@property(nonatomic,retain,readonly)NSString* ID;
@property(nonatomic,retain,readonly)NSString* name;
@property(nonatomic,retain)NSString* avatar;
@end
