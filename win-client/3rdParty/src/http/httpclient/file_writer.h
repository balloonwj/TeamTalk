/**
 * @file    file_writer.h
 * @brief   写文件Wrapper类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-25
 * @website www.xiangwangfeng.com
 */

#pragma once

#include <xstring>
#include "global_defs.h"

NAMESPACE_BEGIN(Util)

//写文件Wrapper类
class FileWriter
{
public:
	FileWriter(const std::wstring&	filepath);
	~FileWriter();
public:
	bool	create();
	bool	write(const char* buffer,size_t length);
	void	flush();
	void	close();
private:
	std::wstring	_filepath;		//文件路径	
	bool			_ready;			//是否准备完毕
	FILE*			_file;			//文件指针
};


NAMESPACE_END(Util)