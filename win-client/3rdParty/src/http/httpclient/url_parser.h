/**
 * @file    url_parser.h
 * @brief   简单的URL解析类(缺少各种判断，待完善)
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "global_defs.h"

NAMESPACE_BEGIN(Http)

//URL解析类
class URLParser
{
public:
	URLParser(const std::string&	url);
public:
	const	std::string&	getDomain()	const	{	return	_domain;}
	const	std::string&	getObject()	const	{	return	_object;}
	int		getPort()	const {	return	_port;}
private:
	void	parseURL(const std::string&	url);
	void	splitURL(const std::string& format_url);
private:
	int			_port;		//端口
	std::string	_domain;	//域名
	std::string	_object;	//请求数据
};

NAMESPACE_END(Http)