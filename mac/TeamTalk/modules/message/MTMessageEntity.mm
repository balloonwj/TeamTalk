//
//  MTMessageEntity.m
//  Duoduo
//
//  Created by 独嘉 on 15/1/16.
//  Copyright (c) 2015年 mogujie. All rights reserved.
//

#import "MTMessageEntity.h"
#import "MTSessionEntity.h"
#import "MTMessageModule.h"
#import "EmotionManager.h"
#import "MTImageCache.h"
#import "security.h"
#include <iostream>
#import "DDPathHelp.h"
#include <stdlib.h>
#import "NSString+Additions.h"
@interface MTMessageEntity(PrivateAPI)

- (void)p_analysisMessageContent:(id)messageContent;
- (NSString*)p_analysisTextMessageForWebView:(NSString*)messageContent;
- (NSString*)p_replaceImageURLToLocalImageFilePath:(NSString*)sender;
- (NSString*)p_encodeConteng:(NSString*)messageContent;
- (NSString*)p_getMessageContentFromMsgData:(NSData*)data forMessageServerID:(NSUInteger)serverID sessionID:(NSString*)sessionID;
- (NSString*)p_decorateURL:(NSString*)sender;

@end

@implementation MTMessageEntity
- (instancetype)initWithServerMessageID:(NSUInteger)messageServerID
                             type:(MTMessageType)messageType
                      messageTime:(NSUInteger)messageTime
                        sessionID:(NSString*)sessionID
                         senderID:(NSString*)senderID
                         targetID:(NSString*)targetID
                          content:(id)messageContent
                            state:(MTMessageSendState)state

{
    self = [super init];
    if (self)
    {
        //自增长ID生成
        _messageID = [MTMessageModule getMessageID];
        //
        _messageServerID = messageServerID;
        _messageType = messageType;
        _messageTime = messageTime;
        _sessionID = sessionID;
        _senderID = senderID;
        _targetID = targetID;
        _messageContent = messageContent;
        _sendState = state;
    }
    return self;
}


//收到消息
//收到消息.如果收到的是自己发的消息.
-(instancetype)initWithMessageData:(IMMsgData *)msgRsp
{
    NSUInteger messageServerID = msgRsp.msgId;
    MsgType msgType = msgRsp.msgType;
    NSData* msgData = msgRsp.msgData;
    NSUInteger messageTime = msgRsp.createTime;
    
    //        NSString* myUserID = [DDClientState shareInstance].userID;
    NSString* fromID = [NSString stringWithFormat:@"%i",[msgRsp fromUserId]];
    NSString* toUserID = [NSString stringWithFormat:@"%i",[msgRsp toSessionId]];

     NSString *originID=nil;
    if (msgType==MsgTypeMsgTypeSingleText ||msgType == MsgTypeMsgTypeSingleAudio) {
        if([fromID isEqualToString:[[DDClientState shareInstance] userID] ]){       //自己发的.
            originID = toUserID;
        }else{
             originID = fromID;
        }
       
    }else{
        originID = toUserID;
    }
    
    NSString* sessionID = nil;
    MTMessageType messageType = MessageTypeNormal;
    id messageContent = nil;
    switch (msgType) {
        case MsgTypeMsgTypeGroupAudio:
            sessionID = [MTSessionEntity getSessionIDForOriginID:originID sessionType:SessionTypeSessionTypeGroup];
            messageType = MessageTypeVoice;
            messageContent = [self p_getMessageContentFromMsgData:msgData forMessageServerID:messageServerID sessionID:sessionID];
            break;
            
        case MsgTypeMsgTypeGroupText:
            sessionID = [MTSessionEntity getSessionIDForOriginID:originID sessionType:SessionTypeSessionTypeGroup];
            messageType = MessageTypeNormal;
            messageContent = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
            break;
            
        case MsgTypeMsgTypeSingleAudio:
            sessionID = [MTSessionEntity getSessionIDForOriginID:originID sessionType:SessionTypeSessionTypeSingle];
            messageType = MessageTypeVoice;
            messageContent = [self p_getMessageContentFromMsgData:msgData forMessageServerID:messageServerID sessionID:sessionID];
            break;
            
        case MsgTypeMsgTypeSingleText:
            sessionID = [MTSessionEntity getSessionIDForOriginID:originID sessionType:SessionTypeSessionTypeSingle];
            messageType = MessageTypeNormal;
            messageContent = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
            break;
            
        default:
            break;
    }
    
    if(msgType == MsgTypeMsgTypeSingleAudio||MsgTypeMsgTypeGroupAudio==msgType){
        _messageContent=messageContent;
    }else{
        std::string *strMsg =new std::string([messageContent UTF8String]);
        char* pOut;
        uint32_t nLen=0;
        int nRet = DecryptMsg(strMsg->c_str(), (uint32_t)strMsg->length(), &pOut, nLen);
        if (nRet != 0) {
            printf(" **** 解密错误:code= %d",nRet);
            _messageContent=@"";
        }else{
            _messageContent = [NSString stringWithUTF8String:pOut];
            Free(pOut);
        }
        delete strMsg;
    }

    
    MTMessageEntity* message = [[MTMessageEntity alloc] initWithServerMessageID:messageServerID type:messageType messageTime:messageTime sessionID:sessionID senderID:fromID targetID:toUserID content:_messageContent state:MessageSendSuccess];
    return message;
}

