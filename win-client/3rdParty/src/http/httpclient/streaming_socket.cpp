/**
 * @file    streaming_socket.cpp
 * @brief   对原生WinSocket的封装类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-23
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "streaming_socket.h"
#include "socket_helper.h"

NAMESPACE_BEGIN(Http)

StreamingSocket::StreamingSocket()
:_port_number(0),_handle(-1),_connected(false)
{
	SocketHelper::initializeWinSocket();
}

StreamingSocket::~StreamingSocket()
{
	close();
}

bool	StreamingSocket::connect(const std::string &remote_host_name, int remote_port_number, 
								 int timeout)
{
	close();

	_host_name		=	remote_host_name;
	_port_number	=	remote_port_number;

	_connected		=	SocketHelper::connectSocket(_handle,_host_name,_port_number,timeout);


	if (!(_connected && resetSocketOptions()))
	{
		return false;
	}
	return true;
}

void	StreamingSocket::close()
{
	if (_connected || _handle != SOCKET_ERROR)
	{
		closesocket(_handle);
	}
	_connected		=	false;
	_host_name		=	"";
	_port_number	=	0;
	_handle			=	-1;
}


int		StreamingSocket::read(char *dest_buffer, int max_read_length)
{
	return _connected ? SocketHelper::readSocket(_handle,_connected,dest_buffer,max_read_length,false) :
			-1;
}

int		StreamingSocket::write(const char *source_buffer, int max_write_length)
{
	return _connected ? SocketHelper::writeSocket(_handle,source_buffer,max_write_length) :
			-1;
}

bool	StreamingSocket::writeAll(const char* source_buffer,int max_write_length)
{
	int unsend_data_length	=	max_write_length;
	const	char*	data	=	source_buffer;

	while (unsend_data_length)
	{
		int ret = write(data,unsend_data_length);
		if (ret <= 0)
		{
			break;
		}
		else
		{
			unsend_data_length	-= ret;
			data				+= ret;
		}

	}
	return unsend_data_length == 0;
}

bool	StreamingSocket::resetSocketOptions()
{
	return	SocketHelper::resetSocketOptions(_handle);
}

NAMESPACE_END(Http)