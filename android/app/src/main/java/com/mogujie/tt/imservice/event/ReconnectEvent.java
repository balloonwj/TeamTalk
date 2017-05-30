package com.mogujie.tt.imservice.event;

/**
 * @author : yingmu on 15-1-5.
 * @email : yingmu@mogujie.com.
 *
 * 用户是否的登陆: 依赖loginManager的状态
 *   没有: 底层socket重连
 *   有: 底层socket重连，relogin
 */
public enum ReconnectEvent {
    NONE,

    SUCCESS,
    DISABLE
}
