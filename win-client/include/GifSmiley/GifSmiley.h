
/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Dec 19 17:45:04 2007
 */
/* Compiler settings for .\_GifSmiley.idl:
    Oicf, W1, Zp8, env=Win32 (32b run)
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
//@@MIDL_FILE_HEADING(  )


#pragma warning( disable: 4049 )  /* more than 64k source lines */
#pragma once


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 475
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __GifSmiley_h__
#define __GifSmiley_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IGifSmileyCtrl_FWD_DEFINED__
#define __IGifSmileyCtrl_FWD_DEFINED__
typedef interface IGifSmileyCtrl IGifSmileyCtrl;
#endif  /* __IGifSmileyCtrl_FWD_DEFINED__ */


#ifndef __CGifSmileyCtrl_FWD_DEFINED__
#define __CGifSmileyCtrl_FWD_DEFINED__

#ifdef __cplusplus
typedef class CGifSmileyCtrl CGifSmileyCtrl;
#else
typedef struct CGifSmileyCtrl CGifSmileyCtrl;
#endif /* __cplusplus */

#endif  /* __CGifSmileyCtrl_FWD_DEFINED__ */


/* header files for imported files */
#include "prsht.h"
#include "mshtml.h"
#include "mshtmhst.h"
#include "exdisp.h"
#include "objsafe.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 

#ifndef __IGifSmileyCtrl_INTERFACE_DEFINED__
#define __IGifSmileyCtrl_INTERFACE_DEFINED__

/* interface IGifSmileyCtrl */
/* [unique][helpstring][dual][uuid][object] */ 

namespace GifSmiley {
	 //const IID IID_IGifSmileyCtrl;
#define DEFINE_GUIDXXX(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
	EXTERN_C const GUID CDECL name \
	= { l, w1, w2, { b1, b2, b3, b4, b5, b6, b7, b8 } }

	DEFINE_GUIDXXX(IID_IGifSmileyCtrl, 0xCB64102B, 0x8CE4, 0x4A55, 0xB0, 0x50,
		0x13, 0x1C, 0x43, 0x5A, 0x3A, 0x3F); 

#if defined(__cplusplus) && !defined(CINTERFACE)

	MIDL_INTERFACE("CB64102B-8CE4-4A55-B050-131C435A3A3F")
	IGifSmileyCtrl : public IDispatch
	{
	public:
		virtual /* [id][requestedit][bindable][propput] */ HRESULT STDMETHODCALLTYPE put_BackColor(
			/* [in] */ OLE_COLOR clr) = 0;

		virtual /* [id][requestedit][bindable][propget] */ HRESULT STDMETHODCALLTYPE get_BackColor(
			/* [retval][out] */ OLE_COLOR *pclr) = 0;

		virtual /* [id][requestedit][bindable][propget] */ HRESULT STDMETHODCALLTYPE get_HWND(
			/* [retval][out] */ long *pHWND) = 0;

		virtual /* [id] */ HRESULT STDMETHODCALLTYPE LoadFromFile(
			/* [in] */ BSTR bstrFileName) = 0;

		virtual /* [id] */ HRESULT STDMETHODCALLTYPE LoadFromFileSized(
			/* [in] */ BSTR bstrFileName,
			/* [in] */ INT nWidth,
			/* [in] */ INT nHeight) = 0;

		virtual /* [id] */ HRESULT STDMETHODCALLTYPE SetHostWindow(
			/* [in] */ long hwndHostWindow,
			/* [in] */ INT nNotyfyMode) = 0;

		virtual /* [id] */ HRESULT STDMETHODCALLTYPE FileName(
			/* [retval][out] */ BSTR* pVal) = 0;

		virtual /* [id] */ HRESULT STDMETHODCALLTYPE FreeImage(
			) = 0;

	};

#else   /* C style interface */

