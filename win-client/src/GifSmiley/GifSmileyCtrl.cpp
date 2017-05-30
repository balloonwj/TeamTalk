// GifSmileyCtrl.cpp : Implementation of CGifSmileyCtrl
#include "stdafx.h"
#include "GifSmileyCtrl.h"
#include "tom.h"
#define DEFINE_GUIDXXX(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
	EXTERN_C const GUID CDECL name \
	= { l, w1, w2, { b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 } }
#include "m_anismiley.h"
#include ".\gifsmileyctrl.h"
DEFINE_GUIDXXX(IID_ITextDocument,0x8CC497C0,0xA1DF,0x11CE,0x80,0x98,
			   0x00,0xAA,0x00,0x47,0xBE,0x5D);

DEFINE_GUIDXXX(IID_IGifSmileyCtrl, 0xCB64102B, 0x8CE4, 0x4A55,0xB0,0x50,
			   0x13,0x1C,0x43,0x5A,0x3A,0x3F);

DEFINE_GUIDXXX(IID_IGifSmileyCtrl2, 0x0418FB4B, 0xE1AF, 0x4e32,0x94,0xAD,
			   0xFF,0x32,0x2C,0x62,0x2A,0xD3);



/////////////////////////////////////////////////////////////////////////////
// STATIC 
//////////////////////////////////////////////////////////////////////////
int         CGifSmileyCtrl::_refCount        = 0;
ULONG_PTR   CGifSmileyCtrl::_gdiPlusToken    = 0;
bool        CGifSmileyCtrl::_gdiPlusFail     = true;
int         CGifSmileyCtrl::_gdiPlusRefCount = 0;  
UINT_PTR    CGifSmileyCtrl::_purgeImageListTimerId      = 0;



CGifSmileyCtrl::MAPTIMER CGifSmileyCtrl::_mapTimers;
CGifSmileyCtrl::LISTIMAGES CGifSmileyCtrl::_listImages;  
extern "C" BOOL g_bGdiPlusFail=FALSE;

extern "C" BOOL InitModule()
{    
	return CGifSmileyCtrl::_InitModule();
}

extern "C" HRESULT UninitModule()
{
	return CGifSmileyCtrl::_UninitModule();
}

bool CGifSmileyCtrl::_InitGdiPlus(void)
{
	Gdiplus::GdiplusStartupInput gdiplusStartupInput;
	if (!g_bGdiPlusFail )
		CGifSmileyCtrl::_gdiPlusFail=false;

	__try 
	{
		if (_gdiPlusToken == 0 && !_gdiPlusFail)
		{
			Gdiplus::GdiplusStartup(&_gdiPlusToken, &gdiplusStartupInput, NULL);
		}
	}
	__except ( EXCEPTION_EXECUTE_HANDLER ) 
	{
		_gdiPlusFail = true;
		g_bGdiPlusFail=TRUE;
	}
	if (!_gdiPlusFail) _gdiPlusRefCount++;
	return !_gdiPlusFail;
}

void CGifSmileyCtrl::_DestroyGdiPlus(void)
{
	_gdiPlusRefCount--;
	if (_gdiPlusToken != 0 && _gdiPlusRefCount!=0)
	{
		Gdiplus::GdiplusShutdown(_gdiPlusToken);
		__FUnloadDelayLoadedDLL2("gdiplus.dll");
		_gdiPlusToken = 0;
	}
}


