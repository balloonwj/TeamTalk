/*******************************************************************************
 *  @file      imconn.h 2013\6\5 18:51:30 $
 *  @author    згЬк<ziteng@mogujie.com>
 *  @brief     
 ******************************************************************************/

#ifndef IMCONN_F6246291_E098_40CB_B2B9_612AD9AC1F93_H__
#define IMCONN_F6246291_E098_40CB_B2B9_612AD9AC1F93_H__

#include "netlib.h"
#include "network/util.h"
#include "UtilPdu.h"
#include <map>
#include <string>
/******************************************************************************/

#define SERVER_HEARTBEAT_INTERVAL	5000
#define SERVER_TIMEOUT				30000
#define CLIENT_HEARTBEAT_INTERVAL	30000
#define CLIENT_TIMEOUT				120000

#define READ_BUF_SIZE	1024 * 128

class CImConn;
typedef hash_map<net_handle_t, CImConn*>		ConnMap_t;

struct ITcpSocketCallback
{
	virtual void onClose() = 0;
	virtual void onReceiveData(const char* data, int32_t size) = 0;
	virtual void onConnectDone() = 0;
	virtual void onReceiveError() = 0;
};

class CImConn : public CRefObject
{
public:
	CImConn();
	virtual ~CImConn();

	net_handle_t Connect(const char* server_ip, uint16_t server_port);
	void Close();	
	bool Shutdown();
	int Send(void* data, int len);

	void onConnect();
	void OnRead();
	void OnWrite();
	void OnClose();
	void OnTimer(uint64_t curr_tick) {}

	void unRegisterCallback();
	void registerCallback(ITcpSocketCallback* pCB);

protected:
	net_handle_t	m_handle;
	bool			m_busy;

	string			m_peer_ip;
	uint16_t		m_peer_port;
	CSimpleBuffer	m_in_buf;
	CSimpleBuffer	m_out_buf;

	ITcpSocketCallback*	m_pTcpSocketCB;
};

void imconn_callback(void* callback_data, uint8_t msg, uint32_t handle, void* pParam);

/******************************************************************************/
#endif// IMCONN_F6246291_E098_40CB_B2B9_612AD9AC1F93_H__