	typedef struct IGifSmileyCtrlVtbl
	{
		BEGIN_INTERFACE

			HRESULT(STDMETHODCALLTYPE *QueryInterface)(
			IGifSmileyCtrl * This,
			/* [in] */ REFIID riid,
			/* [iid_is][out] */ void **ppvObject);

			ULONG(STDMETHODCALLTYPE *AddRef)(
				IGifSmileyCtrl * This);

			ULONG(STDMETHODCALLTYPE *Release)(
				IGifSmileyCtrl * This);

			HRESULT(STDMETHODCALLTYPE *GetTypeInfoCount)(
				IGifSmileyCtrl * This,
				/* [out] */ UINT *pctinfo);

			HRESULT(STDMETHODCALLTYPE *GetTypeInfo)(
				IGifSmileyCtrl * This,
				/* [in] */ UINT iTInfo,
				/* [in] */ LCID lcid,
				/* [out] */ ITypeInfo **ppTInfo);

			HRESULT(STDMETHODCALLTYPE *GetIDsOfNames)(
				IGifSmileyCtrl * This,
				/* [in] */ REFIID riid,
				/* [size_is][in] */ LPOLESTR *rgszNames,
				/* [in] */ UINT cNames,
				/* [in] */ LCID lcid,
				/* [size_is][out] */ DISPID *rgDispId);

			/* [local] */ HRESULT(STDMETHODCALLTYPE *Invoke)(
				IGifSmileyCtrl * This,
				/* [in] */ DISPID dispIdMember,
				/* [in] */ REFIID riid,
				/* [in] */ LCID lcid,
				/* [in] */ WORD wFlags,
				/* [out][in] */ DISPPARAMS *pDispParams,
				/* [out] */ VARIANT *pVarResult,
				/* [out] */ EXCEPINFO *pExcepInfo,
				/* [out] */ UINT *puArgErr);

			/* [id][requestedit][bindable][propput] */ HRESULT(STDMETHODCALLTYPE *put_BackColor)(
				IGifSmileyCtrl * This,
				/* [in] */ OLE_COLOR clr);

			/* [id][requestedit][bindable][propget] */ HRESULT(STDMETHODCALLTYPE *get_BackColor)(
				IGifSmileyCtrl * This,
				/* [retval][out] */ OLE_COLOR *pclr);

			/* [id][requestedit][bindable][propget] */ HRESULT(STDMETHODCALLTYPE *get_HWND)(
				IGifSmileyCtrl * This,
				/* [retval][out] */ long *pHWND);

			/* [id] */ HRESULT(STDMETHODCALLTYPE *LoadFromFile)(
				IGifSmileyCtrl * This,
				/* [in] */ BSTR bstrFileName);

			/* [id] */ HRESULT(STDMETHODCALLTYPE *LoadFromFileSized)(
				IGifSmileyCtrl * This,
				/* [in] */ BSTR bstrFileName,
				/* [in] */ INT nWidth,
				/* [in] */ INT nHeight);

			/* [id] */ HRESULT(STDMETHODCALLTYPE *SetHostWindow)(
				IGifSmileyCtrl * This,
				/* [in] */ long hwndHostWindow,
				/* [in] */ INT nNotyfyMode);

		END_INTERFACE
	} IGifSmileyCtrlVtbl;

	interface IGifSmileyCtrl
	{
		CONST_VTBL struct IGifSmileyCtrlVtbl *lpVtbl;
	};



#ifdef COBJMACROS


#define IGifSmileyCtrl_QueryInterface(This,riid,ppvObject)      \
	(This)->lpVtbl->QueryInterface(This, riid, ppvObject)

#define IGifSmileyCtrl_AddRef(This)     \
	(This)->lpVtbl->AddRef(This)

#define IGifSmileyCtrl_Release(This)    \
	(This)->lpVtbl->Release(This)


#define IGifSmileyCtrl_GetTypeInfoCount(This,pctinfo)   \
	(This)->lpVtbl->GetTypeInfoCount(This, pctinfo)

#define IGifSmileyCtrl_GetTypeInfo(This,iTInfo,lcid,ppTInfo)    \
	(This)->lpVtbl->GetTypeInfo(This, iTInfo, lcid, ppTInfo)

#define IGifSmileyCtrl_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)  \
	(This)->lpVtbl->GetIDsOfNames(This, riid, rgszNames, cNames, lcid, rgDispId)

#define IGifSmileyCtrl_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)    \
	(This)->lpVtbl->Invoke(This, dispIdMember, riid, lcid, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr)


#define IGifSmileyCtrl_put_BackColor(This,clr)  \
	(This)->lpVtbl->put_BackColor(This, clr)

#define IGifSmileyCtrl_get_BackColor(This,pclr) \
	(This)->lpVtbl->get_BackColor(This, pclr)

#define IGifSmileyCtrl_get_HWND(This,pHWND)     \
	(This)->lpVtbl->get_HWND(This, pHWND)

#define IGifSmileyCtrl_LoadFromFile(This,bstrFileName)  \
	(This)->lpVtbl->LoadFromFile(This, bstrFileName)

#define IGifSmileyCtrl_LoadFromFileSized(This,bstrFileName,nWidth,nHeight)     \
	(This)->lpVtbl->LoadFromFileSized(This, bstrFileName, nWidth, nHeight)

#define IGifSmileyCtrl_SetHostWindow(This,hwndHostWindow,nNotyfyMode)   \
	(This)->lpVtbl->SetHostWindow(This, hwndHostWindow, nNotyfyMode)

#endif /* COBJMACROS */


#endif  /* C style interface */



	/* [id][requestedit][bindable][propput] */ HRESULT STDMETHODCALLTYPE IGifSmileyCtrl_put_BackColor_Proxy(
		IGifSmileyCtrl * This,
		/* [in] */ OLE_COLOR clr);


