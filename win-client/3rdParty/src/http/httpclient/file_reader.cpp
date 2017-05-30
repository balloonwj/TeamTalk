/**
 * @file    file_reader.cpp
 * @brief   读文件Wrapper类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-27
 * @website www.xiangwangfeng.com
 */

#include "standard_header.h"
#include "file_reader.h"

NAMESPACE_BEGIN(Util)

FileReader::FileReader(const std::wstring& filepath)
:_filepath(filepath),
_ready(false),
_file(0)
{

}

FileReader::~FileReader()
{
	close();
}

bool	FileReader::open()
{
	_ready	=	(_wfopen_s(&_file,_filepath.c_str(),L"rb") == 0);
	return	_ready;
}

int		FileReader::read(char *buffer, size_t length)
{
	return _ready ? fread(buffer,1,length,_file)
		: -1 ;
}

void	FileReader::close()
{
	if (_ready)
	{
		fclose(_file);
		_ready = false;
	}
}

NAMESPACE_END(Util)