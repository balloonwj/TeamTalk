/**
 * @file    http_global.h
 * @brief   Http全局数据定义
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */
#pragma once
#include "global_defs.h"

const	char	kget[]				=	"GET";
const	char	kpost[]				=	"POST";
const	char	kaccept[]			=	"Accept";
const	char	kconnection[]		=	"Connection";
const	char	kcontent_type[]		=	"Content-Type";
const	char	kcontent_length[]	=	"Content-Length";

NAMESPACE_BEGIN(Http)

//Http传输错误码
enum	HTTPERROR
{
	HTTPERROR_SUCCESS,		//正确
	HTTPERROR_INVALID,		//HTTP已经被弃用
	HTTPERROR_CONNECT,		//连接出错
	HTTPERROR_TRANSPORT,	//传输失败
	HTTPERROR_IO,			//IO错误
	HTTPERROR_PARAMETER		//无效参数
};

NAMESPACE_END(Http)