	void __RPC_STUB IGifSmileyCtrl_put_BackColor_Stub(
		IRpcStubBuffer *This,
		IRpcChannelBuffer *_pRpcChannelBuffer,
		PRPC_MESSAGE _pRpcMessage,
		DWORD *_pdwStubPhase);


	/* [id][requestedit][bindable][propget] */ HRESULT STDMETHODCALLTYPE IGifSmileyCtrl_get_BackColor_Proxy(
		IGifSmileyCtrl * This,
		/* [retval][out] */ OLE_COLOR *pclr);


	void __RPC_STUB IGifSmileyCtrl_get_BackColor_Stub(
		IRpcStubBuffer *This,
		IRpcChannelBuffer *_pRpcChannelBuffer,
		PRPC_MESSAGE _pRpcMessage,
		DWORD *_pdwStubPhase);


	/* [id][requestedit][bindable][propget] */ HRESULT STDMETHODCALLTYPE IGifSmileyCtrl_get_HWND_Proxy(
		IGifSmileyCtrl * This,
		/* [retval][out] */ long *pHWND);


	void __RPC_STUB IGifSmileyCtrl_get_HWND_Stub(
		IRpcStubBuffer *This,
		IRpcChannelBuffer *_pRpcChannelBuffer,
		PRPC_MESSAGE _pRpcMessage,
		DWORD *_pdwStubPhase);


	/* [id] */ HRESULT STDMETHODCALLTYPE IGifSmileyCtrl_LoadFromFile_Proxy(
		IGifSmileyCtrl * This,
		/* [in] */ BSTR bstrFileName);


	void __RPC_STUB IGifSmileyCtrl_LoadFromFile_Stub(
		IRpcStubBuffer *This,
		IRpcChannelBuffer *_pRpcChannelBuffer,
		PRPC_MESSAGE _pRpcMessage,
		DWORD *_pdwStubPhase);


	/* [id] */ HRESULT STDMETHODCALLTYPE IGifSmileyCtrl_LoadFromFileSized_Proxy(
		IGifSmileyCtrl * This,
		/* [in] */ BSTR bstrFileName,
		/* [in] */ INT nWidth,
		/* [in] */ INT nHeight);


	void __RPC_STUB IGifSmileyCtrl_LoadFromFileSized_Stub(
		IRpcStubBuffer *This,
		IRpcChannelBuffer *_pRpcChannelBuffer,
		PRPC_MESSAGE _pRpcMessage,
		DWORD *_pdwStubPhase);


	/* [id] */ HRESULT STDMETHODCALLTYPE IGifSmileyCtrl_SetHostWindow_Proxy(
		IGifSmileyCtrl * This,
		/* [in] */ long hwndHostWindow,
		/* [in] */ INT nNotyfyMode);


	void __RPC_STUB IGifSmileyCtrl_SetHostWindow_Stub(
		IRpcStubBuffer *This,
		IRpcChannelBuffer *_pRpcChannelBuffer,
		PRPC_MESSAGE _pRpcMessage,
		DWORD *_pdwStubPhase);



#endif  /* __IGifSmileyCtrl_INTERFACE_DEFINED__ */



#ifndef __GifSmiley_LIBRARY_DEFINED__
#define __GifSmiley_LIBRARY_DEFINED__

	/* library GifSmiley */
	/* [helpstring][custom][uuid][version] */


	 const IID LIBID_GifSmiley;
	 CLSID CLSID_CGifSmileyCtrl = { 0xDB35DD77, 0x55E2, 0x4905, { 0x80, 0x75, 0xEB, 0x35, 0x1B, 0xB5, 0xCB, 0xC1 } };
	// const CLSID CLSID_CGifSmileyCtrl;

	// struct __declspec(uuid("DB35DD77-55E2-4905-8075-EB351BB5CBC1")) CLSID_CGifSmileyCtrl;



#ifdef __cplusplus

	class DECLSPEC_UUID("DB35DD77-55E2-4905-8075-EB351BB5CBC1")
		CGifSmileyCtrl;
#endif
#endif /* __GifSmiley_LIBRARY_DEFINED__ */

	/* Additional Prototypes for ALL interfaces */

	unsigned long             __RPC_USER  BSTR_UserSize(unsigned long *, unsigned long, BSTR *);
	unsigned char * __RPC_USER  BSTR_UserMarshal(unsigned long *, unsigned char *, BSTR *);
	unsigned char * __RPC_USER  BSTR_UserUnmarshal(unsigned long *, unsigned char *, BSTR *);
	void                      __RPC_USER  BSTR_UserFree(unsigned long *, BSTR *);

	/* end of Additional Prototypes */
}
#ifdef __cplusplus
}
#endif

#endif
