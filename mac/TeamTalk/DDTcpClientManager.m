//
//  DDTcpClientManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-12.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDTcpClientManager.h"
#import "NSStream+NSStreamAddition.h"
#import "SendBuffer.h"
#import "TcpProtocolHeader.h"
#import "DataInputStream.h"

#import "DDAPISchedule.h"

@interface DDTcpClientManager(PrivateAPI)

- (void)p_handleConntectOpenCompletedStream:(NSStream *)aStream;
- (void)p_handleEventErrorOccurredStream:(NSStream *)aStream;
- (void)p_handleEventEndEncounteredStream:(NSStream *)aStream;
- (void)p_handleEventHasBytesAvailableStream:(NSStream *)aStream;
- (void)p_handleEventHasSpaceAvailableStream:(NSStream *)aStream;
@end

@implementation DDTcpClientManager
+ (instancetype)instance
{
    static DDTcpClientManager* g_tcpClientManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_tcpClientManager = [[DDTcpClientManager alloc] init];
    });
    return g_tcpClientManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[DDClientState shareInstance] addObserver:self
                                        forKeyPath:DD_USER_STATE_KEYPATH
                                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                           context:nil];
    }
    return self;
}

#pragma mark - PublicAPI
-(void)connect:(NSString *)ipAdr port:(NSInteger)port status:(NSInteger)status
{
    DDLog(@"mogujie mtalk client :connect ipAdr:%@ port:%ld",ipAdr,(long)port);
    cDataLen = 0;
    
    _receiveBuffer = [NSMutableData data];
    _sendBuffers = [NSMutableArray array];
    _noDataSent = NO;
    
    _receiveLock = [[NSLock alloc] init];
    _sendLock = [[NSLock alloc] init];
    
    NSInputStream  *tempInput  = nil;
    NSOutputStream *tempOutput = nil;
    
    [NSStream getStreamsToHostNamed:ipAdr port:port inputStream:&tempInput outputStream:&tempOutput];
    _inStream  = tempInput;
    _outStream = tempOutput;
    
    [_inStream setDelegate:self];
    [_outStream setDelegate:self];
    
    [_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inStream open];
    [_outStream open];
}

-(void)disconnect
{
    DDLog(@"MTalk Client:disconnect");
    
    cDataLen = 0;
    
	_receiveLock = nil;
	_sendLock = nil;
    
    [_inStream close];
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	_inStream = nil;
    
	[_outStream close];
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	_outStream = nil;
    
	_receiveBuffer = nil;
	_sendBuffers = nil;
	_lastSendBuffer = nil;
    
    [NotificationHelp postNotification:notificationTcpLinkDisconnect userInfo:nil object:nil];

}

-(void)writeToSocket:(NSMutableData *)data{
    [_sendLock lock];
    @try {
        if (_noDataSent ==YES) {
            
            NSInteger len;
            len = [_outStream write:[data mutableBytes] maxLength:[data length]];
            _noDataSent = NO;
           // DDLog(@"WRITE - Written directly to outStream len:%li", len);
            if (len < [data length]) {
//DDLog(@"WRITE - Creating a new buffer for remaining data len:%li", [data length] - len);
                _lastSendBuffer = [SendBuffer dataWithNSData:[data subdataWithRange:NSMakeRange([data length]-len, [data length])]];
                [_sendBuffers addObject:_lastSendBuffer];
                
            }
            return;
        }
        
        if (_lastSendBuffer) {
            NSInteger lastSendBufferLength;
            NSInteger newDataLength;
            lastSendBufferLength = [_lastSendBuffer length];
            newDataLength = [data length];
            if (lastSendBufferLength<1024) {
                DDLog(@"WRITE - Have a buffer with enough space, appending data to it");
                [_lastSendBuffer appendData:data];
                return;
            }
        }
        //DDLog(@"WRITE - Creating a new buffer");
        _lastSendBuffer = [SendBuffer dataWithNSData:data];
        [_sendBuffers addObject:_lastSendBuffer];
        
    }
    @catch (NSException *exception) {
        DDLog(@" ***** NSException:%@ in writeToSocket of MGJMTalkClient *****",exception);
    }
    @finally {
        [_sendLock unlock];
    }
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH])
    {
        switch ([DDClientState shareInstance].userState)
        {
            case DDUserKickout:
            case DDUserKickByMobile:
            case DDUserOffLineInitiative:
                [self disconnect];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - NSStream Delegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventNone:
			//DDLog(@"Event type: EventNone");
			break;
        case NSStreamEventOpenCompleted:
			[self p_handleConntectOpenCompletedStream:aStream];
			break;
		case NSStreamEventHasSpaceAvailable:          //发送数据
			//DDLog(@"Event type: EventHasSpaceAvailable");
            [self p_handleEventHasSpaceAvailableStream:aStream];
            break;
		case NSStreamEventErrorOccurred:
			//DDLog(@"Event type: EventErrorOccured");
			[self p_handleEventErrorOccurredStream:aStream];
			break;
		case NSStreamEventEndEncountered:
			//DDLog(@"Event type: EventEndOccured");
			[self p_handleEventEndEncounteredStream:aStream];
			break;
        case NSStreamEventHasBytesAvailable:
			//DDLog(@"Event type: EventHasBytesAvailable");
            [self p_handleEventHasBytesAvailableStream:aStream];
            break;
    }
}

#pragma mark - PrivateAPI
- (void)p_handleConntectOpenCompletedStream:(NSStream *)aStream
{
    if (aStream == _outStream) {
        [NotificationHelp postNotification:notificationTcpLinkConnectComplete userInfo:nil object:nil];
    }
}