HRESULT  CGifSmileyCtrl::_InitModule()
{    
	_InitGdiPlus();
	return S_OK;

}
HRESULT  CGifSmileyCtrl::_UninitModule()
{
	_mapTimers.clear();

	LISTIMAGES::iterator it=_listImages.begin();   
	while (it!=_listImages.end())
	{
		delete (*it);
		it++;
	}
	_listImages.clear();
	_DestroyGdiPlus();

	return S_OK;
}
// CGifSmileyCtrl
CGifSmileyCtrl::CGifSmileyCtrl()
:m_pGifImage( NULL ), 
m_pDelays( NULL ),
m_nFrameCount( 0 ),
m_nFrameSize( 0, 0 ),
m_bTransparent( true ),
m_nCurrentFrame( 0 ),
m_nTimerId( 0 ),
m_hwndParent( NULL ),
m_bPaintValid( false )
{
	memset(&m_rectPos,0,sizeof(RECT));
	if (_refCount == 0)
	{
		_InitModule();
	}
	_refCount++; 
}
CGifSmileyCtrl::~CGifSmileyCtrl()
{
	UnloadImage(); 

	--_refCount;
	if (_refCount == 0)  
	{ 
		_UninitModule();
	}
}

void CGifSmileyCtrl::doRelease()
{
	LISTIMAGES::iterator it = _listImages.begin();
	while (it != _listImages.end())
	{
		if ((*it) && (*it)->GetRefCount() < 1)
		{
			delete(*it);
			it = _listImages.erase(it);
			continue;
		}
		it++;
	}
}

HRESULT CGifSmileyCtrl::UnloadImage( )
{
	if ( m_nTimerId ) 
		::KillTimer( NULL, m_nTimerId );
	if (m_pGifImage)
	{
		LISTIMAGES::iterator it=_listImages.begin();
		while (it!=_listImages.end())
		{
			if ((*it) && (*it)->IsEqual(m_pGifImage))
			{
				if ( (*it)->UnloadImage() && _purgeImageListTimerId==0 ) 
				{
					//_purgeImageListTimerId=::SetTimer(NULL,0, 1000, PurgeImageListTimerProc);
					doRelease();
				}
				break;
			}
			it++;
		}
	}
	m_nTimerId=NULL;   
	m_pGifImage=NULL;
	m_pDelays=NULL;
	m_nFrameCount=0;
	m_nCurrentFrame=0;
	m_nFrameSize=Size(0,0);
	m_sizeExtent.cx=0;
	m_sizeExtent.cy=0;

	return S_OK;
} 

bool CGifSmileyCtrl::CopySmile( long hwndHostWindow, BSTR bstrFileName, OLE_COLOR clr, INT cy)
{
	COLORREF backColor = (COLORREF)(clr);
	HWND hwnd = (HWND)(hwndHostWindow);
	HRESULT hr; 

	LPOLECLIENTSITE pOleSite;
	LPOLEOBJECT	lpObject=NULL;
	LPLOCKBYTES lpLockBytes = NULL;  

	// retrieve OLE interface for richedit  

	try
	{ 

		IOleObject *lpOleObject = NULL;    //OLE object
		QueryInterface(IID_IOleObject,(void**)&lpOleObject); 
		lpOleObject->GetClientSite(&pOleSite);

		//Load the gif
		LoadFromFileSized(bstrFileName, 0,cy);

		//Set back color
		OLE_COLOR oleBackColor=(OLE_COLOR)backColor;
		m_clrBackColor = oleBackColor;
		put_BackColor(oleBackColor);
		//myObject->put_BackColor(oleBackColor);

		//get the IOleObject
		hr = QueryInterface(IID_IOleObject, (void**)&lpObject);
		if (FAILED(hr))
		{
			return	 false;
		}

		//to insert into richedit, you need a struct of REOBJECT
		REOBJECT reobject;
		ZeroMemory(&reobject, sizeof(REOBJECT));

		reobject.cbStruct = sizeof(REOBJECT);	

		CLSID clsid;
		hr =  lpObject->GetUserClassID(&clsid);


		//set clsid
		reobject.clsid = clsid;
		//can be selected
		reobject.cp = REO_CP_SELECTION;
		//content, but not static
		reobject.dvaspect = DVASPECT_CONTENT;
		//goes in the same line of text line
		reobject.dwFlags = REO_BELOWBASELINE;
		reobject.dwUser = (DWORD)this;
		//the very object
		reobject.poleobj = lpObject;
		//client site contain the object
		reobject.polesite = pOleSite;
		//the storage 
		reobject.pstg = NULL;

		SIZEL sizel={0};
		reobject.sizel = sizel; 
		hr = SetHostWindow((long)hwnd, 0);

		//ole->InsertObject(&reobject);

		//redraw the window to show animation
		::RedrawWindow(hwnd,NULL, NULL, RDW_INVALIDATE);

		if (pOleSite)
		{
			pOleSite->Release();
			pOleSite = NULL;
		}
		if (lpObject)
		{
			lpObject->Release();
			lpObject = NULL;
		} 
	}
	catch( ... )
	{
		if (pOleSite)
		{
			pOleSite->Release();
			pOleSite = NULL;
		}
		if (lpObject)
		{
			lpObject->Release();
			lpObject = NULL;
		} 
		return FALSE;
	}
	return S_OK;
}

