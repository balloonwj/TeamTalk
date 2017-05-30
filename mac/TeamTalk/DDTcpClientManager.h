//
//  DDTcpClientManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SendBuffer;
@interface DDTcpClientManager : NSObject<NSStreamDelegate>
{
@private
    NSInputStream *_inStream;
    NSOutputStream *_outStream;
    NSLock *_receiveLock;
	NSMutableData *_receiveBuffer;
    NSLock *_sendLock;
	NSMutableArray *_sendBuffers;
	SendBuffer *_lastSendBuffer;
	BOOL _noDataSent;
    int32_t cDataLen;

}

+ (instancetype)instance;

-(void)connect:(NSString *)ipAdr port:(NSInteger)port status:(NSInteger)status;
-(void)disconnect;
-(void)writeToSocket:(NSMutableData *)data;


@end
