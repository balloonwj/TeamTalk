/************************************************************
 * @file         TcpProtocolHeader.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       tcp服务器协议头，包括每个service下的command Id定义
 *
 packet data unit header format:
 length     -- 4 byte
 version    -- 2 byte
 flag       -- 2 byte
 service_id -- 2 byte
 command_id -- 2 byte
 error      -- 2 byte
 reserved   -- 2 byte
 ************************************************************/

#import <Foundation/Foundation.h>
#import <stdint.h>
static const int16_t MODULE_ID_REMOTEBASE = 0x0000U; //与服务器端交互的module id
static const int16_t MODULE_ID_LOCALBASE = 0x4000U;  //本地业务的module id
//SID
enum
{
    DDSERVICE_LOGIN                 = 0x0001,            //登录相关
    MODULE_ID_SESSION               = 0x0002,          //Session相关
    DDSERVICE_MESSAGE               = 0x0003,           //消息相关
    SERVICE_GROUP                   = 0x0004,               //群相关
    DDSERVICE_OTHER                 = 0x0007            //其他
};

//session

enum{
    RECENT_SESSION_REQ              =   0x0201,    //最近会话请求
    RECENT_SESSION_RES              =   0x0202,     //最近会话返回
    REMOVE_SESSION_REQ              =   0x0206,     //删除最近会话请求
    REMOVE_SESSION_RES              =   0x0207,     //返回删除最近会话请求    
};

enum
{
    MODULE_ID_NONE              = 0,
    
    //与服务器端交互的module id
    MODULE_ID_LOGIN             = MODULE_ID_REMOTEBASE | 0x0002,    //登陆模块

    MODULE_ID_MESSAGE           = MODULE_ID_REMOTEBASE | 0x0004,    //消息管理模块
    MODULE_ID_HTTP              = MODULE_ID_REMOTEBASE | 0x0005,    //HTTP模块
    MODULE_ID_TCPLINK           = MODULE_ID_REMOTEBASE | 0x0006,    //TCP长连接模块
    MODULE_ID_MAIN              = MODULE_ID_REMOTEBASE | 0x0007,    //主窗口模块i
    //  MODULE_ID_SESSION           = MODULE_ID_REMOTEBASE | 0x0050,    //会话模块
     MODULE_ID_GROUP             = MODULE_ID_REMOTEBASE | 0x0052,    // group module
    MODULE_ID_CAPTURE           = MODULE_ID_LOCALBASE   | 0x001,      //截屏模块
    MODULE_ID_P2P               = MODULE_ID_REMOTEBASE | 0x0051,    //P2P
    
    MODULE_ID_COMMON            = MODULE_ID_LOCALBASE | 0X002,        //多多公共函数库
    MODULE_ID_FILETRANSFER      = MODULE_ID_REMOTEBASE | 0x005A,
};

// 其他
enum
{
    CMD_OTHER_HEART_BEAT_REQ                       =0x0701,
};

//MODULE_ID_LOGIN = 1   登陆相关
enum
{
    CMD_LOGIN_REQ_MSGSERVER                     = 1,                //获取消息服务器信息接口请求
    CMD_LOGIN_RES_MSGSERVER                     = 2,                //返回一个消息服务器的IP和端口
    CMD_LOGIN_REQ_USERLOGIN                     = 0x0103,                //用户登录请求
    CMD_LOGIN_RES_USERLOGIN                     = 0x0104,                //登陆消息服务器验证结果
    CMD_LOGIN_RES_USERLOGOUT                    = 6,                //这个目前不用实现
    CMD_LOGIN_KICK_USER                         = 7,                //踢出用户提示.
    CMD_PUSH_TOKEN_REQ                            = 0x0108,           // 发送token
    CMD_PUSH_TOKEN_RES                            = 0x0109,           // 收到token
};

