//
//  DDClientState.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-14.
//  Copyright (c) 2014年 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用户状态
 */
typedef NS_ENUM(NSUInteger, DDUserState)
{
    /**
     *  用户在线
     */
    DDUserOnline,
    /**
     *  用户多端登录被挤下线
     */
    DDUserKickout,
    /**
     *  用户被移动端踢出
     */
    DDUserKickByMobile,
    /**
     *  用户离线
     */
    DDUserOffLine,
    /**
     *  用户主动下线
     */
    DDUserOffLineInitiative,
    /**
     *  用户正在连接
     */
    DDUserLogining
};

/**
 *  客户端网络状态
 */
typedef NS_ENUM(NSUInteger, DDNetWorkState)
{
    /**
     *  wifi
     */
    DDNetWorkWifi,
    /**
     *  3G
     */
    DDNetWork3G,
    /**
     *  2G
     */
    DDNetWork2G,
    /**
     *  无网
     */
    DDNetWorkDisconnect
};

/**
 *  Socket 连接状态
 */
typedef NS_ENUM(NSUInteger, DDSocketState)
{
    /**
     *  Socket连接登录服务器
     */
    DDSocketLinkLoginServer,
    /**
     *  Socket连接消息服务器
     */
    DDSocketLinkMessageServer,
    /**
     *  Socket没有连接
     */
    DDSocketDisconnect
};

typedef NS_ENUM(NSUInteger,DDDataState)
{
    
    /**
     *  本地用户数据加载完成
     */
    DDLocalUserDataReady          = 1,

    /**
     *  远程用户数据加载完成
     */
    DDRemoteUserDataReady         = 1 << 1,

    /**
     *  本地群数据加载
     */
    DDLocalGroupDataReady         = 1 << 2,

    /**
     *  远程会话群数据加载完成
     */
    DDRemoteSessionGroupDataReady = 1 << 3,

    /**
     *  远程固定群数据加载完成
     */
    DDRemoteFixGroupDataReady     = 1 << 4,

    /**
     *  本地session数据加载完成
     */
    DDLocalSessionDataReady       = 1 << 5,

    /**
     *  远程session数据加载完成
     */
    DDRemoteSessionDataReady      = 1 << 6,

    /**
     *  在线状态加载完成
     */
    DDOnlineDataReady             = 1 << 7
};

#define DD_USER_STATE_KEYPATH               @"userState"
#define DD_NETWORK_STATE_KEYPATH            @"networkState"
#define DD_SOCKET_STATE_KEYPATH             @"socketState"
#define DD_USER_ID_KEYPATH                  @"userID"
#define DD_DATA_STATE_KEYPATH               @"dataState"

@class DDReachability;
@interface DDClientState : NSObject
{
    DDReachability* _reachability;
}
/**
 *  当前登录用户的状态
 */
@property(nonatomic,assign)DDUserState userState;

/**
 *  网络连接状态
 */
@property(nonatomic,assign)DDNetWorkState networkState;

/**
 *  Socket连接状态
 */
@property(nonatomic,assign)DDSocketState socketState;

/**
 *  当前登录用户的ID
 */
@property (nonatomic,retain)NSString* userID;

/**
 *  程序数据状态
 */
@property (nonatomic,assign)DDDataState dataState;

/**
 *  msfs  文件服务器地址
 */
@property (nonatomic,retain)NSString* msfsURL;

/**
 *  发现 地址
 */
@property (nonatomic,retain)NSString* discoverURL;

/**
 *  单例
 *
 *  @return 客户端状态机
 */
+ (instancetype)shareInstance;

- (void)setUseStateWithoutObserver:(DDUserState)userState;

@end
