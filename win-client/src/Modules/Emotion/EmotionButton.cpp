#include "stdafx.h"

#include "resource.h"
#include "EmotionButton.h"
#include "utility/utilStrCodingAPI.h"
#include "utility/utilCommonAPI.h"
#include "Modules/IEmotionModule.h"
#include "Modules/ITcpClientModule.h"
#include <list>
#include <Windows.h>
CEmotionButton::CEmotionButton(void)
{
	m_CxImages=NULL;
	  //窗口大小
	QQFACEDLG_WIDTH = 446;
	QQFACEDLG_HEIGHT = 239;  

		//网格左上角坐标
	CELLS_LEFT = 6;
	CELLS_TOP =3;
	CELLS_RIGHT = 441;	//(6  + 29*15)
	CELLS_BOTTOM = 259;	//(28 + 29*8)

	CELLSIZE = 29; //每个网格= 29*30，（图片尺寸是24*24）

	CELLCOUNT_LINE = 15;	//每行
	CELLCOUNT_COLUMN = 8;	//每列
	CELLCOUNT_PAGE = 120; //每页120个表情


	rcLeft.left = CELLS_LEFT+1;
	rcLeft.top = CELLS_TOP+1;
	rcLeft.right = rcLeft.left + (CELLSIZE*3-1);
	rcLeft.bottom = rcLeft.top + (CELLSIZE*3-1);

	rcRight.left = CELLS_LEFT+(CELLSIZE*12)+1;
	rcRight.top = CELLS_TOP+1;
	rcRight.right = rcRight.left + (CELLSIZE*3-1);
	rcRight.bottom = rcRight.top + (CELLSIZE*3-1);
	//开始时隐藏动画窗口
	pvstatus = _PVStatus::Hide;

	TCHAR facepath[MAX_PATH];
	GetFaceFolderPath(facepath, _T("..\\data\\Emotion\\Face"));
	//加载所有表情！
	m_ImageCount = LoadImages(facepath);
	//表情页数量
	m_PageCount = (m_ImageCount + CELLCOUNT_PAGE - 1) / CELLCOUNT_PAGE;
	curPage=0;

	//创建内存DC
	HDC hdc = GetDC(NULL);
	m_hMemDC = CreateCompatibleDC(hdc);
	m_hMemDCBkGnd = CreateCompatibleDC(hdc);	
	m_hMemBitmap = CreateCompatibleBitmap(hdc, QQFACEDLG_WIDTH, QQFACEDLG_HEIGHT);
	m_hMemBitmapBkGnd = CreateCompatibleBitmap(hdc, QQFACEDLG_WIDTH, QQFACEDLG_HEIGHT);
	ReleaseDC(NULL, hdc);

	SelectObject(m_hMemDC, m_hMemBitmap);
	SelectObject(m_hMemDCBkGnd, m_hMemBitmapBkGnd);

	TCHAR szPageInfo[16];
		//设置页信息
	wsprintf(szPageInfo, _T("%d/%d"), curPage+1, m_PageCount);

	SwitchPage(curPage);
}

CEmotionButton::~CEmotionButton(void)
{
	FreeImages();
}


int CEmotionButton::GetPageCount()
{
    return m_PageCount;
}

//释放图片资源
void CEmotionButton::FreeImages()
{
	if(m_CxImages != NULL)
	{
		delete[] m_CxImages;
		m_CxImages = NULL;
	}	
	m_ImageCount = 0;
}

//获取表情文件夹完整路径！
void CEmotionButton::GetFaceFolderPath(TCHAR* path, TCHAR* folderName)
{
	TCHAR *pChar;
	TCHAR temp[MAX_PATH];
	GetModuleFileName(NULL, temp, MAX_PATH);

	//查找倒数第一个反斜杠位置
	
	pChar=_tcsrchr(temp,'\\');
	if(pChar != NULL)
		*pChar = 0;//在反斜杠处截断字符串

	wsprintf(path, _T("%s\\%s"), temp, folderName);
}

void CEmotionButton::DoPaint(HDC hDC, const RECT& rcPaint)
{ 
	::BitBlt(hDC, 0, 0, QQFACEDLG_WIDTH, QQFACEDLG_HEIGHT, m_hMemDC, 0, 0, SRCCOPY);	
}

int CEmotionButton::GetCurrentPage()
{
    return curPage;
}

