/*******************************************************************************
 *  @file      ISysConfigModule.h 2014\8\4 10:54:39 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     系统配置信息，包括系统设置和全局配置信息
 ******************************************************************************/

#ifndef ISYSCONFIGMODULE_03995006_A398_4574_BAE1_549FE4543DD3_H__
#define ISYSCONFIGMODULE_03995006_A398_4574_BAE1_549FE4543DD3_H__

#include "GlobalDefine.h"
#include "Modules/ModuleDll.h"
#include "Modules/ModuleBase.h"
/******************************************************************************/
NAMESPACE_BEGIN(module)
const UInt16 SYSCONFIG_VERSIONI = 1;
const std::string MODULE_SYSCONFIG_PREFIX = "SysConfig";

//KEYID
const std::string KEY_SYSCONFIG_UPDATED					= MODULE_SYSCONFIG_PREFIX + "Update";//个人设置更新
const std::string KEY_SYSCONFIG_SHOW_USERDETAILDIALOG	= MODULE_SYSCONFIG_PREFIX + "ShowUserDetailDialog";//展示用户详细信息窗口

//BaseFlag
enum
{
	BASE_FLAG_TOPMOST = 1 << 0,						//是否在其他窗口最前端
	BASE_FLAG_NOTIPWHENNEWMSG = 1 << 1,				//当有新消息时飘窗提示
	BASE_FLAG_NOSOUNDWHENMSG = 1 << 2,				//是否关闭消息声音提示
	BASE_FLAG_SENDIMG_BY_CTRLENTER = 1 << 3,        //Ctrl + Enter键发送消息，反之Enter
};

//MusicID
enum
{
	MUSIC_SOUND_DINGDONG =  0,		//叮咚声
	MUSIC_SOUND_KEYBOARD,      //键盘声音
	MUSIC_SOUND_DINGLIN ,       //叮铃声
	MUSIC_SOUND_CALLMSG ,        //来电声音
};

struct TTConfigNeedCache
{
	UInt16			version = 0;
	BOOL			isRememberPWD = TRUE;
	CString			userName;
	std::string		password;
	CString			loginServIP = _T("http://access.teamtalk.im:8080/msg_server");				//开源测试服务器地址
	Int32			sysBaseFlag = 0;			//基本设置
	Int32			sysSoundTypeBaseFlag = 0;	//声音类型
};

struct TTConfig : public TTConfigNeedCache
{
	UInt8			myselectStatus;
	UInt32			loginServPort = 0;
	CString			csUserId;
	CString			token;
	CString			fileSysAddr;
	CString			fileSysBackUpAddr;
	
	std::string		msgSevPriorIP;//消息服务器地址
	std::string		msgSevBackupIP;//消息服务器备用地址
	UInt32			msgServPort;//消息服务器端口
	std::string		userId;
};

/**
 * The class <code>系统配置信息，包括系统设置和全局配置信息</code> 
 *
 */
class MODULE_API ISysConfigModule : public module::ModuleBase
{
public:
	/**
	 * 获取系统配置数据（改变配置数据之后，如果需要立即保存请调用saveData()）
	 *
	 * @param   SystemConfig & cfg
	 * @return  void
	 * @exception there is no any exception to throw.
	 */	
	virtual TTConfig* getSystemConfig() = 0;
	/**
	* 获取用户ID
	*
	* @return  std::string
	* @exception there is no any exception to throw.
	*/
	virtual std::string userID()const = 0;
	virtual CString UserID()const = 0;
	virtual UInt32 userId()const = 0;
	/**
	 * 将配置数据保存到本地
	 *
	 * @return  BOOL
	 * @exception there is no any exception to throw.
	 */
	virtual BOOL saveData() = 0;
	virtual BOOL showServerConfigDialog(IN HWND hParentWnd) = 0;
	/**
	 * 显示系统配置窗口
	 *
	 * @return  void
	 * @exception there is no any exception to throw.
	 */
	virtual void showSysConfigDialog(IN HWND hParentWnd) = 0;
	/**
	* 释放窗口的时候，置false；创建的时候置true
	*
	* @return  void
	* @exception there is no any exception to throw.
	*/
	virtual void setSysConfigDialogFlag(IN BOOL bIsExist) = 0;
	
	/**
	 * 账号目录下的用户信息最后更新时间(暂时放这里)
	 *
	 * @param   void
	 * @return  UInt32
	 * @exception there is no any exception to throw.
	 */	
	virtual UInt32 getUserInfoLatestUpdateTime(void) = 0;
	virtual void saveUserInfoLatestUpdateTime(IN const UInt32 nLatestUpdateTime) = 0;

	virtual UInt32 getDepartmentInfoLatestUpdateTime(void) = 0;
	virtual void saveDepartmentInfoLatestUpdateTime(IN const UInt32 nLatestUpdateTime) = 0;

	virtual UInt32 getRecentSessionLatestUpdateTime(void) = 0;
	virtual void saveRecentSessionLatestUpdateTime(IN const UInt32 nLatestUpdateTime) = 0;
};

MODULE_API ISysConfigModule* getSysConfigModule();

NAMESPACE_END(module)
/******************************************************************************/
#endif// ISYSCONFIGMODULE_03995006_A398_4574_BAE1_549FE4543DD3_H__
