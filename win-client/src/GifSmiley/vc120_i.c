

/* this ALWAYS GENERATED file contains the IIDs and CLSIDs */

/* link this file in with the server and any clients */


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


#ifdef __cplusplus
extern "C"{
#endif 


#include <rpc.h>
#include <rpcndr.h>

#ifdef _MIDL_USE_GUIDDEF_

#ifndef INITGUID
#define INITGUID
#include <guiddef.h>
#undef INITGUID
#else
#include <guiddef.h>
#endif

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        DEFINE_GUID(name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8)

#else // !_MIDL_USE_GUIDDEF_

#ifndef __IID_DEFINED__
#define __IID_DEFINED__

typedef struct _IID
{
    unsigned long x;
    unsigned short s1;
    unsigned short s2;
    unsigned char  c[8];
} IID;

#endif // __IID_DEFINED__

#ifndef CLSID_DEFINED
#define CLSID_DEFINED
typedef IID CLSID;
#endif // CLSID_DEFINED

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        const type name = {l,w1,w2,{b1,b2,b3,b4,b5,b6,b7,b8}}

#endif !_MIDL_USE_GUIDDEF_

MIDL_DEFINE_GUID(IID, IID_IGifSmileyCtrl,0xCB64102B,0x8CE4,0x4A55,0xB0,0x50,0x13,0x1C,0x43,0x5A,0x3A,0x3F);


MIDL_DEFINE_GUID(IID, IID_IGifSmileyCtrl2,0x0418FB4B,0xE1AF,0x4e32,0x94,0xAD,0xFF,0x32,0x2C,0x62,0x2A,0xD3);


MIDL_DEFINE_GUID(IID, LIBID_GifSmiley,0xAFA51984,0xFE21,0x4725,0xBE,0x31,0xD1,0x6F,0x4E,0xBD,0x0C,0x89);


MIDL_DEFINE_GUID(CLSID, CLSID_CGifSmileyCtrl,0xDB35DD77,0x55E2,0x4905,0x80,0x75,0xEB,0x35,0x1B,0xB5,0xCB,0xC1);

#undef MIDL_DEFINE_GUID

#ifdef __cplusplus
}
#endif



