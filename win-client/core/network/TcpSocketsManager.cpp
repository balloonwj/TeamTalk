/******************************************************************************* 
 *  @file      TcpSocketsManager.cpp 2014\12\1 19:55:00 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#include "GlobalDefine.h"
#include "TcpSocketsManager.h"
/******************************************************************************/

// -----------------------------------------------------------------------------
//  TcpSocketsManager: Public, Constructor

TcpSocketsManager::TcpSocketsManager()
{

}

// -----------------------------------------------------------------------------
//  TcpSocketsManager: Public, Destructor

TcpSocketsManager::~TcpSocketsManager()
{

}

net_handle_t TcpSocketsManager::connect(const char* server_ip, uint16_t server_port)
{
	CImConn* pConn = new CImConn;
	net_handle_t handle = pConn->Connect(server_ip, server_port);
	if (handle != SOCKET_ERROR)
	{
		m_client_conn_map[handle] = pConn;
	}

	return handle;
}

TcpSocketsManager* TcpSocketsManager::getInstance()
{
	static TcpSocketsManager inst;
	return &inst;
}

CImConn* TcpSocketsManager::get_client_conn(uint32_t nHandle)
{
	CImConn* pConn = 0;
	ConnMap_t::iterator iter = m_client_conn_map.find(nHandle);
	if (iter != m_client_conn_map.end()) {
		pConn = iter->second;
	}
	return pConn;
}

void TcpSocketsManager::registerCallback(net_handle_t handle, ITcpSocketCallback* pCB)
{
	CImConn* pConn = TcpSocketsManager::getInstance()->get_client_conn(handle);
	if (pConn)
		pConn->registerCallback(pCB);
}

void TcpSocketsManager::unRegisterCallback(net_handle_t handle)
{
	CImConn* pConn = TcpSocketsManager::getInstance()->get_client_conn(handle);
	if (pConn)
		pConn->unRegisterCallback();

	release_by_handle(handle);
}

void TcpSocketsManager::release_by_handle(net_handle_t handle)
{
	ConnMap_t::iterator iter = m_client_conn_map.find(handle);
	if (iter != m_client_conn_map.end())
		m_client_conn_map.erase(handle);
}

/******************************************************************************/