HRESULT CGifSmileyCtrl::FreeImage()
{
    UnloadImage();
	return S_OK;
}

HRESULT CGifSmileyCtrl::LoadFromFile( BSTR bstrFileName )
{
	return CGifSmileyCtrl::LoadFromFileSized( bstrFileName,(INT)0, (INT) 0 );
}

HRESULT CGifSmileyCtrl::LoadFromFileSized(BSTR bstrFileName,INT nWidth,INT nHeight)
{
	m_strFilename = bstrFileName;
	if ( _gdiPlusFail ) return E_FAIL;
	UnloadImage();
	ATL::CString sFilename(bstrFileName);
	ImageItem * foundImage=NULL;
	LISTIMAGES::iterator it=_listImages.begin();
	while (it!=_listImages.end())
	{
		if ((*it) && (*it)->IsEqual(sFilename,nHeight))
		{
			foundImage=(*it);
			break;
		}
		++it;
	}
	if (!foundImage)
	{
		foundImage=new ImageItem;
		_listImages.push_back(foundImage);
	}

	if (foundImage)
	{
		m_pGifImage=foundImage->LoadImageFromFile(sFilename,nWidth,nHeight);
		m_pDelays=foundImage->GetFrameDelays();
		m_nFrameCount=foundImage->GetFrameCount();
		m_nFrameSize=foundImage->GetFrameSize();
		if (m_nFrameSize.Width==0 || m_nFrameSize.Height==0)
		{
			UnloadImage();
			return E_FAIL;
		}
		SIZEL size;
		size.cx=m_nFrameSize.Width+2;
		size.cy=m_nFrameSize.Height;
		AtlPixelToHiMetric(&size,&m_sizeExtent);
		return S_OK;
	}
	return E_FAIL;    
} 

HRESULT CGifSmileyCtrl::UpdateSmileyPos( long left, long bottom, long zoom, long flags )
{
	int zoomnom=HIWORD(zoom);
	int zoomden=LOWORD(zoom);
	if (!zoomden) zoomden=1;
	m_rectPos.bottom=bottom;
	m_rectPos.left=left;
	m_rectPos.top=bottom-(m_nFrameSize.Height*zoomnom/zoomden);
	m_rectPos.right=left+(m_nFrameSize.Width*zoomnom/zoomden)+2;
	if (flags==1)
		m_bPaintValid=false;
	else
		m_bPaintValid=true;
	m_dwFlags=flags;
	return S_OK;
} 

