/************************************************************
 * @file         FileTansferEntity.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       文件传输参数
 ************************************************************/

#import <Foundation/Foundation.h>

@interface FileTransferEntity : NSObject

@property(nonatomic,strong)NSString* fromUserId;
@property(nonatomic,strong)NSString* toUserId;
@property(nonatomic,strong)NSString* fileName;
@property(nonatomic,strong)NSString* savePath;
@property(nonatomic,strong)NSString* listenIp;
@property(nonatomic,assign)uint16 listenPort;
@property(nonatomic,assign)uint32 fileSize;
@property(nonatomic,assign)uint32 acceptFlag;

@end
