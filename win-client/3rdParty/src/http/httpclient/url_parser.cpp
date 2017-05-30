/**
 * @file    url_parser.cpp
 * @brief   简单的URL解析类(缺少各种判断，待完善)
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "url_parser.h"
#include "util.h"

NAMESPACE_BEGIN(Http)


URLParser::URLParser(const std::string &url)
:_port(80),
_object(url)
{
	parseURL(url);
}

void	URLParser::parseURL(const std::string &url)
{
	size_t	length	=	url.length();
	if (length	<	7)	//过短的URL可以认为是无效的
	{
		assert(false);
		return;
	}
	else
	{
		std::string	protocal	=	url.substr(0,7);
		std::string	format_url	=	url;
		if (_strcmpi(protocal.c_str(),"http://") == 0)
		{
			format_url	=	url.substr(7,length-7);
		}
		splitURL(format_url);
	}
}

void	URLParser::splitURL(const std::string& format_url)
{
	size_t	index	=	format_url.find('/');
	size_t	length	=	format_url.length();
	if (index != std::string::npos
		&&	index != length - 1)
	{
		_object					=	format_url.substr(index,length - index);
		std::string	domain		=	format_url.substr(0,index);
		size_t	colon_index		=	domain.find(":");
		size_t	domain_length	=	domain.length();
		if (colon_index !=	std::string::npos &&
			colon_index < domain_length - 1)
		{
			_domain				=	domain.substr(0,colon_index);
			std::string	port	=	domain.substr(colon_index + 1,domain_length - colon_index -1);
			try
			{
				_port	=	atoi(port.c_str());
			}
			catch (...)
			{
				_port	=	80;
			}
		}
		else
		{
			_domain	=	domain;
		}
	}
	else
	{
		size_t	pos = format_url.find(':');
		if (pos != std::string::npos
			&&	pos != length - 1)
		{
			_domain = format_url.substr(0,pos);
			std::string strPort = format_url.substr(pos+1, format_url.length() - pos);
			_port = atoi(strPort.c_str());
		}
		else
			_domain = format_url;
	}
}


NAMESPACE_END(Http)