//历史消息
- (instancetype)initWithMesssageInfo:(MsgInfo*)msgInfo withSessionID:(NSString*)sessionID
{
    NSUInteger msgServerID = msgInfo.msgId;
    MsgType msgtype = msgInfo.msgType;
    NSString* senderID = [NSString stringWithFormat:@"%u",(unsigned int)msgInfo.fromSessionId];
    MTMessageType messageType;
    NSString* newSessionID;
    NSString* targetID;
    NSString* messageContent;
    switch (msgtype) {
        case MsgTypeMsgTypeSingleText:
            messageType = MessageTypeNormal;
            newSessionID = [MTSessionEntity getSessionIDForOriginID:sessionID sessionType:SessionTypeSessionTypeSingle];
            if ([sessionID isEqualToString:senderID])
            {
                targetID = [DDClientState shareInstance].userID;
            }
            else
            {
                targetID = sessionID;
            }
            messageContent = [[NSString alloc] initWithData:msgInfo.msgData encoding:NSUTF8StringEncoding];
            break;
        case MsgTypeMsgTypeSingleAudio:
            messageType = MessageTypeVoice;
            newSessionID = [MTSessionEntity getSessionIDForOriginID:sessionID sessionType:SessionTypeSessionTypeSingle];
            if ([sessionID isEqualToString:senderID])
            {
                targetID = [DDClientState shareInstance].userID;
            }
            else
            {
                targetID = sessionID;
            }
            messageContent = [self p_getMessageContentFromMsgData:msgInfo.msgData forMessageServerID:msgServerID sessionID:sessionID];

            break;
        case MsgTypeMsgTypeGroupText:
            messageType = MessageTypeNormal;
            newSessionID = [MTSessionEntity getSessionIDForOriginID:sessionID sessionType:SessionTypeSessionTypeGroup];
            targetID = [sessionID copy];
            messageContent = [[NSString alloc] initWithData:msgInfo.msgData encoding:NSUTF8StringEncoding];
            break;
        case MsgTypeMsgTypeGroupAudio:
            messageType = MessageTypeVoice;
            newSessionID = [MTSessionEntity getSessionIDForOriginID:sessionID sessionType:SessionTypeSessionTypeGroup];
            targetID = [sessionID copy];
            messageContent = [self p_getMessageContentFromMsgData:msgInfo.msgData forMessageServerID:msgServerID sessionID:sessionID];

            break;
        default:
            break;
    }
    NSUInteger messageTime = msgInfo.createTime;

    if(msgtype == MsgTypeMsgTypeSingleAudio||MsgTypeMsgTypeGroupAudio==msgtype){
        _messageContent=messageContent;
    }else{
        std::string *strMsg =new std::string([messageContent UTF8String]);
        char* pOut;
        uint32_t nLen=0;
        int nRet = DecryptMsg(strMsg->c_str(), (uint32_t)strMsg->length(), &pOut, nLen);
        if (nRet != 0) {
            printf(" **** 解密错误:code= %d",nRet);
            _messageContent=@"";
        }else{
            _messageContent = [NSString stringWithUTF8String:pOut];
            Free(pOut);
        }
        delete strMsg;
    }
   
    
    
    
    MTMessageEntity* message = [[MTMessageEntity alloc] initWithServerMessageID:msgServerID type:messageType messageTime:messageTime sessionID:newSessionID senderID:senderID targetID:targetID content:_messageContent state:MessageSendSuccess];
    return message;
}


