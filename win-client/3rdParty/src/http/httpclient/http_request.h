/**
 * @file    http_request.h
 * @brief   Http请求
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include <vector>
#include "global_defs.h"

#pragma warning(disable:4251)

NAMESPACE_BEGIN(Http)

class IHttpPostFile;

//Http字段
struct	HttpField
{
	std::string	_field_name;
	std::string	_field_value;
	HttpField(const std::string& name,const std::string& value)
		:_field_name(name),_field_value(value){}
};

//Http上传文件定义
struct HttpFile 
{
	std::string		_name;
	IHttpPostFile*	_post_file;
	HttpFile(const std::string& name,IHttpPostFile* post_file)
		:_name(name),_post_file(post_file){}
	~HttpFile();
};


class HTTP_CLASS HttpRequest
{
public:
	HttpRequest();
	HttpRequest(const std::string& method,const std::string& url);
	~HttpRequest();
public:
	void	setRequest(const std::string& method,const std::string& url);
	void	addHeaderField(const std::string& name,const std::string& value);
	void	addFile(const std::string& name,IHttpPostFile*	post_file);
	void	addField(const std::string& name,const std::string& value)	{	_body_fields.push_back(HttpField(name,value));}
	void	setBody(const std::string& body)	{	_body	=	body;}
	void	setOnlyDownloadHeader()				{	_only_download_header	=	true;}
	void	saveToFile(const std::wstring& filepath)	{	_save_as_file = true; _filepath = filepath;}
private:
	const	std::string&	getMethod()	const	{	return	_http_method;}				
	const	std::string&	getHost()	const	{	return	_http_host;}				
	int		getPortNumber() const	{	return	_port_number;}							
	const	std::string&	getBody()	const	{	return	_body;}						
	const	std::string&	getBoundary()	const		{	return	_boundary;}			
	bool	isMultipart()	const	{	return _is_multipart;}							
	const	std::vector<HttpFile*>&	getFiles()	const	{	return	_post_files;}		
	bool	onlyDownloadHeader()const	{	return	_only_download_header;}
	bool	saveAsFile()	const	{	return	_save_as_file;}
	const	std::wstring&	getFilePath() const		{	return	_filepath;}
	int		generateHeader(std::string&	header);
	void	addExtraHeaderField(const std::string& name,const std::string& value);
	void	initDefaultValue();
	void	calcBody();
	void	genBoundary();
	DECLARE_NON_COPYABLE(HttpRequest)
private:
	std::string						_http_method;		//HTTP方法
	std::string						_http_host;			//主机
	std::string						_object;			//请求对象
	int								_port_number;		//端口
	std::vector<HttpField>			_header_fields;		//HTTP头字段
	std::vector<HttpField>			_body_fields;		//HTTP体参数
	std::vector<HttpFile*>			_post_files;		//上传文件列表
	std::string						_boundary;			//Boundary;
	std::string						_body;				//HTTP体
	bool							_is_multipart;		//是否是Multipart
	bool							_only_download_header;//是否只下载HTTP头
	std::wstring					_filepath;			//用于下载的文件路径
	bool							_save_as_file;		//是否以文件的形式接受反馈

	friend	class	HttpClient;
};

NAMESPACE_END(Http)