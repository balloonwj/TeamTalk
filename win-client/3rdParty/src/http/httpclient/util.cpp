/**
 * @file    util.cpp
 * @brief   通用的辅助函数集合
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-23
 * @website www.xiangwangfeng.com
 */

#include "standard_header.h"
#include "util.h"


#pragma warning(disable :4996)

NAMESPACE_BEGIN(Util)

void	makeLower(char* source,int len)
{
	std::transform(source, source + len, source, tolower);
}

void	makeLower(const std::string& input,std::string& output)
{
	size_t	length	=	input.size();
	if (length	>	0)
	{
		output.resize(length);
		std::transform(input.begin(),input.end(),output.begin(),tolower)
;	}
}

void	trimString(const std::string& input,std::string& output)
{
	output	=	input;
	size_t	start_index	=	input.find_first_not_of(" ");
	size_t	end_index	=	input.find_last_not_of(" ");
	if (start_index != std::string::npos &&
		end_index >= start_index)
	{
		output	=	input.substr(start_index,end_index + 1 - start_index);
	}
}



std::string	num_to_string(int num)
{
	char buff[33] = {0};
	sprintf_s(buff,33,"%d",num);
	return std::string(buff);
}

std::string	toUTF8(const std::wstring& source)
{
	int bytes = WideCharToMultiByte(CP_UTF8,0,source.c_str(),-1,NULL,0,NULL,NULL);
	char*  buffer = new char[bytes];
	bytes = WideCharToMultiByte(CP_UTF8,0,source.c_str(),-1,buffer,bytes,NULL,NULL);	

	std::string	dest(buffer);
	delete [] buffer;
	return dest ;
}


std::string	toMBCS(const std::wstring& source)
{
	int bytes = WideCharToMultiByte(CP_ACP,0,source.c_str(),-1,NULL,0,NULL,NULL);
	char*  buffer = new char[bytes];
	bytes = WideCharToMultiByte(CP_ACP,0,source.c_str(),-1,buffer,bytes,NULL,NULL);	

	std::string	dest(buffer);
	delete [] buffer;
	return dest ;
}


int		getFileSize(const std::wstring& filepath)
{
	std::string	mbcs_filepath	=	toMBCS(filepath);
	struct stat file_stat;
	stat(mbcs_filepath.c_str(),&file_stat);
	return (int)file_stat.st_size;		//不支持大文件
}


std::string	torfc1738(const std::string& source)
{
	static	char hex[] = "0123456789ABCDEF";
	std::string dst;
	for (size_t i = 0; i < source.size(); ++i)
	{
		if (isalnum(source[i]))
		{
			dst += source[i];
		}
		else
			if (source[i] == ' ')
			{
				dst += '+';
			}
			else
			{
				unsigned char c = static_cast<unsigned char>(source[i]);
				dst += '%';
				dst += hex[c / 16];
				dst += hex[c % 16];
			}
	}
	return dst;
}


NAMESPACE_END(Util)