- (NSString*)getTextMessageContent
{
    return _messageContent;
}

- (BOOL)hasImages
{
    return NO;
}

- (NSString*)toJson
{
    NSString* messageContent = [[NSString alloc] initWithString:_messageContent ? _messageContent : @""];
    if (self.messageType == MessageTypeNormal)
    {
        messageContent = [self p_analysisTextMessageForWebView:messageContent];
    }
    NSDictionary* message = @{@"ID":@(_messageID),
                              @"ServerID":@(_messageServerID),
                              @"MessageType":@(_messageType),
                              @"MessageTime":@(_messageTime),
                              @"SessionID":_sessionID,
                              @"SenderID":_senderID,
                              @"TargetID":_targetID,
                              @"MessageContent":messageContent,
                              @"SendState":@(_sendState)};
    
    NSError* error = nil;
    NSData *historyData = [NSJSONSerialization dataWithJSONObject:message
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
    
    if (!error)
    {
        NSString* json = [[NSString alloc] initWithData:historyData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

- (NSArray*)imageURL
{
    __block NSString* newContent = [_messageContent copy];
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"&\\$#@~\\^@\\[\\{:[\\w|\\W]+?:\\}\\]&\\$~@#@"
                                                                           options:0
                                                                             error:&error];
        NSMutableArray* urls = [[NSMutableArray alloc] init];
    if (!error)
    {
        if (newContent)
        {
            NSArray* match = [regex matchesInString:newContent options:NSMatchingReportProgress range:NSMakeRange(0, [newContent length])];
            [match enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSTextCheckingResult* matchResult = obj;
                NSRange range = [matchResult range];
                
                NSString* matchString = [newContent substringWithRange:range];
                matchString = [matchString stringByReplacingOccurrencesOfString:IMAGE_MARK_START withString:@""];
                matchString = [matchString stringByReplacingOccurrencesOfString:IMAGE_MARK_END withString:@""];
                if ([matchString hasPrefix:@"http://"])
                {
                    [urls addObject:matchString];
                }
            }];
        }
    }
    
    return urls;
}

#pragma mark -
#pragma mark PricateAPI
- (void)p_analysisMessageContent:(id)messageContent
{
    if (_messageType == MessageTypeNormal)
    {
        _messageContent = messageContent;
    }
    else
    {
        //TODO:语音消息
    }
}

- (NSString*)p_analysisTextMessageForWebView:(NSString*)sender
{
    
    __block NSString* messageContent = [self p_encodeConteng:sender];
    messageContent = [self p_replaceImageURLToLocalImageFilePath:messageContent];
    messageContent = [messageContent stringByReplacingOccurrencesOfString:IMAGE_MARK_START withString:@"<img src='"];
    messageContent = [messageContent stringByReplacingOccurrencesOfString:IMAGE_MARK_END withString:@"'>"];
    
    NSString* parten = @"\\[[\\w\\W]*?\\]";
    NSError* error = NULL;
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
    if (!error)
    {
        NSArray* array = [reg matchesInString:messageContent options:NSMatchingReportProgress range:NSMakeRange(0, [messageContent length])];
        if ([array count] > 0)
        {
            NSMutableDictionary* replaceDic = [[NSMutableDictionary alloc] init];
            for (NSInteger index = 0; index < [array count]; index ++)
            {
                NSTextCheckingResult* matchResult = array[index];
                NSRange range = [matchResult range];
                NSString* matchString = [messageContent substringWithRange:range];
                NSString* filePath = [[EmotionManager instance] getFileFrom:matchString];
                if (filePath)
                {
                    NSArray* resolve = [filePath componentsSeparatedByString:@"."];
                    if ([resolve count] == 2)
                    {
                        NSString* emojiPath = [[NSBundle mainBundle] pathForResource:resolve[0] ofType:resolve[1]];
                        NSString* newEmotion = [NSString stringWithFormat:@"<img src='%@'>",emojiPath];
                        
                        [replaceDic setObject:newEmotion forKey:matchString];
                    }
                    else
                    {
                        NSString* newEmotion = [NSString stringWithFormat:@"<img src='%@'>",filePath];
                        [replaceDic setObject:newEmotion forKey:matchString];
                    }
                }
            }
            [replaceDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                messageContent = [messageContent stringByReplacingOccurrencesOfString:key withString:obj];
            }];
        }
    }
    
    //URL 优化
    messageContent = [self p_decorateURL:messageContent];

    
    return messageContent;
}

- (NSString*)p_replaceImageURLToLocalImageFilePath:(NSString*)sender
{
    __block NSString* newContent = [sender copy];
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"&\\$#@~\\^@\\[\\{:[\\w|\\W]+?:\\}\\]&\\$~@#@"
                                                                           options:0
                                                                             error:&error];
    
    NSMutableArray* urls = [[NSMutableArray alloc] init];
    if (!error)
    {
        NSArray* match = [regex matchesInString:sender options:NSMatchingReportProgress range:NSMakeRange(0, [sender length])];
        [match enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSTextCheckingResult* matchResult = obj;
            NSRange range = [matchResult range];
            
            NSString* matchString = [sender substringWithRange:range];
            [urls addObject:matchString];
        }];
    }
    
    [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* url = (NSString*)obj;
        if ([url rangeOfString:@"http://"].length > 0) {
            NSString* clearURL = [url stringByReplacingOccurrencesOfString:IMAGE_MARK_START withString:@""];
            clearURL = [clearURL stringByReplacingOccurrencesOfString:IMAGE_MARK_END withString:@""];
            NSString* filePath = [[MTImageCache shareInstance] filePathWithKey:clearURL];
            if (filePath)
            {
                newContent = [newContent stringByReplacingOccurrencesOfString:clearURL withString:filePath];
            }
        }
        else
        {
            NSString* filePath = [url stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
            newContent = [newContent stringByReplacingOccurrencesOfString:url withString:filePath];
        }
    }];
    return newContent;
}

