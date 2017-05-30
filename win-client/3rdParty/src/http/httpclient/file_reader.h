/**
 * @file    file_reader.h
 * @brief   读文件Wrapper类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-27
 * @website www.xiangwangfeng.com
 */

#pragma once

#include <xstring>
#include "global_defs.h"

NAMESPACE_BEGIN(Util)

//读文件Wrapper类
class	FileReader
{
public:
	FileReader(const std::wstring&	filepath);
	~FileReader();
public:
	bool	open();
	int		read(char* buffer,size_t length);
	void	close();
private:
	std::wstring	_filepath;		//文件路径
	bool			_ready;			//是否准备完毕
	FILE*			_file;			//文件指针
};

NAMESPACE_END(Util)