/*******************************************************************************
 *  @file      TTPBHeader.h 2014\12\25 20:48:25 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef TTPBHEADER_BE699480_6F65_405B_9E8A_F5B0F13800D0_H__
#define TTPBHEADER_BE699480_6F65_405B_9E8A_F5B0F13800D0_H__

#include "GlobalDefine.h"
#include "UtilPdu.h"
#include "networkdll.h"
/******************************************************************************/
NAMESPACE_BEGIN(imcore)

const static Int8 HEADER_LENGTH = 16;
const static Int16 VERSION = 1;

const UInt32 TTPBHEADER_RESERVED_MASK = 0xff00U;

enum
{
	RESERVED_TYPE_HISTORY_MESSAGE				= TTPBHEADER_RESERVED_MASK | 0x01,		//identify send history message packet
	RESERVED_TYPE_HISTORY_SCROLLBOTTOM_MESSAGE	= TTPBHEADER_RESERVED_MASK | 0x02,		//identify send history message packet which will scroll bottom
	RESERVER_TYPE_UNREADER_MESSAGE				= TTPBHEADER_RESERVED_MASK | 0x03,		//identify unread message packet
};

/**
 * The class <code>TTPBHeader</code> 
 *
 */
class NETWORK_DLL TTPBHeader final
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    TTPBHeader();
    /**
     * Destructor
     */
    ~TTPBHeader();
    //@}

public:
	byte* getSerializeBuffer();
	void unSerialize(byte* headerBuff, UInt16 len);
	void clear();
	inline void setLength(UInt32 length) { m_length = length; }
	inline void setModuleId(UInt16 moduleId) { m_moduleId = moduleId; }
	inline void setCommandId(UInt16 cmdId) { m_commandId = cmdId; }
	inline void setSeqNumber(UInt16 seq) { m_seqNumber = seq; }
	inline void setReserved(UInt16 reservId) { m_reserved = reservId; }

	inline UInt16 getModuleId()const { return m_moduleId; }
	inline UInt16 getCommandId()const { return m_commandId; }
	inline UInt16 getReserved()const { return m_reserved; }
	inline UInt16 getSeqNumber()const {  return m_seqNumber; }

private:
	void _serialize();

private:
	UInt32 		m_length = 0;
	UInt16 		m_version = VERSION;
	UInt16		m_flag = 0;
	UInt16		m_moduleId = 0;
	UInt16		m_commandId = 0;
	UInt16		m_seqNumber = 0;	// °üÐòºÅ
	UInt16		m_reserved = 0; // ±£Áô

	byte*		m_pHeaderBuff = 0;
};

NAMESPACE_END(imcore)
/******************************************************************************/
#endif// TTPBHEADER_BE699480_6F65_405B_9E8A_F5B0F13800D0_H__
