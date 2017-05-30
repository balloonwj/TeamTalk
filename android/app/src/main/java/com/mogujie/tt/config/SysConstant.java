package com.mogujie.tt.config;

/**
 * 系统的常量类
 */
public interface SysConstant {

    /**头像尺寸大小定义*/
    public static final String AVATAR_APPEND_32 ="_32x32.jpg";
    public static final String AVATAR_APPEND_100 ="_100x100.jpg";
    public static final String AVATAR_APPEND_120 ="_100x100.jpg";//头像120*120的pic 没有 所以统一100
    public static final String AVATAR_APPEND_200="_200x200.jpg";

    /**协议头相关 start*/
	public static final int PROTOCOL_HEADER_LENGTH = 16;// 默认消息头的长度
	public static final int PROTOCOL_VERSION = 6;
	public static final int PROTOCOL_FLAG = 0;
	public static final char PROTOCOL_ERROR = '0';
	public static final char PROTOCOL_RESERVED = '0';


    // 读取磁盘上文件， 分支判断其类型
	public static final int FILE_SAVE_TYPE_IMAGE = 0X00013;
	public static final int FILE_SAVE_TYPE_AUDIO = 0X00014;


	public static final float MAX_SOUND_RECORD_TIME = 60.0f;// 单位秒
	public static final int MAX_SELECT_IMAGE_COUNT = 6;


    /**表情使用*/
	public static final int pageSize = 21;
    public static final int yayaPageSize = 8;


    // 好像设定了，但是好像没有用
    public static final int ALBUM_PREVIEW_BACK = 3;
    // resultCode 返回值
	public static final int ALBUM_BACK_DATA = 5;
    public static final int CAMERA_WITH_DATA = 3023;


    /**
     *1. 配置的全局key
     * */
    public static final String SETTING_GLOBAL = "Global";
    public static final String UPLOAD_IMAGE_INTENT_PARAMS = "com.mogujie.tt.upload.image.intent";
    /**
     * event 优先级
     * */
    public static final int SERVICE_EVENTBUS_PRIORITY = 10;
    public static final int MESSAGE_EVENTBUS_PRIORITY = 100;

    //message 每次拉取的条数
    public static final int MSG_CNT_PER_PAGE = 18;
}
