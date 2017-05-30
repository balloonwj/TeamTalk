/*******************************************************************************
 *  @file      TcpSocketsManager.h 2014\12\1 19:54:39 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef TCPSOCKETSMANAGER_2EAF3E98_E9C6_4F3D_ADE6_387E54BCA3AC_H__
#define TCPSOCKETSMANAGER_2EAF3E98_E9C6_4F3D_ADE6_387E54BCA3AC_H__

#include "network/imconn.h"

/******************************************************************************/

/**
 * The class <code>TcpSocketsManager</code> 
 *
 */
class TcpSocketsManager
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Destructor
     */
    ~TcpSocketsManager();
    //@}
	static TcpSocketsManager* getInstance();

public:
	net_handle_t connect(const char* server_ip, uint16_t server_port);
	CImConn* get_client_conn(uint32_t nHandle);
	void release_by_handle(net_handle_t handle);
	void unRegisterCallback(net_handle_t handle);
	void registerCallback(net_handle_t handle,ITcpSocketCallback* pCB);

private:
	TcpSocketsManager();

private:
	ConnMap_t		m_client_conn_map;
};
/******************************************************************************/
#endif// TCPSOCKETSMANAGER_2EAF3E98_E9C6_4F3D_ADE6_387E54BCA3AC_H__
