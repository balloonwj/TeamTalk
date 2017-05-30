/**
 * @file    http_header_parser.h
 * @brief   Http头解析类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "global_defs.h"

NAMESPACE_BEGIN(Http)

//Http文件头解析类
//这个解析类并不是一个通用的解析类，只关注如下字段：
//是否Chunked传输，文件长度，Http返回码
class HttpHeaderParser
{
public:
	HttpHeaderParser(const std::string& header);
public:
	bool	isChunked()	const			{	return	_chunked;}
	int		getContentLength()	const	{	return	_content_length;}
	int		getHttpCode()	const		{	return	_http_code;}
private:
	void	parseHeader();
	void	parseChunkedType();
	void	parseConetentLength();
	void	parseHttpCode();
private:
	std::string		_header;
	bool			_chunked;
	int				_http_code;
	int				_content_length;
};

NAMESPACE_END(Http)