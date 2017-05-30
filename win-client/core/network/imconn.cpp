/******************************************************************************* 
 *  @file      imconn.cpp 2013\6\5 18:51:30 $
 *  @author    згЬк<ziteng@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "network/imconn.h"
#include "network/TTPBHeader.h"
#include "GlobalDefine.h"
#include "TcpSocketsManager.h"

/******************************************************************************/
void imconn_callback(void* callback_data, uint8_t msg, uint32_t handle, void* pParam)
{
	NOTUSED_ARG(handle);
	NOTUSED_ARG(pParam);

	CImConn* pConn = TcpSocketsManager::getInstance()->get_client_conn(handle);
	if (!pConn)
	{
		//LOG__(NET, _T("connection is invalied:%d"), handle);
		return;
	}
	pConn->AddRef();

	//	LOG__(NET,  "msg=%d, handle=%d\n", msg, handle);

	switch (msg)
	{
	case NETLIB_MSG_CONFIRM:
		pConn->onConnect();
		break;
	case NETLIB_MSG_READ:
		pConn->OnRead();
		break;
	case NETLIB_MSG_WRITE:
		pConn->OnWrite();
		break;
	case NETLIB_MSG_CLOSE:
		pConn->OnClose();
		break;
	default:
		LOG__(NET,  _T("!!!imconn_callback error msg: %d"), msg);
		break;
	}

	pConn->ReleaseRef();
}

//////////////////////////
CImConn::CImConn()
:m_pTcpSocketCB(0)
{
	m_busy = false;
	m_handle = NETLIB_INVALID_HANDLE;
}

CImConn::~CImConn()
{
	LOG__(NET,  _T("CImConn::~CImConn, handle=%d"), m_handle);
}

int CImConn::Send(void* data, int len)
{
	if (m_busy)
	{
		m_out_buf.Write(data, len);
		return len;
	}

	int offset = 0;
	int remain = len;
	while (remain > 0) {
		int send_size = remain;
		if (send_size > NETLIB_MAX_SOCKET_BUF_SIZE) {
			send_size = NETLIB_MAX_SOCKET_BUF_SIZE;
		}

		int ret = netlib_send(m_handle, (char*)data + offset, send_size);
		if (ret <= 0) {
			ret = 0;
			break;
		}

		offset += ret;
		remain -= ret;
	}

	if (remain > 0)
	{
		m_out_buf.Write((char*)data + offset, remain);
		m_busy = true;
		LOG__(NET,  _T("send busy, remain=%d"), m_out_buf.GetWriteOffset());
	}

	return len;
}

void CImConn::OnWrite()
{
	if (!m_busy)
		return;

	while (m_out_buf.GetWriteOffset() > 0) {
		int send_size = m_out_buf.GetWriteOffset();
		if (send_size > NETLIB_MAX_SOCKET_BUF_SIZE) {
			send_size = NETLIB_MAX_SOCKET_BUF_SIZE;
		}

		int ret = netlib_send(m_handle, m_out_buf.GetBuffer(), send_size);
		if (ret <= 0) {
			ret = 0;
			break;
		}
		m_out_buf.Read(NULL, ret);
	}

	if (m_out_buf.GetWriteOffset() == 0) {
		m_busy = false;
	}
	LOG__(NET, _T("onWrite, remain=%d"), m_out_buf.GetWriteOffset());
}

void CImConn::onConnect()
{
	LOGA__(NET, "connect done hanle:%d", m_handle);
	if (m_pTcpSocketCB)
		m_pTcpSocketCB->onConnectDone();
}

void CImConn::OnClose()
{
	LOG__(NET,  _T("CImConn OnClose,handle:%d"),m_handle);
	if (m_pTcpSocketCB)
		m_pTcpSocketCB->onClose();
}

void CImConn::OnRead()
{
	for (;;)
	{
		uint32_t free_buf_len = m_in_buf.GetAllocSize() - m_in_buf.GetWriteOffset();
		if (free_buf_len < READ_BUF_SIZE)
			m_in_buf.Extend(READ_BUF_SIZE);

		int ret = netlib_recv(m_handle, m_in_buf.GetBuffer() + m_in_buf.GetWriteOffset(), READ_BUF_SIZE);
		if (ret <= 0)
			break;

		m_in_buf.IncWriteOffset(ret);
		while (m_in_buf.GetWriteOffset() >= imcore::HEADER_LENGTH)
		{
			uint32_t len = m_in_buf.GetWriteOffset();
			uint32_t length = CByteStream::ReadUint32(m_in_buf.GetBuffer());
			if (length > len)
				break;

			try
			{
				imcore::TTPBHeader pbHeader;
				pbHeader.unSerialize((byte*)m_in_buf.GetBuffer(), imcore::HEADER_LENGTH);
				LOG__(NET, _T("OnRead moduleId:0x%x,commandId:0x%x"), pbHeader.getModuleId(), pbHeader.getCommandId());
				if (m_pTcpSocketCB)
					m_pTcpSocketCB->onReceiveData((const char*)m_in_buf.GetBuffer(), length);
				LOGBIN_F__(SOCK, "OnRead", m_in_buf.GetBuffer(), length);
			}
			catch (std::exception& ex)
			{
				assert(FALSE);
				LOGA__(NET, "std::exception,info:%s", ex.what());
				if (m_pTcpSocketCB)
					m_pTcpSocketCB->onReceiveError();
			}
			catch (...)
			{
				assert(FALSE);
				LOG__(NET, _T("unknown exception"));
				if (m_pTcpSocketCB)
					m_pTcpSocketCB->onReceiveError();
			}
			m_in_buf.Read(NULL, length);
		}
	}
}

net_handle_t CImConn::Connect(const char* server_ip, uint16_t server_port)
{
	m_handle = netlib_connect(server_ip, server_port, imconn_callback, 0);
	return m_handle;
}

void CImConn::Close()
{
	netlib_close(m_handle);
	ReleaseRef();
	LOG__(NET,  _T("close, socket=%d"), m_handle);
}

bool CImConn::Shutdown()
{
	LOG__(NET, _T("shutdown, socket=%d"), m_handle);
	return netlib_shutdown(m_handle);
}

void CImConn::registerCallback(ITcpSocketCallback* pCB)
{
	m_pTcpSocketCB = pCB;
}

void CImConn::unRegisterCallback()
{
	m_pTcpSocketCB = 0;
}

/******************************************************************************/