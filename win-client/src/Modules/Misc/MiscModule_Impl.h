/*******************************************************************************
 *  @file      MiscModule.h 2014\8\4 9:56:39 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     一些比较杂的公用的接口函数全部放到这里
 ******************************************************************************/

#ifndef MISCMODULE_A3EEE277_68C9_4F13_96CD_1C0AB4033F12_H__
#define MISCMODULE_A3EEE277_68C9_4F13_96CD_1C0AB4033F12_H__

#include "Modules/IMiscModule.h"
#include "Modules/ModuleBase.h"
/******************************************************************************/

/**
 * The class <code>一些比较杂的公用的接口函数</code> 
 *
 */
class MiscModule_Impl : public module::IMiscModule
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    MiscModule_Impl();
    /**
     * Destructor
     */
    virtual ~MiscModule_Impl();
    //@}
	virtual void release();

public:
	virtual CString getUsersDir();
	virtual CString getTTCommonAppdata();
	virtual CString getCurAccountDir();
	virtual CString getDownloadDir();
	virtual CString getDownloadDirByToday();
	virtual CString getDataDir();
	virtual CString getDefaultAvatar();
	virtual CString getUserTempDir();
	virtual CString getDumpDir();
	virtual CString getFileRecvDir();//文件传输保存的路径
	virtual CString getTTCommonAppdataUserDir();//在系统公共目录下
	virtual CString GetAudioFileSavedPath();	//语音文件保存目录
	virtual CString getEmotionFilesDir();
	virtual CString makeShortTimeDescription(IN UInt32 Intime);
	
	virtual void playSysConfigSound();	//播放设置的声音
	virtual void playSound(const CString& path);
	virtual void quitTheApplication();
	virtual CString getAppTitle();
	virtual void asynOpenWebBrowser(CString& url, Int32 nFlag = SW_SHOWMAXIMIZED);
	virtual void doProcess1(IN std::string& pData, OUT std::string& pOutData);
	virtual void doProcess2(IN std::string& pData, OUT std::string& pOutData);
};
/******************************************************************************/
#endif// MISCMODULE_A3EEE277_68C9_4F13_96CD_1C0AB4033F12_H__