BOOL CGifSmileyCtrl::SelectSmileyClipRgn(HDC hDC, RECT& SmileyPos, HRGN& hOldRegion,  HRGN& hNewRegion, BOOL bTuneBorder)
{
	hNewRegion=NULL;
	hOldRegion=NULL;

	if (!bTuneBorder)
	{
		hNewRegion=CreateRectRgn(SmileyPos.left, SmileyPos.top, SmileyPos.right, SmileyPos.bottom);
	}
	else if (m_hwndParent)
	{
		RECT rcParent;
		RECT rcVis;
		RECT wrc;
		POINT pt={0};

		::ClientToScreen(m_hwndParent, &pt);
		::GetClientRect(m_hwndParent, &rcParent);
		::GetWindowRect(m_hwndParent,&wrc);
		OffsetRect(&rcParent, pt.x-wrc.left, pt.y-wrc.top);

		IntersectRect(&rcVis, &rcParent, &SmileyPos);
		if (IsRectEmpty(&rcVis)) return FALSE;
		hNewRegion=CreateRectRgn(rcVis.left,rcVis.top,rcVis.right,rcVis.bottom);
	}
	else return FALSE;

	if (GetClipRgn(hDC,hOldRegion)!=1)
	{
		DeleteObject(hOldRegion);
		hOldRegion=NULL;
	}

	SelectClipRgn(hDC, hNewRegion);
	return TRUE;
}
void CGifSmileyCtrl::ResetClip(HDC hDC, HRGN& hOldRgn, HRGN& hNewRgn ) 
{
	if ( hOldRgn) SelectClipRgn( hDC, hOldRgn );
	if ( hOldRgn!=NULL ) DeleteObject( hOldRgn );
	if ( hNewRgn!=NULL ) DeleteObject( hNewRgn );
}

HRESULT CGifSmileyCtrl::OnDrawAdvanced(ATL_DRAWINFO& di)
{
	RECT& rc = *(RECT*)di.prcBounds;
	HRGN hOldRgn, hNewRgn;
	SelectSmileyClipRgn(di.hdcDraw, rc, hOldRgn, hNewRgn, FALSE);

	OnDraw(di);

	ResetClip(di.hdcDraw, hOldRgn, hNewRgn);

	return S_OK;
}

HRESULT CGifSmileyCtrl::OnDraw(ATL_DRAWINFO& di)
{
	return OnDrawSmiley(di,false);
}

HRESULT CGifSmileyCtrl::SetHostWindow( long hwndHostWindow, INT nNotyfyMode )
{
	m_hwndParent=(HWND)hwndHostWindow;
	m_nNotifyMode=nNotyfyMode; 
	return S_OK;

}

