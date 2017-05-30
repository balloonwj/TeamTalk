#pragma once
#include "stdafx.h"
#include <atlctl.h>
#include "gdiplus.h"
using namespace Gdiplus;

float FitSize(Size& InSize, Size& ImageSize)
{
    float scaleX= (InSize.Width>0) ? (float)InSize.Width/ImageSize.Width : 0;
    float scaleY= (InSize.Height>0)? (float)InSize.Height/ImageSize.Height : 0;
    float scale=1;
    if (scaleX&&scaleY) 
        scale=min(scaleX, scaleY);
    else if ( scaleX||scaleY )
        scale = scaleX ? scaleX : scaleY;
    InSize.Width=(INT)(ImageSize.Width * scale);
    InSize.Height=(INT)(ImageSize.Height * scale);
    return scale;
}

BOOL GetBitmapFromFile(Bitmap* &m_pBitmap, ATL::CString& strFilename, 
                       int& m_nFrameCount, Size& m_FrameSize, Size& ImageSize,
                       UINT* &m_pFrameDelays )
{
    Bitmap * tempBitmap= new Bitmap(strFilename);    
    if (!tempBitmap) return FALSE;
    GUID   pageGuid = FrameDimensionTime;
    // Get the number of frames in the first dimension.
    m_nFrameCount = max(1, tempBitmap->GetFrameCount(&pageGuid));

    
    Size imSize(tempBitmap->GetWidth(),tempBitmap->GetHeight());
    m_FrameSize=ImageSize;
    float scale=FitSize(m_FrameSize,imSize);
    
    m_pBitmap=new Bitmap(m_FrameSize.Width*m_nFrameCount, m_FrameSize.Height, PixelFormat32bppARGB);

    Graphics *g=new Graphics(m_pBitmap);
    ImageAttributes attr;
    if ( scale!=1 ) 
    {
        g->SetInterpolationMode(InterpolationModeHighQualityBicubic);
        g->SetPixelOffsetMode(PixelOffsetModeHighQuality);            
        if ( scale<1 )
        {
            attr.SetGamma((REAL)1.2,ColorAdjustTypeBitmap); //some darker to made sharpen
        }
    }
    g->Clear(Color(0));
    if (m_nFrameCount>1)
    {
        m_pFrameDelays=new UINT[m_nFrameCount];
        int nSize = tempBitmap->GetPropertyItemSize(PropertyTagFrameDelay);
        // Allocate a buffer to receive the property item.
        PropertyItem* pDelays = (PropertyItem*) new char[nSize];
        tempBitmap->GetPropertyItem(PropertyTagFrameDelay, nSize, pDelays);
        for (int i=0; i<m_nFrameCount; i++)
        {
            GUID pageGuid = FrameDimensionTime;
            tempBitmap->SelectActiveFrame(&pageGuid, i);
            Rect rect(i*m_FrameSize.Width,0,m_FrameSize.Width, m_FrameSize.Height);
            if (scale>=1 )
                g->DrawImage(tempBitmap,rect,0,0,tempBitmap->GetWidth(),tempBitmap->GetHeight(), UnitPixel/*, &attr*/);
            else
            {
                Bitmap bm2(tempBitmap->GetWidth(),tempBitmap->GetHeight(), PixelFormat32bppARGB);
                Graphics g2(&bm2);
                g2.DrawImage(tempBitmap,Rect(0,0,bm2.GetWidth(),bm2.GetHeight()),0,0,tempBitmap->GetWidth(),tempBitmap->GetHeight(), UnitPixel);
                g->DrawImage(&bm2,rect,0,0,bm2.GetWidth(),bm2.GetHeight(), UnitPixel, &attr);
            }
            m_pFrameDelays[i]=10*max(((int*) pDelays->value)[i], 10);
        }   
		delete [] pDelays;
    }
    else
    {
        Rect rect(0,0,m_FrameSize.Width, m_FrameSize.Height);
        g->DrawImage(tempBitmap,rect,0,0,tempBitmap->GetWidth(),tempBitmap->GetHeight(), UnitPixel, &attr);
        m_pFrameDelays=NULL;
    }
    ImageSize=Size(tempBitmap->GetWidth(),tempBitmap->GetHeight());
    delete g;
    delete tempBitmap;
    return TRUE;
}