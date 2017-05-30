/******************************************************************************* 
 *  @file      TTPBHeader.cpp 2014\12\25 20:48:28 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "network/TTPBHeader.h"

/******************************************************************************/
NAMESPACE_BEGIN(imcore)

// -----------------------------------------------------------------------------
//  TTPBHeader: Public, Constructor

TTPBHeader::TTPBHeader()
:m_pHeaderBuff(0)
{
	m_pHeaderBuff = new byte[HEADER_LENGTH];
}

// -----------------------------------------------------------------------------
//  TTPBHeader: Public, Destructor

TTPBHeader::~TTPBHeader()
{
	delete m_pHeaderBuff;
	m_pHeaderBuff = 0;
}

byte* TTPBHeader::getSerializeBuffer()
{
	_serialize();
	return m_pHeaderBuff;
}

void TTPBHeader::unSerialize(byte* headerBuff,UInt16 len)
{
	if (len != HEADER_LENGTH || 0 == headerBuff || 0 == m_pHeaderBuff)
		return;
	memcpy(m_pHeaderBuff, headerBuff, len);
	if (m_pHeaderBuff)
	{
		CByteStream is(m_pHeaderBuff, HEADER_LENGTH);
		is >> m_length;
		is >> m_version;
		is >> m_flag;
		is >> m_moduleId;
		is >> m_commandId;
		is >> m_seqNumber;
		is >> m_reserved;
	}
}

void TTPBHeader::_serialize()
{
	CByteStream::WriteInt32(m_pHeaderBuff, m_length);
	CByteStream::WriteUint16(m_pHeaderBuff + 4, m_version);
	CByteStream::WriteUint16(m_pHeaderBuff + 6, m_flag);
	CByteStream::WriteUint16(m_pHeaderBuff + 8, m_moduleId);
	CByteStream::WriteUint16(m_pHeaderBuff + 10, m_commandId);
	CByteStream::WriteUint16(m_pHeaderBuff + 12, m_seqNumber);
	CByteStream::WriteUint16(m_pHeaderBuff + 14, m_reserved);
}

void TTPBHeader::clear()
{
	memset(m_pHeaderBuff, 0, HEADER_LENGTH);
	m_length = 0;
	m_version = VERSION;
	m_flag = 0;
	m_moduleId = 0;
	m_commandId = 0;
	m_seqNumber = 0;
	m_reserved = 0;
}

NAMESPACE_END(imcore)
/******************************************************************************/