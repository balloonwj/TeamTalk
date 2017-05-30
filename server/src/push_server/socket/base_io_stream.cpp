#include "base_io_stream.h"
#include "socket_io_define.h"
#include "io_loop.h"

CSLog g_socketlog = CSLog(LOG_MODULE_SOCKET);

CBaseIOStream::CBaseIOStream(CIOLoop* pio)
{
	m_socket = S_INVALID_SOCKET;
	m_sock_id = CSockIDGenerator::GetInstance()->GetSocketID();
	m_bCheckTcpConnected = FALSE;
	m_pio = pio;
}

CBaseIOStream::~CBaseIOStream(void)
{
    Close();
}


/**	@fn	BOOL CBaseIOStream::Bind(const char* szIP, uint32_t nPort)
*	@brief 
*	@param[in] szIP 
*	@param[in] nPort 
*	@return	
*/
BOOL CBaseIOStream::Bind( const char* szIP, uint32_t nPort ) const
{
	if (S_Bind(m_socket, szIP, nPort) == 0)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

void CBaseIOStream::Close()
{
    if (m_socket != S_INVALID_SOCKET)
    {
        if (m_pio)
        {
            m_pio->Remove_Handler(this);
        }
        S_CloseSocket(m_socket);
        m_socket = S_INVALID_SOCKET;
    }
}

void CBaseIOStream::ShutDown()
{
    Close();
}
