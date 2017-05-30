/**
 * @file    socket_helper.h
 * @brief   Socket相关的辅助函数
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-23
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "global_defs.h"

NAMESPACE_BEGIN(SocketHelper)

void	initializeWinSocket();

bool	connectSocket(int volatile& handle,const std::string& remote_host_name,
					int remote_port_number,int timeout_millisecs);

int		readSocket(int handle,bool connected,char* dest_buffer,int max_read_length,bool block_util_all_arrived);

int		writeSocket(int handle,const char* source_buffer,int max_write_length);

bool	resetSocketOptions(int handle);

bool	setSocketBlockingState(int handle,bool block);

int		waitForReadiness (int handle, bool for_ready, int timeout_msecs);

unsigned long	getIntAddress(const char* ip_address);

NAMESPACE_END(SocketHelper)