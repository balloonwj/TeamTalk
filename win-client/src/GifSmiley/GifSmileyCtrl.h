#ifndef GifSmileyCtrl_h__
#define GifSmileyCtrl_h__

// GifSmileyCtrl.h : Declaration of the CGifSmileyCtrl
#pragma once
#include "resource.h"       // main symbols
#include "richedit.h"
#include "richole.h"
#include <atlctl.h>

#include "gdiplus.h"
#ifdef _MSC_VER
#include <delayimp.h>
#endif

#include <map>
#include <list>

#pragma comment(lib, "delayimp")
#pragma comment(lib, "gdiplus")

using namespace Gdiplus;
// IGifSmileyCtrl
[
	object,
	uuid(CB64102B-8CE4-4A55-B050-131C435A3A3F),
	dual,
	helpstring("IGifSmileyCtrl Interface"),
	pointer_default(unique)
]
__interface IGifSmileyCtrl : public IDispatch
{
	[propput, bindable, requestedit, id(DISPID_BACKCOLOR)]
	HRESULT BackColor([in]OLE_COLOR clr);
	[propget, bindable, requestedit, id(DISPID_BACKCOLOR)]
	HRESULT BackColor([out,retval]OLE_COLOR* pclr);
	[propget, bindable, requestedit, id(DISPID_HWND)]
	HRESULT HWND([out, retval]long* pHWND);  
	//Methods
	[id(1)]	HRESULT LoadFromFile( [in] BSTR bstrFileName );
	[id(2)]	HRESULT LoadFromFileSized([in] BSTR bstrFileName, [in] INT nWidth,[in] INT nHeight);
	[id(3)]	HRESULT SetHostWindow( [in] long hwndHostWindow, [in] INT nNotyfyMode );
	[propget, id(4), helpstring("property FileName")] HRESULT FileName([out, retval] BSTR* pVal); 
	[id(5)]	HRESULT FreeImage();	
};


// IGifSmileyCtrl2
[
	object,
	uuid(0418FB4B-E1AF-4e32-94AD-FF322C622AD3),
	dual,
	helpstring("IGifSmileyCtrl2 Interface"),
	pointer_default(unique)
]

__interface IGifSmileyCtrl2 : public IDispatch
{
	[id(4)] HRESULT SetHint( [in] BSTR bstrHint);
	[id(5)] HRESULT GetHint( [out, retval] BSTR * bstrHint);
};

//CGifSmileyCtrl
[
	coclass,
	control,
	default(IGifSmileyCtrl2),
	threading(apartment),
	vi_progid("GifSmiley.GifSmileyCtrl"),
	progid("GifSmiley.GifSmileyCtrl.1"),
	version(1.0),
	uuid("DB35DD77-55E2-4905-8075-EB351BB5CBC1"),
	helpstring("GifSmileyCtrl Class"),
	registration_script("control.rgs")
]

