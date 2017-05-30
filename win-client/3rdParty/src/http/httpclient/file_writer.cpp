/**
 * @file    file_writer.h
 * @brief   写文件Wrapper类
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-25
 * @website www.xiangwangfeng.com
 */

#include "standard_header.h"
#include "file_writer.h"

NAMESPACE_BEGIN(Util)

FileWriter::FileWriter(const std::wstring &filepath)
:_filepath(filepath),
_ready(false),
_file(0)
{

}

FileWriter::~FileWriter()
{
	close();
}

bool	FileWriter::create()
{
	_ready	=	(_wfopen_s(&_file,_filepath.c_str(),L"wb") == 0);
	return	_ready;
}

bool	FileWriter::write(const char *buffer, size_t length)
{
	return _ready ? length == fwrite(buffer,1,length,_file)
		: false;
}

void	FileWriter::flush()
{
	fflush(_file);
}

void	FileWriter::close()
{
	if (_ready)
	{
		fclose(_file);
		_ready	=	false;
	}
}


NAMESPACE_END(Util)