void CGifSmileyCtrl::DoDrawSmiley(HDC hdc, RECT& rc, int ExtentWidth, int ExtentHeight, int frameWidth, int frameHeight)
{
	Rect rect(0,0,ExtentWidth, ExtentHeight);    
	Bitmap bmp(ExtentWidth, ExtentHeight, PixelFormat32bppARGB );
	Graphics * mem=Graphics::FromImage(&bmp);        
	if (!m_bTransparent)
	{
		COLORREF col=(COLORREF)(m_clrBackColor);
		SolidBrush brush(Color(GetRValue(col),GetGValue(col),GetBValue(col)));
		mem->FillRectangle( &brush, 0 ,0, ExtentWidth, ExtentHeight);
	}

	mem->DrawImage(m_pGifImage, rect, m_nCurrentFrame*frameWidth, 0, frameWidth, frameHeight, UnitPixel);
	Graphics g(hdc);
	g.DrawImage(&bmp, rc.left, rc.top, ExtentWidth, ExtentHeight);
	delete mem;
}
BOOL CGifSmileyCtrl::IsVisible(ATL_DRAWINFO& di)
{
	//TO DO: check if smiley portion of parent window is really visible in case of obscured window
	//if (!::IsWindowVisible(m_hwndParent)) 
	//	return FALSE;
	if (!::RectVisible(di.hdcDraw,(RECT*)di.prcBounds)) 
		return FALSE;
	return TRUE;
}
HRESULT CGifSmileyCtrl::OnDrawSmiley(ATL_DRAWINFO& di, bool bCustom=false)
{
	USES_CONVERSION;
	if (di.dwDrawAspect != DVASPECT_CONTENT)
	{
		return E_FAIL;
	}
	if ( bCustom && !IsVisible(di))
	{
		return S_OK;
	}
	if (!m_pGifImage)
	{
		return E_FAIL;
	}
	RECT& rc = *(RECT*)di.prcBounds;

	HRGN hOldRgn, hNewRgn;

	if (!IsRectEmpty(&m_rectPos))
	{   //strange workaround for drawing zoom out smileys (look MS calculate it one pix larger than exactly)
		if (rc.bottom-rc.top-1 == m_rectPos.bottom-m_rectPos.top 
			&& rc.right-rc.left== m_rectPos.right-m_rectPos.left)
			rc.top+=1;
	}

	if ( bCustom )SelectSmileyClipRgn(di.hdcDraw, rc, hOldRgn, hNewRgn, TRUE);

	InflateRect(&rc,-1,0); //border offset to fix blinked cursor painting
	if ( (m_dwFlags&REO_INVERTEDSELECT) == 0 || !bCustom || m_bTransparent)
		DoDrawSmiley(di.hdcDraw, rc, rc.right-rc.left,rc.bottom-rc.top, m_nFrameSize.Width, m_nFrameSize.Height);
	else
	{
		Bitmap bmp(rc.right-rc.left,rc.bottom-rc.top, PixelFormat32bppARGB);
		Graphics g(&bmp);
		COLORREF col=(COLORREF)(m_clrBackColor);
		SolidBrush brush(Color(GetRValue(col),GetGValue(col),GetBValue(col)));
		g.FillRectangle( &brush, 0 ,0, rc.right-rc.left, rc.bottom-rc.top);
		HDC hdc=g.GetHDC();
		RECT mrc={0};
		mrc.right=rc.right-rc.left;
		mrc.bottom=rc.bottom-rc.top;
		DoDrawSmiley(hdc, mrc, mrc.right-mrc.left,mrc.bottom-mrc.top, m_nFrameSize.Width, m_nFrameSize.Height);
		InvertRect(hdc, &mrc);
		BitBlt(di.hdcDraw, rc.left, rc.top, rc.right-rc.left, rc.bottom-rc.top, hdc, 0, 0, SRCCOPY );
		g.ReleaseHDC(hdc);       
	}
	if ((m_dwFlags&REO_SELECTED) == REO_SELECTED && bCustom)
	{
		//Draw frame around
		HBRUSH oldBrush=(HBRUSH)SelectObject(di.hdcDraw, GetStockObject(NULL_BRUSH)); 
		HPEN oldPen=(HPEN)SelectObject(di.hdcDraw, GetStockObject(BLACK_PEN));
		::Rectangle(di.hdcDraw, rc.left, rc.top, rc.right, rc.bottom );
		SelectObject(di.hdcDraw, oldBrush);
		SelectObject(di.hdcDraw, oldPen);
	}
	AdvanceFrame();
	if (!bCustom) 
		m_bPaintValid=false;
	ResetClip(di.hdcDraw, hOldRgn, hNewRgn);

	return S_OK;
}


void CGifSmileyCtrl::OnBackColorChanged()
{
	if ( (m_clrBackColor&0xFF000000)==0xFF000000) 
		m_bTransparent=true;
	else
		m_bTransparent=false;
	FireViewChange();
}
 

