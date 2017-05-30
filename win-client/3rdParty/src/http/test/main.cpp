#include <iostream>
#include <windows.h>
#include "../httpclient/http.h"

class DelegateA : public Http::IProgressDelegate
{
public:
	virtual	void	dataWriteProgress(int write_length,int total_length)  {std::cout<<write_length<<"-------"<<total_length<<std::endl;}
	virtual	void	dataReadProgress(int read_length,int total_length) {std::cout<<read_length<<"-------"<<total_length<<std::endl;}
};

class DelegateB	: public Http::IAsyncHttpDelegate
{
public:
	virtual	void	onError(Http::HTTPERROR error_code,const Http::HttpRequest* request,const Http::HttpResponse* resposne)
	{
		std::cout<<"error code is     "<<error_code<<std::endl;
	}
	virtual	void	onSuccess(const Http::HttpRequest* request,const Http::HttpResponse* resposne)
	{
		std::cout<<"body is   "<<resposne->getBody()<<std::endl;
	}
	virtual	void	dataWriteProgress(int write_length,int total_length)  {std::cout<<write_length<<"-------"<<total_length<<std::endl;}
	virtual	void	dataReadProgress(int read_length,int total_length) {std::cout<<read_length<<"-------"<<total_length<<std::endl;}
};




void	SyncDownloadFile(const std::wstring& filepath)
{
	Http::HttpRequest	request("get","http://image.zcool.com.cn/1/24/m_1268212765379.jpg");
	request.saveToFile(filepath);
	Http::HttpResponse	response;
	Http::HttpClient	client;
	DelegateA a;
	client.setProgressDelegate(&a);
	if (client.execute(&request,&response))
	{
		std::cout<<"download file successfully,filepath is  "<<response.getBody()<<std::endl;
	}
}

void	AsyncDownloadFile()
{
	for (int i = 0; i < 1000; i++)
	{
		wchar_t buff[100]  = {0};
		swprintf_s(buff,100,L"D:\\httpclient_download\\%d.jpg",i);

		Http::HttpRequest*	request = new Http::HttpRequest("get","http://image.zcool.com.cn/1/24/m_1268212765379.jpg");
		request->saveToFile(buff);
		DelegateB* delegate = new DelegateB();
		Http::HttpPool::getInstance()->postRequest(request,delegate);
	}

}

int main()
{
	//未使用代理
	Http::ProxyConfig	empty_proxy;
	std::wstring	noproxy_filepath = L"D:\\httpclient_download\\noproxy.jpg";
	SyncDownloadFile(noproxy_filepath);

	//使用HTTP代理
	Http::ProxyConfig	http_proxy(Http::PROXY_HTTP,"192.168.132.163",808,"proxy","test");
	Http::HttpClient::setProxy(&http_proxy);
	std::wstring	http_proxy_filepath = L"D:\\httpclient_download\\httpproxy.jpg";
	SyncDownloadFile(http_proxy_filepath);


	//使用Socks4代理
	//Http::ProxyConfig	socks4_proxy(Http::PROXY_SOCK4,"192.168.132.163",1080);
	//Http::HttpClient::setProxy(&socks4_proxy);
	//std::wstring	sock4_proxy_filepath = L"D:\\httpclient_download\\socks4.jpg";
	//SyncDownloadFile(sock4_proxy_filepath);


	//使用Socks5代理
	Http::ProxyConfig	socks5_proxy(Http::PROXY_SOCK5,"192.168.132.163",1080,"proxy","test");
	Http::HttpClient::setProxy(&socks5_proxy);
	std::wstring	socks5_proxy_filepath = L"D:\\httpclient_download\\socks5.jpg";
	SyncDownloadFile(socks5_proxy_filepath);


	
	Http::HttpClient::setProxy(&empty_proxy);
	//AsyncDownloadFile();

	Sleep(5000000);
	return 0;
}