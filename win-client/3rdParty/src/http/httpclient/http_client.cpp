/**
 * @file    http_client.cpp
 * @brief   Http传输类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-24
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "http_client.h"
#include "util.h"
#include "lock.h"
#include "proxy_socket.h"
#include "http_request.h"
#include "http_response.h"
#include "http_delegate.h"
#include "file_writer.h"
#include "http_header_parser.h"
#include "http_response_receiver.h"
#include "http_post_file.h"

NAMESPACE_BEGIN(Http)

HttpClient::HttpClient(bool keep_connection)
:_http_error(HTTPERROR_PARAMETER),
_keep_connection(keep_connection),
_request(0),
_response(0),
_delegate(0),
_is_valid(true)
{
	_proxy_socket	=	new ProxySocket();
	_is_valid_lock	=	new Util::Lock();
}

HttpClient::~HttpClient()
{
	delete	_proxy_socket;
	delete	_is_valid_lock;
}

bool	HttpClient::execute(HttpRequest* request,HttpResponse* respone)
{
	//参数检查
	PTR_BOOL(request);
	PTR_BOOL(respone);
	_request	=	request;
	_response	=	respone;
	setErrorCode(HTTPERROR_SUCCESS);

	//连接服务器
	const std::string&	host	=	_request->getHost();
	int	port_number				=	_request->getPortNumber();
	_proxy_socket->setHost(host,port_number);

	//尝试连接
	{
		const Util::ScopedLock scoped_lock(*_is_valid_lock);
		if (_is_valid)	//判断HttpClient是否还有效
		{
			if (!(_keep_connection && _proxy_socket->isConnected()))
			{
				if (!_proxy_socket->connect())
				{
					setErrorCode(HTTPERROR_CONNECT);
					return false;
				}
			}
		}
		else
		{
			setErrorCode(HTTPERROR_INVALID);
			return false;
		}
	}

	//进行数据传输
	bool	execute				=	false;
	const	std::string& method	=	_request->getMethod();

	//Get方法
	if (_strcmpi(method.c_str(),kget) == 0)
	{
		execute	=	httpGet();
	}
	//Post方法
	else if (_strcmpi(method.c_str(),kpost) == 0)
	{
		execute	=	httpPost();
	}
	//其他，抛出错误
	else
	{
		assert(false);
	}
	
	//如果不是长连接 就关闭网络
	if (!_keep_connection)
	{
		_proxy_socket->close();
	}

	return execute;
}

void	HttpClient::setProxy(const Http::ProxyConfig *proxy_config)
{
	PTR_VOID(proxy_config);
	ProxySocket::setProxy(*proxy_config);
}

void	HttpClient::setErrorCode(HTTPERROR http_error)
{
	_http_error	=	http_error;
	//如果传输失败后，关闭当前Socket 
	//(为了支持keep-alive模式，在服务器出错后能够正常进行重连)
	if (_http_error != HTTPERROR_SUCCESS)	
	{
		_proxy_socket->close();
	}
}


void	HttpClient::killSelf()
{
	const Util::ScopedLock scoped_lock(*_is_valid_lock);
	_is_valid	=	false;
	_proxy_socket->close();
}

void	HttpClient::reset()
{
	const Util::ScopedLock scoped_lock(*_is_valid_lock);
	_proxy_socket->close();
}


bool	HttpClient::httpGet()
{
	//发送HTTP头请求
	if (sendHeader())
	{
		//接受反馈
		return	getResponse();
	}
	else
	{
		setErrorCode(HTTPERROR_TRANSPORT);
		return false;
	}
}

bool	HttpClient::httpPost()
{
	//发送HTTP头请求
	bool complete = false;
	if (sendHeader())
	{
		if (_request->isMultipart())
		{
			complete	=	doMultipartPost();
		}
		else
		{
			if (sendBody())
			{
				complete	= 	getResponse();
			}
		}
	}
	return complete;
}

bool	HttpClient::sendHeader()
{
	std::string header;
	int	header_length	=	_request->generateHeader(header);
	bool send			=	_proxy_socket->writeAll(header.c_str(),header_length);
	if (!send)
	{
		setErrorCode(HTTPERROR_TRANSPORT);
	}
	return send;
}

bool	HttpClient::sendBody()
{
	const std::string&	body	=	_request->getBody();
	size_t	length				=	body.length();
	if (length == 0)
	{
		return true;	//如果body内没有内容 直接返回true
						//(上传文件的时候body内容是动态生成，body内容可能为空) 
	}
	bool	send				=	_proxy_socket->writeAll(body.c_str(),body.length());
	if (!send)
	{
		setErrorCode(HTTPERROR_TRANSPORT);;
	}
	return send;
}

bool	HttpClient::doMultipartPost()
{
	//如果有Fields段 已经写入了body内  直接发送
	if (!sendBody())
	{
		setErrorCode(HTTPERROR_TRANSPORT);
		return false;
	}

	//发送文件
	const std::vector<HttpFile*>& post_files	=	_request->getFiles();
	const std::string&	boundary				=	_request->getBoundary();
	for (size_t i = 0; i < post_files.size(); i++)
	{
		//modify by kuaidao "Content-Type:""Content-Disposition"大小写敏感
		const std::string name		=	post_files[i]->_name;
		IHttpPostFile* post_file	=	post_files[i]->_post_file;
		std::string file_header		=  "--" + boundary + "\r\n"
										"Content-Disposition: form-data; name=\"" + name + "\"; filename=\"" + 
										post_file->getFilename() + "\"\r\n" +
										"Content-Type: " + post_file->getContentType() + "\r\n" +
										"\r\n";

		bool send_file_header		 = _proxy_socket->writeAll(file_header.c_str(),file_header.size());
		if (!send_file_header)
		{
			setErrorCode(HTTPERROR_TRANSPORT);
			return false;
		}

		bool post_file_success = uploadFile(post_file);
		if (!post_file_success)
		{
			setErrorCode(HTTPERROR_TRANSPORT);
			return false;
		}


		std::string file_tailer = "\r\n";
		bool send_file_tailer	 = _proxy_socket->writeAll(file_tailer.c_str(),file_tailer.size());
		if (!send_file_tailer)
		{
			setErrorCode(HTTPERROR_TRANSPORT);
			return false;
		}
	}

	//发送boundary结束标记
	std::string post_tailer		= "--" + boundary + "--\r\n";
	bool send_post_tailer		= _proxy_socket->writeAll(post_tailer.c_str(),post_tailer.size());
	
	return send_post_tailer ? getResponse() : setErrorCode(HTTPERROR_TRANSPORT) , false;
	
}

bool	HttpClient::uploadFile(IHttpPostFile* post_file)
{
	FilePoster file_poster(_proxy_socket,_http_error,_delegate);
	return post_file ? post_file->postFile(file_poster) : false;
}


bool	HttpClient::getResponse()
{
	std::string	body_header;		//收取的Body和Header的混合体
	if (downloadHeader(body_header))
	{
		//如果请求指定只需要获取Http头直接返回 (主要是为分段下载减少下载量)
		if (_request->onlyDownloadHeader())
		{
			return true;
		}
		else
		{
			return	downloadBody(body_header);
		}
	}
	else
	{
		return	false;
	}
}

bool	HttpClient::downloadHeader(std::string& body_header)
{
	body_header.clear();
	char buff[kmax_buffer_size] = {0};
	std::string	header;
	bool complete = false;
	while(!complete)
	{
		int ret = _proxy_socket->read(buff,kmax_buffer_size);
		if (ret <= 0)
		{
			setErrorCode(HTTPERROR_TRANSPORT);
			break;
		}
		header.append(buff,ret);					//因为Header往往很短，基本一次可以收完
		size_t end_index = header.find("\r\n\r\n");	//所以也不需要计算偏移来提高搜索速度
		if (end_index != std::string::npos)
		{
			complete			= true;
			size_t length		= header.length() ;
			body_header			= header.substr(end_index + 4,length - end_index - 4);
			_response->setHeader(header.substr(0,end_index + 4));
		}
	}
	return complete;
}

bool	HttpClient::downloadBody(const std::string& body_header)
{
	const std::string& header	=	_response->getHeader();
	HttpHeaderParser	header_parser(header);
	bool	is_chunked			=	header_parser.isChunked();
	int		http_code			=	header_parser.getHttpCode();
	int		content_lenght		=	header_parser.getContentLength();
	bool	complete			=	false;
	_response->setHttpCode(http_code);
	if (is_chunked)	//Chunk类型的Http体
	{
		complete = downloadChunkedBody(body_header);
	}
	else	//带Content-Length的Http体
	{
		complete = downloadFixedSizeBody(body_header,content_lenght);	
	}

	return complete;	//下载完毕
}


bool	HttpClient::downloadFixedSizeBody(const std::string& body_header,int content_length)
{
	int	received_length	=	(int)body_header.length();
	if (received_length > content_length ||
		content_length	<	0)
	{
		setErrorCode(HTTPERROR_TRANSPORT);
		assert(false);
		return false;
	}
	
	//构造Http反馈接收类
	HttpResponseReceiver*	response_receiver	=	0;
	if (_request->saveAsFile())
	{
		const std::wstring& filepath	=	_request->getFilePath();
		_response->setBody(Util::toUTF8(filepath));		//如果是下载到本地IO，则response的Body里面保存的是文件路径
		response_receiver				=	new HttpResponseReceiver(filepath);
	}
	else
	{
		response_receiver				=	new HttpResponseReceiver();
	}

	//接受Http体
	bool	complete=	false;
	bool	write	=	response_receiver->write(body_header.c_str(),body_header.length());
	if (write)
	{
		int		unreceived_length			=	content_length	-	received_length;
		onDataReadProgress(received_length,content_length);
		char	buff[kmax_file_buffer_size]	=	{0};
		while (unreceived_length >	0)
		{
			int	ret	=	_proxy_socket->read(buff,kmax_file_buffer_size);
			if (ret <= 0)
			{
				setErrorCode(HTTPERROR_TRANSPORT);
				break;
			}
			else if (!response_receiver->write(buff,ret))
			{
				setErrorCode(HTTPERROR_IO);
				break;
			}
			unreceived_length	-=	ret;
			onDataReadProgress(content_length - unreceived_length,content_length);
		}
		complete	=	(unreceived_length	==	0);
	}
	else
	{
		setErrorCode(HTTPERROR_IO);
	}

	//如果是写入内存数据 需要赋回给HttpResponse
	if (complete && !_request->saveAsFile())
	{
		const std::string&	body	=	response_receiver->getBody();
		_response->setBody(body);
	}

	delete	response_receiver;
	return	complete;
}

bool	HttpClient::downloadChunkedBody(const std::string& body_header)
{
	std::string body		= body_header;		//接受HTTP头时拿到的部分HTTP体信息
	bool complete			= false;			//是否已经接受完整了
	bool find_first_chunk	= false;			//是否找到第一个ChunkSize
	int	 chunk_size			= 0;				//Chunk的数据大小
	int  chunk_size_length	= 0;				//ChunkSize的大小  比如 12\r\n 说明;chunk_size为18 chunk_size_length为2

	//构造Http反馈接收类
	HttpResponseReceiver*	response_receiver	=	0;
	bool	save_as_file						=	_request->saveAsFile();
	if (save_as_file)
	{
		const std::wstring& filepath	=	_request->getFilePath();
		_response->setBody(Util::toUTF8(filepath));
		response_receiver				=	new HttpResponseReceiver(filepath);
	}
	else
	{
		response_receiver				=	new HttpResponseReceiver();
	}

	//接受并解析chunk内容
	while(true)
	{
		//如果在上次已经查询到第一块chunk的大小
		if (find_first_chunk)
		{
			if (chunk_size == 0)//如果是最后一块了
			{
				complete = true;
				break;
			}
			else	//否则分析chunk内容并进行切割
			{
				size_t length		= body.length();
				size_t first_chunk	= chunk_size_length + 2 + chunk_size + 2;
				if (length >= first_chunk)	//如果已经接受到一整块chunkdata了则进行切割，否则重新接受
				{
					find_first_chunk		= false;
					std::string chunk_data	= body.substr(chunk_size_length + 2, chunk_size);
					body.erase(0,first_chunk);
					if (!response_receiver->write(chunk_data.c_str(),chunk_data.length()))
					{
						setErrorCode(HTTPERROR_IO);
						break;
					}
				}
				else
				{
					if (!continueToReceiveBody(body))
					{
						setErrorCode(HTTPERROR_TRANSPORT);
						break;
					}
				}
			}
		}
		else//查找chunk_size
		{
			size_t index = body.find("\r\n");
			if (index != std::string::npos)		//找到，做标记
			{
				find_first_chunk			= true;
				chunk_size_length			= (int)index;
				std::string raw_chunk_size	= body.substr(0,chunk_size_length);
				chunk_size					= (int)strtoul(raw_chunk_size.c_str(),0,16);

			}
			else	//没有找到，继续接受信息
			{
				if (!continueToReceiveBody(body))
				{
					setErrorCode(HTTPERROR_TRANSPORT);
					break;
				}
			}
		}
	}

	if (!save_as_file && complete)
	{
		const std::string&	body	=	response_receiver->getBody();
		_response->setBody(body);
	}
	delete response_receiver;

	return complete;	
}

bool	HttpClient::continueToReceiveBody(std::string& body)
{
	char buff[kmax_file_buffer_size] = {0};
	int ret	=	_proxy_socket->read(buff,kmax_file_buffer_size);
	if (ret <= 0)
	{
		setErrorCode(HTTPERROR_TRANSPORT);
		return false;
	}
	else
	{
		body.append(buff,ret);
		return true;
	}
}

void	HttpClient::onDataReadProgress(int read_length,int total_length)
{
	if (_delegate) 
	{
		_delegate->dataReadProgress(read_length,total_length);
	}
}

NAMESPACE_END(Http)