/**
 * @file    proxy_config.h
 * @brief   代理配置项
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-23
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "global_defs.h"

NAMESPACE_BEGIN(Http)

//代理类型
enum HTTP_DATA ProxyType
{
	PROXY_NULL,
	PROXY_HTTP,
	PROXY_SOCK4,
	PROXY_SOCK5,
};

//代理配置项
struct HTTP_DATA ProxyConfig
{
	ProxyConfig()
	:_proxy_type(PROXY_NULL)
	,_port_number(0)
	{

	}

	ProxyConfig(ProxyType proxy_type,const std::string& host_name,int port_number,
		const std::string& username ="",const std::string& password = "")
		:_proxy_type(proxy_type),
		_host_name(host_name),
		_port_number(port_number),
		_username(username),
		_password(password)
	{

	}

	void	copy(const ProxyConfig& proxy_config)
	{
		_proxy_type		=	proxy_config._proxy_type;
		_host_name		=	proxy_config._host_name;
		_port_number	=	proxy_config._port_number;
		_username		=	proxy_config._username;
		_password		=	proxy_config._password;
	}

	ProxyType		_proxy_type;
	std::string		_host_name;
	int				_port_number;
	std::string		_username;
	std::string		_password;
};


NAMESPACE_END(Http)