- (NSString*)p_encodeConteng:(NSString*)messageContent
{
    //html编码
    NSString* newMessageContent = [messageContent stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    newMessageContent = [newMessageContent stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    newMessageContent = [newMessageContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    newMessageContent = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                           (CFStringRef)newMessageContent,
                                                                                           NULL,
                                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                           kCFStringEncodingUTF8));
    newMessageContent = [newMessageContent stringByReplacingOccurrencesOfString:@"%E2%80%A8" withString:@"<br/>"];
    newMessageContent = [newMessageContent stringByReplacingOccurrencesOfString:@"%20" withString:@"&nbsp;"];
    newMessageContent = [newMessageContent stringByReplacingOccurrencesOfString:@"%09" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;"];
    
    newMessageContent = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                           (CFStringRef)newMessageContent,
                                                                                                           CFSTR(""),
                                                                                                           kCFStringEncodingUTF8));
    
    return newMessageContent;
}

- (NSString*)p_getMessageContentFromMsgData:(NSData*)data forMessageServerID:(NSUInteger)serverID sessionID:(NSString*)sessionID
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    if ([data length] > 4)
    {
        NSData* voiceLengthData = [data subdataWithRange:NSMakeRange(0, 4)];
        int8_t ch1;
        [voiceLengthData getBytes:&ch1 range:NSMakeRange(0,1)];
        ch1 = ch1 & 0x0ff;
        
        int8_t ch2;
        [voiceLengthData getBytes:&ch2 range:NSMakeRange(1,1)];
        ch2 = ch2 & 0x0ff;
        
        int32_t ch3;
        [voiceLengthData getBytes:&ch3 range:NSMakeRange(2,1)];
        ch3 = ch3 & 0x0ff;
        
        int32_t ch4;
        [voiceLengthData getBytes:&ch4 range:NSMakeRange(3,1)];
        ch4 = ch4 & 0x0ff;
        
        if ((ch1 | ch2 | ch3 | ch4) < 0){
            @throw [NSException exceptionWithName:@"Exception" reason:@"EOFException" userInfo:nil];
        }
        int voiceLength = ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0));
        voiceLength = voiceLength > 60 ? 0 : voiceLength;
        [dic setObject:@(voiceLength) forKey:@"length"];
    }
    NSData* voiceData = [data subdataWithRange:NSMakeRange(4, [data length] - 4)];
    NSString* fileName = [NSString stringWithFormat:@"%@-%lu",sessionID,serverID];
    NSString* voiceFilePath = [[DDPathHelp voiceCachePath] stringByAppendingPathComponent:fileName];
    NSString* wavFilePath = [voiceFilePath stringByAppendingString:@".wav"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //存文件
        [voiceData writeToFile:voiceFilePath atomically:YES];
        
        //解码
        NSPipe* pipe = [NSPipe pipe];
        NSTask *task = [[NSTask alloc] init];
        NSString* path = [NSString stringWithFormat:@"%@/speexdec",[[NSBundle mainBundle] resourcePath]];
        task.launchPath = path;
        task.arguments = @[voiceFilePath, wavFilePath];
        task.standardOutput = pipe;
        
        [task launch];
    });
    
    [dic setObject:wavFilePath forKey:@"path"];
    NSString* string = [NSString jsonStringFromDic:dic];
    return string;
}

