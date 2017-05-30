/*******************************************************************************
 *  @file      IOperation.h 2014\7\16 19:10:09 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief	   异步操作执行单位
 ******************************************************************************/

#ifndef IOPERATION123_D8CF1B19_B95A_4A75_82FB_7572A1BB9A30_H__
#define IOPERATION123_D8CF1B19_B95A_4A75_82FB_7572A1BB9A30_H__

#include "GlobalDefine.h"
#include "network/networkdll.h"
#include <memory>
/******************************************************************************/
NAMESPACE_BEGIN(imcore)

/**
 * The class <code>IOperation</code> 
 *
 */
struct NETWORK_DLL IOperation
{
public:
	virtual void process() = 0;
//private:
	/**
	* 必须让容器来释放自己
	*
	* @return  void
	* @exception there is no any exception to throw.
	*/
	virtual void release() = 0;
};

NAMESPACE_END(imcore)
/******************************************************************************/
#endif// IOPERATION123_D8CF1B19_B95A_4A75_82FB_7572A1BB9A30_H__
