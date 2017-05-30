#ifndef _SOCKET_IO_H
#define _SOCKET_IO_H

#if (defined(_WIN32) || defined(_WIN64))
#if defined(SOCKET_IO_EXPORTS)
#define SOCKET_IO_DECLARE_CLASS __declspec(dllexport)
#else
#define SOCKET_IO_DECLARE_CLASS __declspec(dllimport)
#endif
#else
#define SOCKET_IO_DECLARE_CLASS
#endif


//#include "io_loop.h"
//#include "epoll_io_loop.h"
//#include "session_msg.h"
//#include "tcp_client_async.h"
//#include "tcp_server.h"
//#include "tcp_session_async.h"
//#include "udp_client.h"

#endif