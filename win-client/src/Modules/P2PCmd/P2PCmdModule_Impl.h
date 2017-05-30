/*******************************************************************************
 *  @file      P2PCmdModule_Impl.h 2014\8\18 13:45:06 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     客户端与客户端之间传输数据，如正在输入、抖动
 ******************************************************************************/

#ifndef P2PCMDMODULE_IMPL_A50A4241_F1E2_4E7D_A738_70C2E5EE82BE_H__
#define P2PCMDMODULE_IMPL_A50A4241_F1E2_4E7D_A738_70C2E5EE82BE_H__

#include "Modules/IP2PCmdModule.h"
/******************************************************************************/

/**
 * The class <code>客户端与客户端之间传输数据，如正在输入、抖动</code> 
 *
 */
class P2PCmdModule_Impl : public module::IP2PCmdModule
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    P2PCmdModule_Impl() = default;
    /**
     * Destructor
     */
    virtual ~P2PCmdModule_Impl() = default;
    //@}
	virtual void onPacket(imcore::TTPBHeader& header, std::string& pbBody);
public:
	virtual BOOL tcpSendShakeWindowCMD(IN std::string sToID);
	virtual void tcpSendWritingCMD(IN std::string sToID, IN const BOOL bWriting);

private:
	void _parseMsgJsonData(IN std::string sJsonData, OUT UInt32& nServiceID, OUT UInt32& nCmdID);
	void _makeJsonData(IN UINT32 nServiceID, IN UINT32 nCmdID, IN std::string sContent, OUT std::string& sJsonData);

private:
	/**@name 服务器端拆包*/
	//@{
	void _p2pCmdNotifyResponse(std::string& pbBody);
	//@}
};
/******************************************************************************/
#endif// P2PCMDMODULE_IMPL_A50A4241_F1E2_4E7D_A738_70C2E5EE82BE_H__
