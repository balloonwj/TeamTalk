//
//  NotificationHelp.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "NotificationHelp.h"




//NSString* const notificationLoginMsgServerSuccess = @"Notification_Login_Msg_Server_Success";
//NSString* const notificationLoginMsgServerFailure = @"Notification_Login_Msg_Server_Success";
NSString* const notificationRemoveSession = @"Notification_Remove_Session";
//NSString* const notificationLoginLoginServerSuccess = @"Notification_login_login_server_success";
//NSString* const notificationLoginLoginServerFailure = @"Notification_login_login_server_failure";
NSString* const notificationTcpLinkConnectComplete = @"Notification_Tcp_Link_connect_complete";
NSString* const notificationTcpLinkConnectFailure = @"Notification_Tcp_Link_conntect_Failure";
NSString* const notificationTcpLinkDisconnect = @"Notification_Tcp_link_Disconnect";
NSString* const notificationServerHeartBeat = @"Notification_Server_heart_beat";
NSString* const notificationUserLoginSuccess = @"Notification_user_login_success";
NSString* const notificationUserOffline = @"Notification_user_off_line";
NSString* const notificationUserKickouted = @"Notification_user_kick_out";

NSString* const notificationReloadTheRecentContacts = @"Notification_reload_recent_contacts";

//NSString* const notificationGetAllUsers = @"Notification_get_all_Users";
NSString* const notificationReceiveMessage = @"Notification_receive_message";
NSString* const notificationReceiveP2PShakeMessage = @"Notification_receive_P2P_Shake_message";
NSString* const notificationReceiveP2PInputingMessage = @"Notifictaion_receive_P2P_Inputing_message";
NSString* const notificationReceiveP2PStopInputingMessage = @"Notification_receive_P2P_StopInputing_message";
NSString* const notificationReceiveP2PIntranetMessage = @"Notification_receive_P2P_Intranet_message";
@implementation NotificationHelp
+ (void)postNotification:(NSString*)notification userInfo:(NSDictionary*)userInfo object:(id)object
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object userInfo:userInfo];
    });
}
@end