//MODULE_ID_FRIENDLIST = 3 成员列表相关
enum
{
    CMD_FRI_REQ_RECENT_LIST         = 1,                //获取最近联系人请求
    CMD_FRI_SERVICE_LIST            = 2,                //店铺客服列表
    CMD_FRI_RECENT_CONTACTS         = 3,                //最近联系人列表
    CMD_FRI_USERLIST_ONLINE_STATE   = 4,                //在线好友状态列表
    CMD_FRI_USER_STATE_CHANGE       = 5,                //好友状态更新通知
    CMD_FRI_ADD_NEW_BUSINESS_USER   = 7,                //分配客服的回复
    CMD_FRI_GET_USER_ONLINE_STATE   = 9,                //返回某个用户的在线状态
    CMD_FRI_USER_INFO_LIST          = 10,               //返回用户信息列表
    CMD_FRI_USER_INFO_LIST_REQ      = 11,               //用户信息列表请求
    CMD_FRI_REMOVE_SESSION_REQ      = 12,               //移除会话请求
    CMD_FRI_REMOVE_SESSION_RES      = 13,               //移除会话返回
    CMD_FRI_ALL_USER_REQ            = 0x0208,               // 获取公司全部员工信息
    CMD_FRI_ALL_USER_RES            = 0x0209,
    CMD_FRI_LIST_STATE_REQ          = 0x020a,               //批量获取用户在线状态
    CMD_FRI_LIST_STATE_RES          = 0x020b,               //批量返回用户在线状态
    CMD_FRI_LIST_DETAIL_INFO_REQ    = 0x0204,               //批量获取用户详细资料
    CMD_FRI_LIST_DETAIL_INFO_RES    = 0x0205,               //批量放回用户详细资料
    CMD_FRI_LIST_DEPARTMENT_REQ     = 0x0210,           //获取组织架构
    CMD_FRI_LIST_DEPARTMENT_RES     = 0x0211,           //获取组织架构返回
    CMD_FRI_MODIFY_USER_AVATAR_REQ  = 20,               //修改用户头像
    CMD_FRI_MODIFY_USER_AVATAR_RES  = 21,                //修改用户头像返回
};

//MODULE_ID_SESSION = 80 消息会话相关
enum
{
    CMD_MSG_DATA                   = 0x0301,//收到聊天消息
    CMD_MSG_DATA_ACK               = 0x0302,//消息收到确认.  这是收
    CMD_MSG_READ_ACK               = 0x0303,//消息已读确认
    CID_MSG_READ_NOTIFY            = 4,//消息已读通知
    CMD_MSG_UNREAD_CNT_REQ         = 0x0307,//请求未读消息计数
    CMD_MSG_UNREAD_CNT_RES         = 0x0308,//返回自己的未读消息计数
    CMD_MSG_UNREAD_MSG_REQ         = 9,//请求两人之间的未读消息
    CMD_MSG_HISTORY_MSG_REQ        = 10,//请求两人之间的历史消息
    CID_MSG_LIST_REQUEST           = 0x0309,//获取消息队列请求
    CID_MSG_LIST_RESPONSE          = 0x030a,//返回消息队列请求
    CMD_MSG_GET_2_UNREAD_MSG       = 14,//返回两人之间的未读消息
    CMD_MSG_GET_2_HISTORY_MSG      = 15,//查询两人之间的历史消息
    MSG_MSG_READ_NOTIFY            = 0x0304,//消息被读掉通知
    CMD_MSG_GET_LASTEST_MSG_ID_REQ = 0x030b,//获取最后一条消息ID
    CMD_MSG_GET_LASTEST_MSG_ID_RES = 0x030c
    
};

//MODULE_ID_FILETRANSFER = 90 文件传输相关
//MODULE_ID_SESSION = 80 消息会话相关
enum
{
    // to/from FileServer
    CMD_FILE_LOGIN_REQ              = 1,    // 登录FileServer请求
    CMD_FILE_LOGIN_RES              = 2,    // 登录FileServer回复
    CMD_FILE_DATA                   = 3,    // 文件数据，切分成4KB的数据包
    CMD_FILE_UPLOAD_OFFLINE_FINISH	= 4,	// 完成离线文件上传
    CMD_FILE_GET_OFFLINE_REQ		= 5,	// 获取离线文件请求
    
