/**
 * @file    dll_init.cpp
 * @brief   DLL加载卸载过程
 * @author  xiangwangfeng <xiangwangfeng@gmail.com>
 * @data	2011-7-5
 * @website www.xiangwangfeng.com
 */
#include "standard_header.h"
#include "http_pool.h"

void	onDLLProcessAttach()
{

}

void	onDLLThreadAttach()
{

}

void	onDLLThreadDetach()
{

}


void	onDLLProcessDetach()
{
	//Http::HttpPool::freeInstance();	
}


BOOL APIENTRY DllMain(HANDLE hModule, 
					  DWORD  ul_reason_for_call, 
					  LPVOID lpReserved)
{
	switch( ul_reason_for_call ) 
	{
		case DLL_PROCESS_ATTACH:

			onDLLProcessAttach();
			break;
		case DLL_THREAD_ATTACH:
			onDLLThreadAttach();
			break;
		case DLL_THREAD_DETACH:
			onDLLThreadDetach();
			break;
		case DLL_PROCESS_DETACH:
			onDLLProcessDetach();
			break;
	}
	return TRUE;
}