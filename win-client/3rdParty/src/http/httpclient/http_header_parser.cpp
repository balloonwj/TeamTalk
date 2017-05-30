/**
 * @file    http_header_parser.cpp
 * @brief   Http头解析类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "http_header_parser.h"
#include "util.h"

NAMESPACE_BEGIN(Http)

HttpHeaderParser::HttpHeaderParser(const std::string& header)
:_chunked(false),
_http_code(-1),
_content_length(0)
{
	Util::makeLower(header,_header);
	parseHeader();
}


void	HttpHeaderParser::parseHeader()
{
	parseHttpCode();
	parseChunkedType();
	parseConetentLength();
}

void	HttpHeaderParser::parseHttpCode()
{
	//正常HTTP头中 第9-11位为HTTP状态码
	size_t lenght	=	_header.length();
	if (lenght	>=	12)
	{
		std::string http_code = _header.substr(9,3);
		try
		{
			_http_code	=	atoi(http_code.c_str());
		}
		catch (...)
		{
			_http_code	=	-1;
		}
	}
}

void	HttpHeaderParser::parseChunkedType()
{
	size_t index = _header.find("transfer-encoding:");
	if (index	!=	std::string::npos)
	{
		size_t start_index		= index + 19;
		size_t end_index		= _header.find("\r\n",start_index);
		std::string header_value= _header.substr(start_index,end_index-start_index);
		std::string	transfer_encoding;
		Util::trimString(header_value,transfer_encoding);
		_chunked = (transfer_encoding.compare("chunked") == 0);
	}
}

void	HttpHeaderParser::parseConetentLength()
{
	//modify by kuaidao 子串模式匹配问题修复
	std::string conLenSplit = "content-length:";
	size_t start_index = _header.find(conLenSplit);
	if (start_index == std::string::npos)
	{	
		return;
	}
	size_t end_index = _header.find("\r\n",start_index);
	if (end_index != std::string::npos)
	{
		std::string content_length = _header.substr(start_index + conLenSplit.size(), end_index - start_index - conLenSplit.size());
		try
		{
			_content_length	=	atoi(content_length.c_str());
		}
		catch(...)
		{
			_content_length	=	0;
		}
	}
}


NAMESPACE_END(Http)