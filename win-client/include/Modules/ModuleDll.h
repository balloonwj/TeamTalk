/*******************************************************************************
 *  @file      ModuleDll.h 2014\7\18 10:35:59 $
 *  @author    ¿ìµ¶<kuaidao@mogujie.com>
 *  @brief   
 ******************************************************************************/

#ifndef MODULEDLL_BEC4C7B0_327C_463B_A33A_C29891DA3E66_H__
#define MODULEDLL_BEC4C7B0_327C_463B_A33A_C29891DA3E66_H__

/******************************************************************************/

#ifndef MODULE_DLL
	#define MODULE_API			__declspec( dllimport )
	#define MODULE_CLASS		__declspec( dllimport )
#else
	#define MODULE_API			__declspec( dllexport )
	#define MODULE_CLASS		__declspec( dllexport )
#endif

/******************************************************************************/
#endif// MODULEDLL_BEC4C7B0_327C_463B_A33A_C29891DA3E66_H__