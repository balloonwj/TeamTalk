/**
 * @file    standard_header.h
 * @brief   标准头文件
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-23
 * @website www.xiangwangfeng.com
 */
#pragma once
#include <cassert>
#include <iostream>
#include <cstdio>
#include<algorithm>
#include <locale>
#include <cctype>
#include <sys/stat.h>
#include <WinSock2.h>
#include <Windows.h>

#define HTTP_CLIENT_EXPORT	//导出标识

#define PTR_BOOL(p)		{assert(p); if(!p){return false;}}
#define SAFE_DELETE(p)	{if(p) {delete p; p = 0;}}

const int	kmax_file_buffer_size		=	10240;	//上传下载文件的buffer的大小
const int	kmax_buffer_size			=	1024;	//普通传输的buffer大小
const int	kmax_http_pool_threads_num	=	5;