- (NSString*)p_decorateURL:(NSString*)sender
{
    /*
    NSString* string = [sender copy];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    NSString* parten = @"((?:(http|https|Http|Https|rtsp|Rtsp):\\/\\/(?:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,64}(?:\\:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,25})?\\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}\\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\\:\\d{1,5})?)(\\/(?:(?:[a-zA-Z0-9\\;\\/\\?\\:\\@\\&\\=\\#\\~\\-\\.\\+\\!\\*\\'\\(\\)\\,\\_])|(?:\\%[a-fA-F0-9]{2}))*)?(?:\\b|$)";
    NSError* error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
    NSMutableArray* urls = [[NSMutableArray alloc] init];
    if (!error)
    {
        NSArray* match = [reg matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
        [match enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSTextCheckingResult* matchResult = obj;
            NSRange range = [matchResult range];
            
            NSString* matchString = [string substringWithRange:range];
            if (![urls containsObject:matchString])
            {
                [urls addObject:matchString];
            }
        }];
    }
    
    __block NSString* messageContent = [sender copy];
    [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        //<a data-href="' + httpText + '" class="open_link" style="color:#0085e4;cursor:pointer;">' + httpText + '</a>
        NSString* newURLString = [NSString stringWithFormat:@"<a data-href=\"%@\" class=\"open_link\" style=\"color:#0085e4;cursor:pointer;\">%@</a>",obj,obj];
        messageContent = [messageContent stringByReplacingOccurrencesOfString:obj withString:newURLString];
    }];
    return messageContent;
     */
    return sender;
}

@end
