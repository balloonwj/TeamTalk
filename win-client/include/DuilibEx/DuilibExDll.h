#pragma once

#ifndef DUILIBEX_DLL
	#define DUILIBEX_API		__declspec( dllimport )
	#define DUILIBEX_DATA		__declspec( dllimport )
	#define DUILIBEX_CLASS		AFX_CLASS_IMPORT
#else
	#define DUILIBEX_API		__declspec( dllexport )
	#define DUILIBEX_DATA		__declspec( dllexport )
	#define DUILIBEX_CLASS		AFX_CLASS_EXPORT
#endif