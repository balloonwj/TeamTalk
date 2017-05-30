#include "stdafx.h"
#include "Modules.h"

#define CHECK_BOOL(exp)														\
	do {																	\
		if (!(exp))															\
		{																	\
			goto END0;														\
		}																	\
	} while (0)


BEGIN_MESSAGE_MAP(CModulesApp, CWinApp)
END_MESSAGE_MAP()

CModulesApp::CModulesApp()
{
}

CModulesApp theApp;

BOOL CModulesApp::InitInstance()
{
	CWinApp::InitInstance();

	return TRUE;
}
