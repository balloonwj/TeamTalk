/**
 * @file    http_post_file.cpp
 * @brief   用于HTTP POST的文件接口定义 
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-26
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "http_post_file.h"
#include "util.h"
#include "file_reader.h"
#include "proxy_socket.h"
#include "http_delegate.h"

NAMESPACE_BEGIN(Http)



HttpFileStream::HttpFileStream(const std::wstring &filepath, const std::string& fileName, const std::string& content_type)
:_filepath(filepath)
{
	_filename		=		fileName;
	_content_type	=		content_type;
	_file_size		=		Util::getFileSize(filepath);
}



bool	HttpFileStream::postFile(FilePoster& file_poster)
{
	ProxySocket* proxy_socket	=	file_poster._proxy_socket;
	HTTPERROR&	http_error		=	file_poster._http_error;
	IProgressDelegate* delegate	=	file_poster._delegate;
	if (proxy_socket)
	{
		bool	complete	=	false;
		Util::FileReader	file_reader(_filepath);
		if (file_reader.open())
		{
			int file_size = getFileSize();	//不支持大文件
			if (file_size > 0)
			{
				int unsend_data = file_size;
				char buff[kmax_file_buffer_size];
				while(unsend_data > 0)
				{
					int read_count = file_reader.read(buff,kmax_file_buffer_size);
					if (read_count > 0)
					{
						bool send = proxy_socket->writeAll(buff,read_count);
						if (!send)
						{
							http_error	=	HTTPERROR_TRANSPORT;
							break;
						}
						else
						{
							unsend_data -= read_count;
							if (delegate)
							{
								delegate->dataWriteProgress(file_size - unsend_data,file_size);
							}
						}
					}
					else
					{
						http_error	=	HTTPERROR_IO;
						break;
					}
				}
				complete = unsend_data == 0;
			}
		}
		return complete;
	}
	else
	{
		assert(false);
		return false;
	}
}



HttpMemoryStream::HttpMemoryStream(const char* data,size_t length,const std::string& filename,
								   const std::string& content_type)
								   :_data(data,length)
{
	_filename		=	filename;
	_content_type	=	content_type;
	_file_size		=	(int)_data.length();
}

bool	HttpMemoryStream::postFile(FilePoster &file_poster)
{
	ProxySocket* proxy_socket	=	file_poster._proxy_socket;
	HTTPERROR&	http_error		=	file_poster._http_error;
	IProgressDelegate* delegate	=	file_poster._delegate;

	if (proxy_socket)
	{
		int total_data_length	=	(int)_data.size();
		int unsend_data_length	=	total_data_length;
		const char* data		=	_data.c_str();
		while (unsend_data_length)
		{
			int send_data_length = (unsend_data_length >= kmax_file_buffer_size ?  
										kmax_file_buffer_size :unsend_data_length);
			int ret = proxy_socket->write(data,send_data_length);
			if (ret <= 0)
			{
				http_error	=	HTTPERROR_TRANSPORT;
				break;
			}
			else
			{
				unsend_data_length	-=	ret;
				data				+=	ret;

				if (delegate)
				{
					delegate->dataWriteProgress(total_data_length - unsend_data_length,total_data_length);
				}
			}
		}
		return unsend_data_length == 0;
	}
	else
	{
		assert(false);
		return false;
	}
}


NAMESPACE_END(Http)