//
//  MGJMTalkIMessageHanlder.h
//  mtalk
//
//  Created by maye on 13-10-17.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataInputStream.h"
@protocol MGJMTalkIMessageHanlder <NSObject>

@required
//function handleMessage(commandId:int, bodyData:ByteArray):void;
/***************delete by kuaidao 移植到DDlogic框架**********************************/
//-(id)handleMessage:(NSString *)commandId data:(DataInputStream *)bodyData delegate:(id<MGJMTalkIEvents>)delegate;

//add by kuaidao 协议解包处理接口函数,commandId改为短整型
@required
-(id)unpackProtocol:(uint16)commandId data:(DataInputStream *)bodyData;

@end
