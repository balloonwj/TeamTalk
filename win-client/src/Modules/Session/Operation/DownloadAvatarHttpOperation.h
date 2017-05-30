/*******************************************************************************
 *  @file      DownloadImgHttpOperation.h 2014\8\14 10:18:26 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     下载图片操作
 ******************************************************************************/

#ifndef DOWNLOADIMGHTTPOPERATION_4BB88F5E_5D0E_4FBA_9530_72972EB7647C_H__
#define DOWNLOADIMGHTTPOPERATION_4BB88F5E_5D0E_4FBA_9530_72972EB7647C_H__

#include "Modules/IModuleInterface.h"
#include "Modules/IHttpPoolModule.h"
#include "Modules/IDatabaseModule.h"
/******************************************************************************/

const std::string AVATAR_FORMAT_48X48 = "_50x50";
const std::string AVATAR_FORMAT_64X64 = "_64x64";
const std::string AVATAR_FORMAT_170X170 = "_170x170";

class DownloadImgParam
{
public:
	enum
	{
		DOWNLOADIMG_OK = 0,             //下载成功
		DOWNLOADIMG_ERROR,				//网络错误
	};

public:
	UInt8						m_result;
	std::string					m_sId;
	module::ImImageEntity		m_imgEntity;
};

/**
 * The class <code>下载图片操作</code> 
 *
 */
class DownloadAvatarHttpOperation : public module::IHttpOperation
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
	DownloadAvatarHttpOperation(IN std::string sId,IN std::string& downUrl,IN BOOL bGrayScale
		,const std::string format,module::IOperationDelegate callback);
    /**
     * Destructor
     */
    virtual ~DownloadAvatarHttpOperation();
    //@}

public:
	virtual void processOpertion();
	virtual void release();

private:
	std::string		m_downUrl;
	std::string		m_sId;
	std::string		m_format;
	BOOL			m_bGrayScale;
};

/******************************************************************************/
#endif// DOWNLOADIMGHTTPOPERATION_4BB88F5E_5D0E_4FBA_9530_72972EB7647C_H__
