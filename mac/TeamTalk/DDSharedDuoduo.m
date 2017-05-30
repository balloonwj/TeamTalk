//
//  DDSharedDuoduo.m
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

id<DDDuoduoProtocol> duoduo = nil;

void setSharedDuoduo(id<DDDuoduoProtocol> shared){
    NSCAssert(duoduo == nil, @"Attempt to set the shared duoduo instance after it's already been set");
    NSCParameterAssert(shared != nil);
    duoduo = shared;
}