    // to/from MsgServer
    CMD_FILE_REQUEST                = 10,   // 文件传输请求
    CMD_FILE_RESPONSE               = 11,   // 对方接受或拒绝文件传输
    CMD_FILE_RECV_READY             = 12,   // 对方已经连接到FileServer，准备好接受文件
    CMD_FILE_ABORT                  = 13,   // 放弃文件传输
    CMD_FILE_UPLOAD_OFFLINE_NOTIFY  = 14,   // 发送方通知对方上传离线文件
    CMD_FILE_DOWNLOAD_OFFLINE_NOTIFY = 15,  // 发送发通知对方离线文件上传完成，可以下载
    CMD_FILE_HAS_OFFLINE_REQ		= 16,   // 用户登录时查询是否有离线文件
    CMD_FILE_HAS_OFFLINE_RES		= 17,   // 返回是否有离线文件
    CMD_FILE_ADD_OFFLINE_REQ        = 18,
    CMD_FILE_DEL_OFFLINE_REQ        = 19,
};

//MODULE_ID_USERINFO = 1000
enum
{
    DDCMD_USER_INFO_REQ                     = 0x0204,          //查询用户详情
    DDCMD_USER_INFO_RES                     = 0x0205,           //返回用户详情
    
};

//MODULE_ID_P2P
enum {
    CMD_P2P_CMD_DATA        = 1,                        //抖屏
    //    CMD_P2P_CMD_INPUTING    = 2,                        //正在输入
    //    CMD_P2P_CMD_STOPINPUTING= 3                         //停止输入
};

//群
enum
{
    CMD_ID_GROUP_LIST_REQ               = 0x0401,    // 固定群
    CMD_ID_GROUP_LIST_RES               = 0x0402,
    CMD_ID_GROUP_USER_LIST_REQ          = 0x0403,
    CMD_ID_GROUP_USER_LIST_RES          = 0x0404,
    CMD_ID_GROUP_UNREAD_CNT_REQ     = 5,
    CMD_ID_GROUP_UNREAD_CNT_RES     = 6,
    CMD_ID_GROUP_UNREAD_MSG_REQ     = 7,
    CMD_ID_GROUP_UNREAD_MSG_RES     = 8,
    CMD_ID_GROUP_HISTORY_MSG_REQ    = 9,
    CMD_ID_GROUP_HISTORY_MSG_RES    = 10,
    CMD_ID_GROUP_MSG_READ_ACK           = 11,
    CMD_ID_GROUP_CREATE_TMP_GROUP_REQ   = 0x0405,
    CMD_ID_GROUP_CREATE_TMP_GROUP_RES   = 0x0406,
    CMD_ID_GROUP_QUIT_GROUP_REQ         = 0x0407,
    CMD_ID_GROUP_QUIT_GROUP_RES         = 0x0408,
    CMD_ID_GROUP_JOIN_GROUP_REQ     = 14,
    CMD_ID_GROUP_JOIN_GROUP_RES     = 15,
    CMD_ID_GROUP_DIALOG_LIST_REQ        = 16,   // 最近联系群
    CMD_ID_GROUP_DIALOG_LIST_RES        = 17,
    CMD_ID_FIXED_GROUP_CHANGED          = 19,
    CID_GROUP_SHIELD_GROUP_REQUEST      = 0x0409,
    CID_GROUP_SHIELD_GROUP_RESPONSE     = 0x040a,
    
};
@interface TcpProtocolHeader : NSObject

@property (nonatomic,assign) UInt16 version;
@property (nonatomic,assign) UInt16 flag;
@property (nonatomic,assign) UInt16 serviceId;
@property (nonatomic,assign) UInt16 commandId;
@property (nonatomic,assign) UInt16 reserved;
@property (nonatomic,assign) UInt16 error;

@end
