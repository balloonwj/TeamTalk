#ifndef _SOCKET_IO_DEFINE_H
#define _SOCKET_IO_DEFINE_H
//
#include "stdio.h"
#include "../slog/slog_api.h"
#define SOCKET_IO_RESULT_OK                 0x0000  //
#define SOCKET_IO_TCP_RECV_FAILED			0x0001	//tcp recv failed
#define SOCKET_IO_TCP_SEND_FAILED			0x0002  //tcp send failed
#define SOCKET_IO_TCP_CONNECT_FAILED		0x0003	//tcp connect failed

#define SOCKET_IO_UDP_RECV_FAILED			0x0011	//udp recv failed
#define SOCKET_IO_UDP_SEND_FAILED			0x0012  //udp send failed

#define SOCKET_IO_SSL_RECV_FAILED           0x0021  //ssl recv failed
#define SOCKET_IO_SSL_SEND_FAILED           0x0022  //ssl send failed
#define SOCKET_IO_SSL_CONNECT_FAILED        0x0023  //ssl connect failed

#define LOG_MODULE_SOCKET   "SOCKET"
extern CSLog g_socketlog;


#define __FILENAME__ (strrchr(__FILE__, '/') ? (strrchr(__FILE__, '/') + 1):__FILE__)

#define SOCKET_IO_FATAL(fmt, ...) \
{\
    g_socketlog.Fatal("<%s>|<%d>|<%s>," fmt, __FILENAME__, __LINE__, __FUNCTION__, ##__VA_ARGS__);\
}


#define SOCKET_IO_ERROR(fmt, ...) \
{\
    g_socketlog.Error("<%s>|<%d>|<%s>," fmt, __FILENAME__, __LINE__, __FUNCTION__, ##__VA_ARGS__);\
}

#define SOCKET_IO_WARN(fmt, ...)  \
{\
    g_socketlog.Warn("<%s>|<%d>|<%s>," fmt, __FILENAME__, __LINE__, __FUNCTION__, ##__VA_ARGS__);\
}

#define SOCKET_IO_INFO(fmt, ...)  \
{\
    g_socketlog.Info("<%s>|<%d>|<%s>," fmt, __FILENAME__, __LINE__, __FUNCTION__, ##__VA_ARGS__);\
}

#define SOCKET_IO_DEBUG(fmt, ...)  \
{\
    g_socketlog.Debug("<%s>|<%d>|<%s>," fmt, __FILENAME__, __LINE__, __FUNCTION__, ##__VA_ARGS__);\
}

#define SOCKET_IO_TRACE(fmt, ...)  \
{\
    g_socketlog.Trace("<%s>|<%d>|<%s>," fmt, __FILENAME__, __LINE__, __FUNCTION__, ##__VA_ARGS__);\
}

#endif