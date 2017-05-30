

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 8.00.0603 */
/* at Mon May 15 22:24:51 2017
 */
/* Compiler settings for vc120.idl:
    Oicf, W1, Zp8, env=Win32 (32b run), target_arch=X86 8.00.0603 
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */

#pragma warning( disable: 4049 )  /* more than 64k source lines */


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

#ifndef __vc120_h__
#define __vc120_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IGifSmileyCtrl_FWD_DEFINED__
#define __IGifSmileyCtrl_FWD_DEFINED__
typedef interface IGifSmileyCtrl IGifSmileyCtrl;

#endif 	/* __IGifSmileyCtrl_FWD_DEFINED__ */


#ifndef __IGifSmileyCtrl2_FWD_DEFINED__
#define __IGifSmileyCtrl2_FWD_DEFINED__
typedef interface IGifSmileyCtrl2 IGifSmileyCtrl2;

#endif 	/* __IGifSmileyCtrl2_FWD_DEFINED__ */


#ifndef __CGifSmileyCtrl_FWD_DEFINED__
#define __CGifSmileyCtrl_FWD_DEFINED__

#ifdef __cplusplus
typedef class CGifSmileyCtrl CGifSmileyCtrl;
#else
typedef struct CGifSmileyCtrl CGifSmileyCtrl;
#endif /* __cplusplus */

#endif 	/* __CGifSmileyCtrl_FWD_DEFINED__ */


/* header files for imported files */
#include "prsht.h"
#include "mshtml.h"
#include "mshtmhst.h"
#include "exdisp.h"
#include "objsafe.h"

#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __IGifSmileyCtrl_INTERFACE_DEFINED__
#define __IGifSmileyCtrl_INTERFACE_DEFINED__

