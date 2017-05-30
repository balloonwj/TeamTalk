/**
 * @file    http_post_file.h
 * @brief   用于HTTP POST的文件接口定义 
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-26
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include <xstring>
#include "global_defs.h"
#include "http_global.h"

NAMESPACE_BEGIN(Http)

class	ProxySocket;
class	IProgressDelegate;


//文件POST传输结构
struct	HTTP_CLASS FilePoster 
{
	ProxySocket*	_proxy_socket;
	HTTPERROR&		_http_error;
	IProgressDelegate*	_delegate;

	FilePoster(ProxySocket* proxy_socket,HTTPERROR&	http_error,IProgressDelegate* delegate) 
		: _proxy_socket(proxy_socket) ,_http_error(http_error),_delegate(delegate){}
};

//HTTP POST文件接口
class HTTP_CLASS	IHttpPostFile
{
public:
	const	std::string&	getContentType()const	{	return	_content_type;}		
	const	std::string&	getFilename()	const	{	return	_filename;}
	int		getFileSize()	const					{	return	_file_size;}

	//传输接口，需要派生类实现
	virtual	bool	postFile(FilePoster&	file_poster)	= 0;
	virtual	~IHttpPostFile() {}
protected:
	int			_file_size;			//文件大小
	std::string	_filename;			//文件名
	std::string	_content_type;		//Content-Type
};


//本地文件流
class HTTP_CLASS	HttpFileStream	:	public	IHttpPostFile
{
public:
	HttpFileStream(const std::wstring&	filepath, const std::string& fileName, const std::string& content_type = "Application/oct-stream");
public:
	virtual	bool	postFile(FilePoster&	file_poster);
private:
	std::wstring		_filepath;		//文件名
};


//内存文件流
class HTTP_CLASS	HttpMemoryStream	:	public	IHttpPostFile
{
public:
	HttpMemoryStream(const char* data,size_t length,const std::string& filename,
		const std::string& content_type = "Application/oct-stream");
public:
	virtual	bool	postFile(FilePoster&	file_poster);
private:
	std::string		_data;		//数据块
};

NAMESPACE_END(Http)