inline HRESULT CGifSmileyCtrl::FireViewChange()
{
	if (m_bInPlaceActive)
	{
		// Active
		if (m_hWndCD != NULL)
			::InvalidateRect(m_hWndCD, NULL, m_bTransparent); // Window based
		else if (m_bWndLess && m_spInPlaceSite != NULL)
			m_spInPlaceSite->InvalidateRect(NULL, m_bTransparent); // Windowless
	}
	else if (!m_hwndParent)
	{
		SendOnViewChange(DVASPECT_CONTENT);
	}
	else
	{ 

		COLORREF oldColor=m_clrBackColor;
		BOOL     fOldTransparent= m_bTransparent;
		HWND     hwndOld=m_hwndParent; 
		FVCNDATA_NMHDR nmhdr={0};

		nmhdr.cbSize=sizeof(FVCNDATA_NMHDR);
		nmhdr.hwndFrom=hwndOld;
		nmhdr.code=NM_FIREVIEWCHANGE;
		nmhdr.clrBackground=oldColor;
		nmhdr.fTransparent=fOldTransparent;
		nmhdr.bAction= m_bPaintValid ? (fOldTransparent ? FVCA_INVALIDATE : FVCA_DRAW ) : FVCA_SENDVIEWCHANGE;
		nmhdr.rcRect=m_rectPos;
		//SendPrePaintEvent
		nmhdr.bEvent=FVCN_PREFIRE;
		
		//set members
		m_clrBackColor=nmhdr.clrBackground;
		m_bTransparent=nmhdr.fTransparent;
		m_hwndParent=nmhdr.hwndFrom;
		switch (nmhdr.bAction)
		{
		case FVCA_SKIPDRAW:
			AdvanceFrame();
			break;
		case FVCA_SENDVIEWCHANGE:
			SendOnViewChange(DVASPECT_CONTENT);
			::SendMessage(m_hwndParent, WM_PAINT, NULL, NULL);
			break;
		case FVCA_INVALIDATE:
			::InvalidateRect(m_hwndParent, &(nmhdr.rcRect), FALSE);
			break;
		case FVCA_DRAW:
		case FVCA_CUSTOMDRAW:
			ATL_DRAWINFO di;
			memset(&di,0,sizeof(ATL_DRAWINFO));
			di.cbSize=sizeof(ATL_DRAWINFO);
			di.dwDrawAspect=DVASPECT_CONTENT;
			if (nmhdr.bAction==FVCA_DRAW)
				di.hdcDraw=::GetWindowDC(m_hwndParent);
			else
				di.hdcDraw=nmhdr.hDC;
			RECTL rcl={nmhdr.rcRect.left, nmhdr.rcRect.top, nmhdr.rcRect.right, nmhdr.rcRect.bottom};
			di.prcBounds=&rcl;
			OnDrawSmiley(di,nmhdr.bAction==FVCA_DRAW);
			if (nmhdr.bAction==FVCA_DRAW)
				::ReleaseDC(m_hwndParent, di.hdcDraw);
			break;
		}
		//SendPostPaintEvent
		nmhdr.bEvent=FVCN_POSTFIRE;
		
		//restore members
		m_clrBackColor=oldColor;
		m_bTransparent=fOldTransparent;
		m_hwndParent=hwndOld;
	}

	return S_OK;
} 

VOID CALLBACK CGifSmileyCtrl::TimerProc(HWND hwnd,UINT /*uMsg*/,UINT_PTR idEvent, DWORD /*dwTime*/)
{
	CGifSmileyCtrl * me=NULL;//(CGifSmileyCtrl*)idEvent;
	::KillTimer(hwnd, idEvent);
	MAPTIMER::iterator it=_mapTimers.find(idEvent);
	if (it!=_mapTimers.end())
	{
		me=it->second;
		_mapTimers.erase(it);        
	}

	if ( me )  
	{       
		me->OnTimer();
	}
}

VOID CALLBACK CGifSmileyCtrl::PurgeImageListTimerProc( HWND, UINT, UINT_PTR, DWORD )
{
	::KillTimer(NULL, _purgeImageListTimerId);
	LISTIMAGES::iterator it = _listImages.begin();
	while (it != _listImages.end())
	{
		if ((*it) && (*it)->GetRefCount() < 1)
		{
			delete(*it);
			it = _listImages.erase(it);
			continue;
		}
		it++;
	}
} 

void CGifSmileyCtrl::AdvanceFrame()
{
	if ( m_nFrameCount > 1 &&  m_nTimerId == 0)
	{  
		int DelayTime  = 0; 
		m_nTimerId=::SetTimer( NULL /*_hwndTimerWnd*/, (UINT_PTR) this, m_pDelays[m_nCurrentFrame] * (DelayTime + 1), TimerProc ); 
		_mapTimers[m_nTimerId]=this;
	}
}

