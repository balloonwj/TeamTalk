/**
 * @file    streaming_socket.h
 * @brief   对原生WinSocket的封装类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-23
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "global_defs.h"

NAMESPACE_BEGIN(Http)

//对原生SOCKET的封装
class HTTP_CLASS StreamingSocket
{
public:
	StreamingSocket();
	~StreamingSocket();
public:
	bool	connect(const std::string& remote_host_name,
					int remote_port_number,
					int timeout = 3000);

	bool	isConnected() const	{return _connected;}

	void	close();

	int		read(char* dest_buffer,int max_read_length);

	int		write(const char* source_buffer,int max_write_length);

	bool	writeAll(const char* source_buffer,int max_write_length);
private:
	bool	resetSocketOptions();
private:
	std::string		_host_name;				//目标地址
	int	volatile	_port_number,_handle;	//端口号，SOCKET
	bool			_connected;				//是否已连接
	
};


NAMESPACE_END(Http)