/* interface IGifSmileyCtrl */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IGifSmileyCtrl;

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
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_FileName( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE FreeImage( void) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IGifSmileyCtrlVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IGifSmileyCtrl * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IGifSmileyCtrl * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IGifSmileyCtrl * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IGifSmileyCtrl * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IGifSmileyCtrl * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IGifSmileyCtrl * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IGifSmileyCtrl * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        /* [id][requestedit][bindable][propput] */ HRESULT ( STDMETHODCALLTYPE *put_BackColor )( 
            IGifSmileyCtrl * This,
            /* [in] */ OLE_COLOR clr);
        
        /* [id][requestedit][bindable][propget] */ HRESULT ( STDMETHODCALLTYPE *get_BackColor )( 
            IGifSmileyCtrl * This,
            /* [retval][out] */ OLE_COLOR *pclr);
        
        /* [id][requestedit][bindable][propget] */ HRESULT ( STDMETHODCALLTYPE *get_HWND )( 
            IGifSmileyCtrl * This,
            /* [retval][out] */ long *pHWND);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *LoadFromFile )( 
            IGifSmileyCtrl * This,
            /* [in] */ BSTR bstrFileName);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *LoadFromFileSized )( 
            IGifSmileyCtrl * This,
            /* [in] */ BSTR bstrFileName,
            /* [in] */ INT nWidth,
            /* [in] */ INT nHeight);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *SetHostWindow )( 
            IGifSmileyCtrl * This,
            /* [in] */ long hwndHostWindow,
            /* [in] */ INT nNotyfyMode);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_FileName )( 
            IGifSmileyCtrl * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *FreeImage )( 
            IGifSmileyCtrl * This);
        
        END_INTERFACE
    } IGifSmileyCtrlVtbl;

    interface IGifSmileyCtrl
    {
        CONST_VTBL struct IGifSmileyCtrlVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IGifSmileyCtrl_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IGifSmileyCtrl_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IGifSmileyCtrl_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IGifSmileyCtrl_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IGifSmileyCtrl_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IGifSmileyCtrl_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IGifSmileyCtrl_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IGifSmileyCtrl_put_BackColor(This,clr)	\
    ( (This)->lpVtbl -> put_BackColor(This,clr) ) 

#define IGifSmileyCtrl_get_BackColor(This,pclr)	\
    ( (This)->lpVtbl -> get_BackColor(This,pclr) ) 

#define IGifSmileyCtrl_get_HWND(This,pHWND)	\
    ( (This)->lpVtbl -> get_HWND(This,pHWND) ) 

#define IGifSmileyCtrl_LoadFromFile(This,bstrFileName)	\
    ( (This)->lpVtbl -> LoadFromFile(This,bstrFileName) ) 

#define IGifSmileyCtrl_LoadFromFileSized(This,bstrFileName,nWidth,nHeight)	\
    ( (This)->lpVtbl -> LoadFromFileSized(This,bstrFileName,nWidth,nHeight) ) 

#define IGifSmileyCtrl_SetHostWindow(This,hwndHostWindow,nNotyfyMode)	\
    ( (This)->lpVtbl -> SetHostWindow(This,hwndHostWindow,nNotyfyMode) ) 

#define IGifSmileyCtrl_get_FileName(This,pVal)	\
    ( (This)->lpVtbl -> get_FileName(This,pVal) ) 

#define IGifSmileyCtrl_FreeImage(This)	\
    ( (This)->lpVtbl -> FreeImage(This) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IGifSmileyCtrl_INTERFACE_DEFINED__ */


#ifndef __IGifSmileyCtrl2_INTERFACE_DEFINED__
#define __IGifSmileyCtrl2_INTERFACE_DEFINED__

/* interface IGifSmileyCtrl2 */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IGifSmileyCtrl2;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("0418FB4B-E1AF-4e32-94AD-FF322C622AD3")
    IGifSmileyCtrl2 : public IDispatch
    {
    public:
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE SetHint( 
            /* [in] */ BSTR bstrHint) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE GetHint( 
            /* [retval][out] */ BSTR *bstrHint) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IGifSmileyCtrl2Vtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IGifSmileyCtrl2 * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IGifSmileyCtrl2 * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IGifSmileyCtrl2 * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IGifSmileyCtrl2 * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IGifSmileyCtrl2 * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IGifSmileyCtrl2 * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IGifSmileyCtrl2 * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *SetHint )( 
            IGifSmileyCtrl2 * This,
            /* [in] */ BSTR bstrHint);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE *GetHint )( 
            IGifSmileyCtrl2 * This,
            /* [retval][out] */ BSTR *bstrHint);
        
        END_INTERFACE
    } IGifSmileyCtrl2Vtbl;

    interface IGifSmileyCtrl2
    {
        CONST_VTBL struct IGifSmileyCtrl2Vtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IGifSmileyCtrl2_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IGifSmileyCtrl2_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IGifSmileyCtrl2_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IGifSmileyCtrl2_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IGifSmileyCtrl2_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IGifSmileyCtrl2_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IGifSmileyCtrl2_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IGifSmileyCtrl2_SetHint(This,bstrHint)	\
    ( (This)->lpVtbl -> SetHint(This,bstrHint) ) 

#define IGifSmileyCtrl2_GetHint(This,bstrHint)	\
    ( (This)->lpVtbl -> GetHint(This,bstrHint) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IGifSmileyCtrl2_INTERFACE_DEFINED__ */



#ifndef __GifSmiley_LIBRARY_DEFINED__
#define __GifSmiley_LIBRARY_DEFINED__

/* library GifSmiley */
/* [helpstring][uuid][version] */ 


EXTERN_C const IID LIBID_GifSmiley;

EXTERN_C const CLSID CLSID_CGifSmileyCtrl;

#ifdef __cplusplus

class DECLSPEC_UUID("DB35DD77-55E2-4905-8075-EB351BB5CBC1")
CGifSmileyCtrl;
#endif
#endif /* __GifSmiley_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  BSTR_UserSize(     unsigned long *, unsigned long            , BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserMarshal(  unsigned long *, unsigned char *, BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserUnmarshal(unsigned long *, unsigned char *, BSTR * ); 
void                      __RPC_USER  BSTR_UserFree(     unsigned long *, BSTR * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