- (void)p_handleEventHasSpaceAvailableStream:(NSStream *)aStream
{
    [_sendLock lock];
    
    @try {
        
        if (![_sendBuffers count]) {
            DDLog(@"WRITE - No data to send");
            _noDataSent = YES;
            
            return;
        }
        
        SendBuffer *sendBuffer = [_sendBuffers objectAtIndex:0];
        
        NSInteger sendBufferLength = [sendBuffer length];
        
        if (!sendBufferLength) {
            if (sendBuffer == _lastSendBuffer) {
                _lastSendBuffer = nil;
            }
            
            [_sendBuffers removeObjectAtIndex:0];
            
            //DDLog(@"WRITE - No data to send");
            
            _noDataSent = YES;
            
            return;
        }
        
        NSInteger len = ((sendBufferLength - [sendBuffer sendPos] >= 1024) ? 1024 : (sendBufferLength - [sendBuffer sendPos]));
        if (!len) {
            if (sendBuffer == _lastSendBuffer) {
                _lastSendBuffer = nil;
            }
            
            [_sendBuffers removeObjectAtIndex:0];
            
           // DDLog(@"WRITE - No data to send");
            
            _noDataSent = YES;
            
            return;
        }
        
        //			DDLog(@"write %ld bytes", len);
        len = [_outStream write:((const uint8_t *)[sendBuffer mutableBytes] + [sendBuffer sendPos]) maxLength:len];
       // DDLog(@"WRITE - Written directly to outStream len:%lid", (long)len);
        [sendBuffer consumeData:len];
        
        if (![sendBuffer length]) {
            if (sendBuffer == _lastSendBuffer) {
                _lastSendBuffer = nil;
            }
            
            [_sendBuffers removeObjectAtIndex:0];
        }
        
        _noDataSent = NO;
        
        
        return;
    }
    @catch (NSException *exception) {
        DDLog(@" ***** NSException in MGJMTalkCleint :%@  ******* ",exception);
    }
    @finally {
        [_sendLock unlock];
    }
}

- (void)p_handleEventErrorOccurredStream:(NSStream *)aStream
{
    DDLog(@"handle eventErrorOccurred");
}

- (void)p_handleEventEndEncounteredStream:(NSStream *)aStream
{
    DDLog(@"handle eventEndEncountered");
    cDataLen = 0;

}

- (void)p_handleEventHasBytesAvailableStream:(NSStream *)aStream
{
    uint8_t buf[1024];
    NSInteger len = 0;
    len = [(NSInputStream *)aStream read:buf maxLength:1024];
    if (len < 0) {
        [self disconnect];
        return;
    }
    
    if (len > 0) {
        
        //  DataInputStream *dataIn = [DataInputStream dataInputStreamWithData:<#(NSData *)#>
        [_receiveLock lock];
        [_receiveBuffer appendBytes:(const void *)buf length:len];
        
        while ([_receiveBuffer length] >= IM_PDU_HEADER_LEN) {
            NSRange range = NSMakeRange(0, IM_PDU_HEADER_LEN);
//            [[DDAPISchedule instance] receiveServerData:_receiveBuffer];

            NSData *headerData = [_receiveBuffer subdataWithRange:range];
    
            DataInputStream *inputData = [DataInputStream dataInputStreamWithData:headerData];
            
            uint32_t pduLen = [inputData readInt];
            if (pduLen > (uint32_t)[_receiveBuffer length]) {
                break;
            }
            
            TcpProtocolHeader* tcpHeader = [[TcpProtocolHeader alloc] init];
            tcpHeader.version = [inputData readShort];
            tcpHeader.flag = [inputData readShort];
            tcpHeader.serviceId = [inputData readShort];
            tcpHeader.commandId = [inputData readShort];
            tcpHeader.reserved = [inputData readShort];
            tcpHeader.error = [inputData readShort];
        
//            DDLog(@"receive a packet serviceId=%d, commandId=%d", tcpHeader.serviceId, tcpHeader.commandId);
            
            range = NSMakeRange(IM_PDU_HEADER_LEN, pduLen - IM_PDU_HEADER_LEN);
            NSData *payloadData = [_receiveBuffer subdataWithRange:range];
            
            
            
            //
            uint32_t remainLen = (int)[_receiveBuffer length] - pduLen;
            range = NSMakeRange(pduLen, remainLen);
            NSData *remainData = [_receiveBuffer subdataWithRange:range];
            [_receiveBuffer setData:remainData];
            ServerDataType dataType = DDMakeServerDataType(tcpHeader.serviceId, tcpHeader.commandId, tcpHeader.reserved);
            [[DDAPISchedule instance] receiveServerData:payloadData forDataType:dataType];
            
//            }
//            DataInputStream *payloadInputData = [DataInputStream dataInputStreamWithData:payloadData];
//            
//            // 先更新_receiveBuffer, 在处理数据包
//            uint32_t remainLen = (int)[_receiveBuffer length] - pduLen;
//            range = NSMakeRange(pduLen, remainLen);
//            NSData *remainData = [_receiveBuffer subdataWithRange:range];
//            [_receiveBuffer setData:remainData];
//            DDDispatchTask* task = [[DDDispatchTask alloc] initDispatchTask:tcpHeader body:payloadInputData];
//            [[DDLogic instance] pushTask:task delegate:nil];
            
            //收到心跳
            [NotificationHelp postNotification:notificationServerHeartBeat userInfo:nil object:nil];
            
        }
        
        [_receiveLock unlock];
    }
    else {
        DDLog(@"No buffer!");
    }

}
@end
