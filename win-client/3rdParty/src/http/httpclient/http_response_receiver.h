/**
 * @file    http_response_receiver.h
 * @brief   Http反馈接受类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-26
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <xstring>
#include <string>
#include "global_defs.h"

namespace Util
{
	class FileWriter;
}

NAMESPACE_BEGIN(Http)

//Http反馈接受的Wrapper类
class HttpResponseReceiver
{
public:
	HttpResponseReceiver();
	HttpResponseReceiver(const std::wstring&	filepath);
	~HttpResponseReceiver();
public:
	bool	write(const	char*	buffer,int	length);
	void	close();
	const std::string&	getBody()	const	{	return	_body;}
private:
	std::string			_body;
	bool				_save_as_file;
	Util::FileWriter*	_file_writer;
	const	int			_min_flush_length;
};

NAMESPACE_END(Http)