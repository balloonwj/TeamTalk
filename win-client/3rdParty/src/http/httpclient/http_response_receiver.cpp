/**
 * @file    http_response_receiver.cpp
 * @brief   Http反馈接受类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-26
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "http_response_receiver.h"
#include "file_writer.h"

NAMESPACE_BEGIN(Http)

HttpResponseReceiver::HttpResponseReceiver()
:_save_as_file(false),
_min_flush_length(1024 * 100),
_file_writer(0)
{

}


HttpResponseReceiver::HttpResponseReceiver(const std::wstring& filepath)
:_min_flush_length(1024 * 100),
_save_as_file(true)
{
	_file_writer	=	new	Util::FileWriter(filepath);
	_file_writer->create();
}

HttpResponseReceiver::~HttpResponseReceiver()
{
	SAFE_DELETE(_file_writer);
}

bool	HttpResponseReceiver::write(const char *buffer, int length)
{
	if (!_save_as_file)
	{
		_body.append(buffer,length);
		return	true;
	}
	else
	{
		static	int	write_bytes	=	0;
		bool	write			=	_file_writer->write(buffer,length);
		if (write)
		{
			write_bytes	+=	write;
			if (write_bytes	>=	_min_flush_length)
			{
				write_bytes	-=	_min_flush_length;
				_file_writer->flush();
			}
		}
		return	write;
	}
}

void	HttpResponseReceiver::close()
{
	if (_save_as_file)
	{
		_file_writer->close();
	}
}



NAMESPACE_END(Http)