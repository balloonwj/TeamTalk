/**
 * @file    http_response.h
 * @brief   Http反馈
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include <xstring>
#include "global_defs.h"

NAMESPACE_BEGIN(Http)

//Http反馈
class HTTP_CLASS HttpResponse
{
public:
	HttpResponse():_http_code(-1) {}
public:
	int						getHttpCode()	const		{	return	_http_code;}//反馈的HTTP状态嘛
	const	std::string&	getHeader()	const			{	return	_header;}	//HTTP消息头
	const	std::string&	getBody()	const			{	return	_body;}		//HTTP消息体，如果请求是以文件的形式被下载的，这里放的文件路径(UTF编码)
	
private:
	void	setHttpCode(int	http_code)				{	_http_code	=	http_code;}
	void	setBody(const std::string&	body)		{	_body	=	body;}
	void	setHeader(const	std::string&	header)	{	_header	=	header;}

private:
	std::string		_header;					//Http头
	std::string		_body;						//Http体
	int				_http_code;					//Http返回码
	friend	class	HttpClient;
};

NAMESPACE_END(Http)