void CGifSmileyCtrl::OnTimer()
{
	m_nTimerId=NULL;
	m_nCurrentFrame=(m_nCurrentFrame+1)%m_nFrameCount;
	FireViewChange();
}

ImageItem::ImageItem() : 
m_nRef( 0 ), 
m_pBitmap( NULL ),
m_nFrameCount( 0 ),
m_pFrameDelays( NULL ),
m_nHeight( 0 )
{

}
ImageItem::~ImageItem()
{
	delete m_pBitmap;
	m_pBitmap = 0;
	if (m_pFrameDelays)
	{
		delete[] m_pFrameDelays;
		m_pFrameDelays = 0;
	}
}
BOOL GetBitmapFromFile(Bitmap* &m_pBitmap, ATL::CString& strFilename, 
					   int& m_nFrameCount, Size& m_FrameSize, Size& ImageSize,
					   UINT* &m_pFrameDelays );

Bitmap * ImageItem::LoadImageFromFile(ATL::CString& strFilename, int nWidth, int nHeight)
{
	if ( !m_strFilename.CompareNoCase(strFilename) && nHeight==m_nHeight )
	{
		m_nRef++;
		return m_pBitmap;
	}
	else if ( m_pBitmap==NULL && m_nRef==0)
	{
		Size ImageSize(nWidth, nHeight);
		if (GetBitmapFromFile(m_pBitmap, strFilename, m_nFrameCount, m_FrameSize, ImageSize, m_pFrameDelays ))
		{
			m_nHeight = nHeight;
			m_nRef++;
			m_strFilename=strFilename;
			return m_pBitmap;
		}
		return NULL;

	}
	//NOT REACHABLE
	DebugBreak();
	return NULL;
}

bool ImageItem::UnloadImage()
{
	m_nRef--;
	if (m_nRef < 1)  
		return true;
	return false;
}

bool ImageItem::IsEqual(Bitmap * pBitmap)
{
	return (pBitmap == m_pBitmap);
}

bool ImageItem::IsEqual(ATL::CString& strFilename, int nHeight)
{
	return (!m_strFilename.CompareNoCase(strFilename) && m_nHeight == nHeight);
}

int ImageItem::GetRefCount()
{
	return m_nRef;
}

UINT * ImageItem::GetFrameDelays()
{
	return m_pFrameDelays;
}

UINT ImageItem::GetFrameCount()
{
	return m_nFrameCount;
}

Size ImageItem::GetFrameSize()
{
	return m_FrameSize;
}

HRESULT CGifSmileyCtrl::IPersistStreamInit_Load(LPSTREAM pStm,const ATL_PROPMAP_ENTRY* pMap)
{
	HRESULT hr = S_OK;
	INFO_GIF infoGif;
	hr = pStm->Read(&infoGif, sizeof(INFO_GIF), NULL);

	hr = IPersistStreamInitImpl<CGifSmileyCtrl>::IPersistStreamInit_Load( pStm, pMap);

	CopySmile(infoGif.hwndFrom, infoGif.filePath, infoGif.clrBackground, 0);
	return hr;
}

HRESULT CGifSmileyCtrl::IPersistStreamInit_Save(LPSTREAM pStm, BOOL fClearDirty,const ATL_PROPMAP_ENTRY* pMap)
{
	INFO_GIF infoGif;;
	wsprintf(infoGif.filePath, m_strFilename.GetBuffer());
	infoGif.hwndFrom = (LONG)m_hwndParent;
	infoGif.clrBackground = m_clrBackColor;
	pStm->Write(&infoGif, sizeof(INFO_GIF),NULL);
	return IPersistStreamInitImpl<CGifSmileyCtrl>::IPersistStreamInit_Save( pStm, fClearDirty, pMap);
}
STDMETHODIMP CGifSmileyCtrl::get_FileName(BSTR* pVal)
{
	*pVal = m_strFilename.AllocSysString();
	return S_OK;
}
