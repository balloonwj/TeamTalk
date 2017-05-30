#ifndef _IO_LOOP_H
#define _IO_LOOP_H
#include "socket_io.h"
#include "base_socket.hpp"
#include "../thread/base_thread.hpp"
#include "base_io_stream.h"
#include "../type/base_type.h"
#include <map>
#include <vector>
using namespace std;

class CWakerPipe
{
public:
	CWakerPipe() 
	{ 
		m_wake_sock_recv = S_INVALID_SOCKET;
		m_wake_sock_send = S_INVALID_SOCKET;
	}
	~CWakerPipe() 
	{
	}

	void Start() 
	{
		m_wake_sock_recv = S_CreateSocket(AF_INET, SOCK_DGRAM, 0);
		m_wake_sock_send = S_CreateSocket(AF_INET, SOCK_DGRAM, 0);
        S_Bind(m_wake_sock_recv, "127.0.0.1", 0);
        S_GetSockName(m_wake_sock_recv, m_szRecvIP, &m_nRecvPort);
	}

	void Stop() 
	{
		if (m_wake_sock_recv != S_INVALID_SOCKET)
		{
			S_CloseSocket(m_wake_sock_recv);
			m_wake_sock_recv = S_INVALID_SOCKET;
		}
		if (m_wake_sock_send != S_INVALID_SOCKET)
		{
			S_CloseSocket(m_wake_sock_send);
			m_wake_sock_send = S_INVALID_SOCKET;
		}
	}

	S_SOCKET GetWakeSocket() { return m_wake_sock_recv; }

	void Wake()
	{
		const char* szMsg = "lljzj";
		S_SendTo(m_wake_sock_send, (void*)szMsg, (int32_t)strlen(szMsg), m_szRecvIP, m_nRecvPort);
	}

	void Recv()
	{
		char szMsg[64] = {0};
        char szIP[32] = {0};
        int32_t nPort = 0;
		S_RecvFrom(m_wake_sock_recv, szMsg, 32, szIP, &nPort);
	}
private:
	S_SOCKET m_wake_sock_recv;
	S_SOCKET m_wake_sock_send;
    char m_szRecvIP[32];
    int32_t m_nRecvPort;
};

class SOCKET_IO_DECLARE_CLASS CIOLoop
{
public:
	CIOLoop(void);
	virtual ~CIOLoop(void);

    static void*  RunThread(void* param);

	virtual void Start();
	virtual void Stop();
	virtual void Run();

	virtual void Add_Handler( CBaseIOStream* piostream );
	virtual void Remove_Handler(CBaseIOStream* piostream);
	virtual void Add_WriteEvent(CBaseIOStream* piostream) { m_waker.Wake(); }
	virtual void Remove_WriteEvent(CBaseIOStream* piostream) { m_waker.Wake(); }
protected:
	CBaseIOStream* _GetHandlerBySock(S_SOCKET sock);

protected:
	bool m_bCloseRequest;
    CBaseThread m_thread;

	map<S_SOCKET, CBaseIOStream*> m_MapIOStreamBySocket;
    CBaseMutex m_MapMutex;

	CWakerPipe m_waker;
};
#endif