void CEmotionButton::SetPage(int page)
{
     curPage = page;	 
	 SwitchPage(curPage);
}

void CEmotionButton::DoEvent(TEventUI& event)
{
     switch( event.Type)
	 {
		 case UIEVENT_MOUSEMOVE:
		 {
				RECT rc1, rc2, invalidRect;
				int lastCol = -1, curCol = -1;

				unsigned char changetype = _PosChangeType::NoChange; //预览矩形是否需要改变

				POINT pt = event.ptMouse;
				int tmpSel = GetCellIndex(pt.x, pt.y);

				//是否超出了图片数量
				if((tmpSel + curPage * CELLCOUNT_PAGE) >= m_ImageCount)
					tmpSel = -1;

				if(tmpSel != curSel)
				{
					//两个cell 索引行进
					lastSel = curSel;
					curSel = tmpSel;
					curFrame = 0;

					//预览矩形需要移动吗？
					lastCol = (lastSel % 15);
					curCol = (curSel % 15); //每行15个

					GetBlueRect(lastSel, &rc1);
					GetBlueRect(curSel, &rc2);
					UnionRect(&invalidRect, &rc1, &rc2);
					invalidRect.right++;
					invalidRect.bottom++;

					//判断缩略矩形是否发生位置改变？
					if(pvstatus == _PVStatus::Hide)
					{
						if(curSel >= 0)
						{
							if((curSel%15) > 7)
							{
								pvstatus = _PVStatus::Left;
								changetype = _PosChangeType::HideToLeft;
							}
							else
							{
								pvstatus = _PVStatus::Right;
								changetype = _PosChangeType::HideToRight;
							}
						}
					}
					else if(pvstatus == _PVStatus::Left)
					{					
						if(curSel < 0)
						{
							pvstatus = _PVStatus::Hide;
							changetype = _PosChangeType::LeftToHide;
						}
						else if(curCol < 4 || (curCol == 4 && lastCol == 4))
						{
							pvstatus = _PVStatus::Right;
							changetype = _PosChangeType::LeftToRight;
						}
					}
					else if(pvstatus == _PVStatus::Right)
					{
						if(curSel < 0)
						{
							pvstatus = _PVStatus::Hide;
							changetype = _PosChangeType::RightToHide;
						}
						else if(curCol > 10 || (curCol == 10 && lastCol == 10))
						{
							pvstatus = _PVStatus::Left;
							changetype = _PosChangeType::RightToLeft;
						}
					}

					//刷新蓝色矩形框
					UpdateSelectedFace(curPage, curSel, curFrame, pvstatus);
					this->Invalidate();
					 					
					if(changetype == _PosChangeType::NoChange)
					{
						//刷新预览图片
						if(pvstatus == _PVStatus::Left)
						{
							this->Invalidate();
							//InvalidateRect(hDlg, &rcLeft, FALSE);
						}
						else if(pvstatus == _PVStatus::Right)
						{
							this->Invalidate();
							//InvalidateRect(hDlg, &rcRight, FALSE);
						}

					}
					else
					{
						CopyRect(&rc1, &rcLeft);
						CopyRect(&rc2, &rcRight);
						rc1.right++;
						rc1.bottom++;
						rc2.right++;
						rc2.bottom++; 

						//擦除原位置的缩略图
						switch(changetype & 0xf0)
						{
						case 0x00:
							break;
						case 0x10:
							this->Invalidate();
							//InvalidateRect(hDlg, &rc1, FALSE);
							break;
						case 0x20:
							this->Invalidate();
							//InvalidateRect(hDlg, &rc2, FALSE);
							break;
						}
						//显示新位置上的缩略图
						switch(changetype & 0x0f)
						{
						case 0x00:
							pvstatus = _PVStatus::Hide;
							break;
						case 0x01:
							this->Invalidate();
							//InvalidateRect(hDlg, &rc1, FALSE);
							break;
						case 0x02:
							this->Invalidate();
							//InvalidateRect(hDlg, &rc2, FALSE);
							break;
						}
					}

					//安装定时器（显示动画）
					if(curSel >= 0)
					{
						UINT frameDelay = 200;
						CxImage* pImg = GetSelectedImage(curPage, curSel);
						CxImage* pFrame = pImg->GetFrame(curFrame);

						//QQ表情的帧延时通常是10毫秒，显示速度过快，因此增大到50毫秒
						if(pFrame != NULL) frameDelay = max(frameDelay, pFrame->GetFrameDelay());

						frameCount = pImg->GetNumFrames();
 
						this->m_pManager->SetTimer(this, TIMER_SHOWGIF, frameDelay);
					}
					else
					{ 
						this->m_pManager->KillTimer(this, TIMER_SHOWGIF);
					}
				}
				
				//使系统通知我们 WM_MOUSELEAVE ;
				TrackMouseEvent(&m_tme); //注意版本需求：_WIN32_WINNT 0x0510
		 }
		 break;
		 case UIEVENT_MOUSELEAVE:
		 {
			if(curSel >= 0)
			{
				RECT rc;
				GetBlueRect(curSel, &rc);
				lastSel = curSel;
				curSel = -1;
				curFrame = 0;
				pvstatus = _PVStatus::Hide;
				UpdateSelectedFace(curPage, curSel, curFrame, pvstatus);
				this->Invalidate();
				//InvalidateRect(hDlg, &rc, FALSE);
			}
		 }
		 break;
		 case UIEVENT_TIMER:
		 {
			this->m_pManager->KillTimer(this, TIMER_SHOWGIF);

			if(curSel >= 0 && frameCount > 1)
			{
				CxImage *pImg = GetSelectedImage(curPage, curSel);
				CxImage *pFrame = NULL;
				UINT frameDelay = 200;

				LPRECT lpRect = (pvstatus == _PVStatus::Left)? &rcLeft:&rcRight;
				
				//移动到下一帧！
				curFrame = (curFrame + 1) % frameCount;

				//QQ表情的帧延时通常是10毫秒，显示速度过快，因此增大到100毫秒
				pFrame = pImg->GetFrame(curFrame);
				
				if(pFrame) frameDelay = max(frameDelay, pFrame->GetFrameDelay());
 
				UpdateSelectedFace(curPage, curSel, curFrame, pvstatus);
				this->Invalidate();
				//InvalidateRect(hDlg, lpRect, FALSE);

				//下一帧的定时时间
				this->m_pManager->SetTimer(this, TIMER_SHOWGIF, frameDelay);
			} 
		 }
		 break;
		case UIEVENT_BUTTONUP:
		{
			POINT pt = event.ptMouse;
			int curSel = GetCellIndex(pt.x, pt.y);
			int index = curPage * CELLCOUNT_PAGE + curSel; //从页内相对索引计算出绝对索引。
			if (index > -1 && index < (int)m_mapImagePath.size())
			{
				CString strPath = m_mapImagePath[index];
				module::EmotionParam* pEmotionParam = new module::EmotionParam();
				pEmotionParam->sid = module::getEmotionModule()->getCurEmotionWndSessionId();
				pEmotionParam->strPath = strPath;
				module::getEmotionModule()->asynNotifyObserver(module::KEY_EMOTION_SELECTED, std::shared_ptr<void>(pEmotionParam));
				::ShowWindow(m_pManager->GetPaintWindow(), SW_HIDE);
			}
		}
		break;
	 }
}