class ATL_NO_VTABLE CGifSmileyCtrl :
	public IGifSmileyCtrl2,
	public CComControl<CGifSmileyCtrl>,
	public IOleObjectImpl<CGifSmileyCtrl>,
	public IOleInPlaceObjectWindowlessImpl<CGifSmileyCtrl>,
	public CStockPropImpl<CGifSmileyCtrl, IGifSmileyCtrl>,
	public IViewObjectExImpl<CGifSmileyCtrl>,
	public IPersistStreamInitImpl<CGifSmileyCtrl>,
	public IPersistStorageImpl<CGifSmileyCtrl>,
	public IOleControlImpl<CGifSmileyCtrl>
{
public:

	DECLARE_OLEMISC_STATUS(OLEMISC_RECOMPOSEONRESIZE |
	OLEMISC_CANTLINKINSIDE |
		OLEMISC_INSIDEOUT |
		OLEMISC_ACTIVATEWHENVISIBLE |
		OLEMISC_SETCLIENTSITEFIRST
		)

		BEGIN_COM_MAP(CGifSmileyCtrl)
			COM_INTERFACE_ENTRY(IGifSmileyCtrl2)
			COM_INTERFACE_ENTRY(IGifSmileyCtrl)
			COM_INTERFACE_ENTRY(IOleControl)
			COM_INTERFACE_ENTRY(IOleObject)
			COM_INTERFACE_ENTRY(IPersistStreamInit)
			COM_INTERFACE_ENTRY2(IPersist, IPersistStreamInit)
			COM_INTERFACE_ENTRY(IPersistStorage)
		END_COM_MAP()

		BEGIN_PROP_MAP(CGifSmileyCtrl)
			//PROP_ENTRY("BackColor", DISPID_BACKCOLOR, CLSID_StockColorPage)
		END_PROP_MAP()


		BEGIN_MSG_MAP(CGifSmileyCtrl)
			CHAIN_MSG_MAP(CComControl<CGifSmileyCtrl>)
			DEFAULT_REFLECTION_HANDLER()
		END_MSG_MAP()

		DECLARE_PROTECT_FINAL_CONSTRUCT()

public:

	static HRESULT _InitModule();
	static HRESULT _UninitModule();

	// methods
	CGifSmileyCtrl();
	~CGifSmileyCtrl();
	HRESULT IPersistStreamInit_Load(LPSTREAM pStm,const ATL_PROPMAP_ENTRY* pMap);
	HRESULT IPersistStreamInit_Save(LPSTREAM pStm, BOOL fClearDirty,const ATL_PROPMAP_ENTRY* pMap);
	HRESULT FireViewChange();
	HRESULT OnDrawAdvanced(ATL_DRAWINFO& di);

	HRESULT FreeImage();
	HRESULT LoadFromFile( BSTR bstrFileName );
	HRESULT LoadFromFileSized( BSTR bstrFileName, INT nWidth,INT nHeight );        
	HRESULT SetHostWindow (long hwndHostWindow, INT nNotyfyMode ); 
	void	OnBackColorChanged();
	HRESULT FinalConstruct() {	return S_OK;}
	void	FinalRelease(){}
	HRESULT SetHint( BSTR bstrHint)  { m_strHint=bstrHint; return S_OK; }
	HRESULT GetHint( BSTR * bstrHint) { *bstrHint = m_strHint.AllocSysString(); return S_OK; } 
public:
	//  properties:    
	OLE_COLOR	m_clrBackColor;
	SIZEL		m_sizeExtent;

private:
	typedef std::map<UINT_PTR, CGifSmileyCtrl*> MAPTIMER;
	typedef std::list<class ImageItem* > LISTIMAGES;
	typedef std::list<class CGifSmileyCtrl* > LISTSMILEYS;
	typedef std::map<HWND, struct HostWindowData> MAPHOSTINFO;
	typedef std::map<DWORD, DWORD> MAPOBJECTS; 
	static int         _refCount;
	static ULONG_PTR   _gdiPlusToken;
	static bool        _gdiPlusFail;
	static int         _gdiPlusRefCount;
	static MAPTIMER    _mapTimers;
	static LISTIMAGES  _listImages;
	static LISTSMILEYS _listSmileys; 
	static UINT_PTR	   _purgeImageListTimerId; 

	ATL::CString m_strHint;
	Bitmap * m_pGifImage;
	UINT   * m_pDelays;
	UINT     m_nFrameCount;
	Size     m_nFrameSize;
	BOOL     m_bTransparent;
	UINT     m_nCurrentFrame;
	UINT_PTR m_nTimerId;
	bool     m_nAnimated;
	HWND	 m_hwndParent;
	ATL::CString m_strFilename;
	RECT	 m_rectPos;
	bool	 m_bPaintValid;
	INT		 m_nNotifyMode;		//0 - none, 1 - empty, 2 - before, 3 - after
	DWORD	 m_dwFlags; 
private:  
	bool CopySmile( long hwndHostWindow, BSTR bstrFileName, OLE_COLOR clr, INT cy);
	static bool _InitGdiPlus();
	static void _DestroyGdiPlus();
	static VOID CALLBACK TimerProc( HWND, UINT, UINT_PTR, DWORD );   
	static VOID CALLBACK PurgeImageListTimerProc( HWND, UINT, UINT_PTR, DWORD );   
 
	BOOL		IsVisible(ATL_DRAWINFO& di);
	BOOL		SelectSmileyClipRgn(HDC hDC, RECT& SmileyPos, HRGN& hOldRegion, HRGN& hNewRegion,  BOOL bTuneBorder);
	void		ResetClip(HDC hDC, HRGN& hOldRgn, HRGN& hNewRgn );

	HRESULT		UpdateSmileyPos( long left, long bottom, long zoom, long flags );
	HRESULT		OnDrawSmiley(ATL_DRAWINFO& di, bool bCustom);
	void		DoDrawSmiley(HDC ,  RECT& , int , int , int , int );
	HRESULT		UnloadImage( );
	void		AdvanceFrame();
	void		OnTimer();    
	HRESULT		OnDraw(ATL_DRAWINFO& di);
	void		doRelease();
	STDMETHOD(get_FileName)(BSTR* pVal); 
};

class ImageItem
{  
private:
	ATL::CString m_strFilename;
	int          m_nHeight;
	Bitmap*      m_pBitmap;
	int          m_nRef;  
	UINT*        m_pFrameDelays;
	int          m_nFrameCount;
	Size         m_FrameSize;
public:
	ImageItem();
	~ImageItem();
	Bitmap* LoadImageFromFile(ATL::CString& strFilename, int nWidth, int nHeight);
	bool UnloadImage();
	bool IsEqual(ATL::CString& strFilename, int nHeight);
	bool IsEqual(Bitmap * pBitmap);
	int  GetRefCount();
	UINT * GetFrameDelays(); 
	UINT GetFrameCount();
	Size GetFrameSize();
};

struct HostWindowData
{
	HWND hwnd;
	WNDPROC pOldProc; 
	HostWindowData(): hwnd(NULL), pOldProc(NULL) {};
};

#endif // GifSmileyCtrl_h__