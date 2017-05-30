/*******************************************************************************
 *  @file      IMiscModule.h 2014\8\4 9:51:53 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef IMISCMODULE_450253C2_B143_4DD2_BD21_552FC6049D7A_H__
#define IMISCMODULE_450253C2_B143_4DD2_BD21_552FC6049D7A_H__

#include "GlobalDefine.h"
#include "Modules/ModuleDll.h"
/******************************************************************************/
class FloatInfo;
NAMESPACE_BEGIN(module)

/**
 * The class <code>一些比较杂的公用的接口函数</code> 
 *
 */
class MODULE_API IMiscModule
{
public:
	virtual CString getUsersDir() = 0;
	virtual CString getTTCommonAppdata() = 0;
	virtual CString getCurAccountDir() = 0;
	virtual CString getDownloadDir() = 0;
	virtual CString getDataDir() = 0;
	virtual CString getDefaultAvatar() = 0;
	virtual CString getUserTempDir() = 0;
	virtual CString getDumpDir() = 0;
	virtual CString getTTCommonAppdataUserDir() = 0;//在系统公共目录下
	virtual CString GetAudioFileSavedPath() = 0;
	virtual CString getEmotionFilesDir() = 0;
	virtual CString getFileRecvDir() = 0;
	/**
	 * 转换成显示的时间
	 *
	 * @param   IN UInt32 time
	 * @return  CString
	 * @exception 当天的时间显示为 小时：分钟
				  大于1天的显示为 昨天
				  大于2天的显示为 月-日
				  大于1年的显示为 去年
				  大于2年的显示为 远古
	 */
	virtual CString makeShortTimeDescription(IN UInt32 time) = 0;
	/**
	* 播放设置的声音
	*
	* @param   void
	* @return  void
	* @exception there is no any exception to throw.
	*/
	virtual void playSysConfigSound() = 0;	//
	/**
	* 播放wav格式的音频文件
	*
	* @param   const CString & path
	* @return  void
	* @exception there is no any exception to throw.
	*/
	virtual void playSound(IN const CString& path) = 0;
	/**
	 * 退出应用程序
	 *
	 * @return  void
	 * @exception there is no any exception to throw.
	 */	
	virtual void quitTheApplication() = 0;
	/**
	 * 获取应用程序标题
	 *
	 * @return  CString
	 * @exception there is no any exception to throw.
	 */
	virtual CString getAppTitle() = 0;

	/**
	 * 异步打开浏览器窗口
	 *
	 * @param   const CString & strURL
	 * @param   INT nFlag
	 * @return  void
	 * @exception there is no any exception to throw.
	 */	
	virtual void asynOpenWebBrowser(CString& url, INT nFlag = SW_SHOWMAXIMIZED) = 0;

	/**
	* 消息加/解密函数（注：该名称不能取的太明显,你懂得~）
	*
	* @param   std::string& pData
	* @param   std::string& pOutData
	* @return  BOOL 成功 true 失败 false
	* @exception there is no any exception to throw.
	*/
	virtual void doProcess1(IN std::string& pData,OUT std::string& pOutData) = 0;
	virtual void doProcess2(IN std::string& pData, OUT std::string& pOutData) = 0;
};

#define ENCRYPT_MSG(p1,p2) module::getMiscModule()->doProcess1((p1),(p2))
#define	DECRYPT_MSG(p1,p2) module::getMiscModule()->doProcess2((p1),(p2))

MODULE_API IMiscModule* getMiscModule();

NAMESPACE_END(module)
/******************************************************************************/
#endif// IMISCMODULE_450253C2_B143_4DD2_BD21_552FC6049D7A_H__