void CEmotionButton::Notify(TNotifyUI& msg)
{
	if (0 == _tcsicmp(msg.sType, DUI_MSGTYPE_TIMER))
	{
		
	}
}

//切换当前页时需要进行的更新
void CEmotionButton::SwitchPage(int curPage)
{
	if(NULL == m_CxImages)
		return ;
	int index, count, left, top, width, height;
	RECT rc; 

    this->Invalidate();	
	//先画背景
	TCHAR szBKImg[MAX_PATH] = {0};
	_sntprintf(szBKImg, MAX_PATH - 1, _T("file='bg.png' corner='4,4,2,2' fade='100'"));
	  
	CBitmap bmp;
	CString strBitmapPath = CPaintManagerUI::GetInstancePath() + _T("..\\data\\Emotion\\IDB_BKGND.bmp");
	HBITMAP hBlankBkGnd;
	hBlankBkGnd = (HBITMAP)LoadImage(AfxGetInstanceHandle(), strBitmapPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
	bmp.DeleteObject();
	HDC hTempDC = CreateCompatibleDC(m_hMemDCBkGnd);
	SelectObject(hTempDC, hBlankBkGnd);
	
	

	BitBlt(m_hMemDCBkGnd, 0, 0, QQFACEDLG_WIDTH, QQFACEDLG_HEIGHT, hTempDC, 0, 0, SRCCOPY);
	
	DeleteDC(hTempDC);
	DeleteObject(hBlankBkGnd);
	 
	//绘制当前页面的所有表情
	//绘制本页内所有图片
	for(index = (curPage * CELLCOUNT_PAGE), count = 0; (index< m_ImageCount && count < CELLCOUNT_PAGE); index++, count++)
	{
		//居中绘制
		GetBlueRect(count, &rc);

		long leftB = 0, topB = 0;
		if ((rc.left + rc.right) > (long)m_CxImages[index].GetWidth())
		{
			leftB = (long)((rc.left + rc.right - m_CxImages[index].GetWidth()) / 2);
		}
		if ((rc.top + rc.bottom) >(long)m_CxImages[index].GetHeight())
		{
			topB = (long)((rc.top + rc.bottom - m_CxImages[index].GetHeight()) / 2);
		}

		left = max(rc.left, leftB);
		top = max(rc.top, topB);
		width = min(int(m_CxImages[index].GetWidth()), CELLSIZE-1);
		height = min(int(m_CxImages[index].GetHeight()), CELLSIZE-1);

		m_CxImages[index].GetFrame(0)->Draw(m_hMemDCBkGnd, left, top, width, height);
	}

	//传送到内存位图	
	BitBlt(m_hMemDC, 0, 0, QQFACEDLG_WIDTH, QQFACEDLG_HEIGHT, m_hMemDCBkGnd, 0, 0, SRCCOPY); 
}

//鼠标在窗口上移动时需要进行的更新
void CEmotionButton::UpdateSelectedFace(int curPage, int curSel, int curFrame, int pvstatus)
{
	HGDIOBJ hOldBrush = NULL, hOldPen = NULL, hTempPen, hTempBrush;
	HPEN hPen1 = NULL;
	HPEN hPen2 = NULL;
	LPRECT lpRect = NULL;
	RECT rc;
	int index;

	//贴背景
	BitBlt(m_hMemDC, 0, 0, QQFACEDLG_WIDTH, QQFACEDLG_HEIGHT, m_hMemDCBkGnd, 0, 0, SRCCOPY);

	//绘制蓝色选中框
	if(curSel >= 0)
	{
		hPen1 = CreatePen(PS_SOLID, 1, RGB(0, 0, 255));
		hTempPen = SelectObject(m_hMemDC, hPen1);
		hTempBrush = SelectObject(m_hMemDC, GetStockObject(NULL_BRUSH));
		GetBlueRect(curSel, &rc);		
		Rectangle(m_hMemDC, rc.left, rc.top, rc.right, rc.bottom);

		if(hOldPen == NULL) hOldPen = hTempPen;
		if(hOldBrush == NULL) hOldBrush = hTempBrush;
	}

	//绘制左侧或者右侧的预览图
	if(pvstatus == _PVStatus::Left) lpRect = &rcLeft;
	else if(pvstatus == _PVStatus::Right) lpRect = &rcRight;

	if(lpRect != NULL)
	{
		index = curPage * CELLCOUNT_PAGE + curSel; //从页内相对索引计算出绝对索引。		
		hPen2 = CreatePen(PS_SOLID, 1, RGB(0, 138, 255)); //淡蓝色画笔		
		hTempPen = SelectObject(m_hMemDC, hPen2);
		hTempBrush = SelectObject(m_hMemDC, GetStockObject(WHITE_BRUSH)); //白色画刷
		Rectangle(m_hMemDC, lpRect->left, lpRect->top, lpRect->right, lpRect->bottom);
		//居中绘制
		int left = 0, top = 0;
		if ((lpRect->left + lpRect->right) > (long)m_CxImages[index].GetWidth())
		{
			left = (lpRect->left + lpRect->right - m_CxImages[index].GetWidth()) / 2;
		}
		if ((lpRect->top + lpRect->bottom) > (long)m_CxImages[index].GetHeight())
		{
			top = (lpRect->top + lpRect->bottom - m_CxImages[index].GetHeight()) / 2;
		}

		//设置帧
		if(curFrame < m_CxImages[index].GetNumFrames())
		{
			CxImage* pFrame = m_CxImages[index].GetFrame(curFrame);
			if (pFrame)
			{
				//hard code,compatible for yaya emotion
				if (left == 0 || top == 0)
				{
					pFrame->Draw(m_hMemDC, left, top, pFrame->GetWidth() - 10, pFrame->GetHeight() - 2);
				}
				else
				{
					pFrame->Draw(m_hMemDC, left, top);
				}
			}
			//m_CxImages[index].Draw(m_hMemDC, left, top);
		}
		if(hOldBrush == NULL) hOldBrush = hTempBrush;
		if(hOldPen == NULL) hOldPen = hTempPen;
	}
	
	//恢复画刷，画笔
	if(hOldBrush != NULL) SelectObject(m_hMemDC, hOldBrush);
	if(hOldPen != NULL)	SelectObject(m_hMemDC, hOldPen);

	if(hPen1 != NULL) DeleteObject(hPen1);
	if(hPen2 != NULL) DeleteObject(hPen2);
}



//提供客户区坐标，获取当前鼠标下方的网格索引
int  CEmotionButton::GetCellIndex(int x, int y)
{
	//点是否在网格范围内？
	//注意x >= CELLS_RIGHT (包含等于)
	if(x < CELLS_LEFT || x >= CELLS_RIGHT || y < CELLS_TOP || y >= CELLS_BOTTOM)
		return -1;

	//每行 15  个 CELL
	return (y - CELLS_TOP) / CELLSIZE * 15 + (x - CELLS_LEFT) / CELLSIZE;
}

//获取某个Cell的蓝色矩形框（选中时绘制）
void  CEmotionButton::GetBlueRect(int cellIndex, LPRECT pRect)
{
	pRect->left = CELLS_LEFT + CELLSIZE * (cellIndex % 15) + 1;
	pRect->top = CELLS_TOP + CELLSIZE * (cellIndex / 15) + 1;
	pRect->right = pRect->left + (CELLSIZE - 2);
	pRect->bottom = pRect->top + (CELLSIZE - 1);
}

//从指定的文件夹加载图片
int CEmotionButton::LoadImages(LPTSTR folder)
{
	TCHAR filter[MAX_PATH], filename[MAX_PATH];
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind;
	int index = 0, count = 0;

	//遍历获取到文件数目
	wsprintf(filter, _T("%s\\*.gif"), folder);
	hFind = FindFirstFile(filter, &FindFileData);
	if (hFind == INVALID_HANDLE_VALUE) 
	{
		return 0;
	} 
	else 
	{
		count++;
		while (FindNextFile(hFind, &FindFileData) != 0) 
		{
			count++;
		}
	}
	FindClose(hFind);

	if(count>0)
	{
		    m_CxImages = new CxImage[count];

			hFind = FindFirstFile(filter, &FindFileData);
			wsprintf(filename, _T("%s\\%s"), folder, FindFileData.cFileName);
			//m_Images[index++].Load(filename);
			m_CxImages[index].SetRetreiveAllFrames(true);
			m_mapImagePath[index] = filename;
			m_CxImages[index++].Load(filename, CXIMAGE_FORMAT_UNKNOWN);

			while (FindNextFile(hFind, &FindFileData) != 0) 
			{
				wsprintf(filename, _T("%s\\%s"), folder, FindFileData.cFileName);
				//m_Images[index++].Load(filename);
				m_CxImages[index].SetRetreiveAllFrames(true);
				m_mapImagePath[index] = filename;
				m_CxImages[index++].Load(filename, CXIMAGE_FORMAT_UNKNOWN);
			}
			FindClose(hFind);
	}
	
	return count;
}
int CEmotionButton::_LoadImages(IN CString folder)
{
	std::list<CString> listAllNames;
	module::getEmotionModule()->getAllEmotionFileNames(listAllNames);
	if (!listAllNames.empty())
	{
		m_CxImages = new CxImage[listAllNames.size()];
		UInt32 index = 0;
		for (CString strName : listAllNames)
		{
			CString fileName;
			fileName = folder + _T("\\") +strName;
			if (util::isFileExist(fileName))
			{
				m_CxImages[index].SetRetreiveAllFrames(true);
				m_mapImagePath[index] = fileName;
				m_CxImages[index++].Load(fileName, CXIMAGE_FORMAT_UNKNOWN);
			}
			else
			{
				LOG__(ERR, _T("Can't find the file:%s"),fileName);
				continue;
			}
		}
	}
	return listAllNames.size();
}


CxImage *CEmotionButton::GetSelectedImage(int curPage, int curSel)
{
	return m_CxImages + (curPage * CELLCOUNT_PAGE + curSel);
} 
