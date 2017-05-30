/**
 * @file    util.h
 * @brief   通用的辅助函数集合
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-4-23
 * @website www.xiangwangfeng.com
 */

#pragma once
#include <string>
#include "global_defs.h"



NAMESPACE_BEGIN(Util)

//转换字符串为小写
void	makeLower(char*	source,int len);

//转换字符串为小写
void	makeLower(const std::string& input,std::string& output);

//数字转字符串
std::string	num_to_string(int num);

//除去字符串两边空格
void	trimString(const std::string& input,std::string& output);

//Unicode转UTF8
std::string	toUTF8(const std::wstring&	source);

//Unicode转MBCS
std::string	toMBCS(const std::wstring&	source);

//返回文件大小
int		getFileSize(const std::wstring&	filepath);

//rfc1738编码
std::string torfc1738(const std::string& source);

NAMESPACE_END(Util)