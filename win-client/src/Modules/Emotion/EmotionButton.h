#pragma once
#include "cxImage/cxImage/ximage.h"
#include "DuiLib/UIlib.h"
#include "GlobalDefine.h"
#include <map>
using namespace DuiLib;

class CEmotionButton : public CControlUI ,public INotifyUI
{
public:
	CEmotionButton(void);
	~CEmotionButton(void);
public:
	virtual void DoPaint(HDC hDC, const RECT& rcPaint);
	virtual void DoEvent(TEventUI& event);
	virtual void Notify(TNotifyUI& msg);
	void SetPage(int page);
	int GetCurrentPage();
	int GetPageCount();
public:
	//窗口大小
	int QQFACEDLG_WIDTH;
	int QQFACEDLG_HEIGHT;

	//网格左上角坐标
	int CELLS_LEFT;
	int CELLS_TOP;
	int CELLS_RIGHT;	//(6  + 29*15)
	int CELLS_BOTTOM;	//(28 + 29*8)

	int CELLSIZE; //每个网格= 29*30，（图片尺寸是24*24）

	int CELLCOUNT_LINE;	//每行
	int CELLCOUNT_COLUMN;	//每列
	int CELLCOUNT_PAGE; //每页120个表情

	const int TIMER_SHOWGIF = 101;	//定时器-显示动态GIF
	int curSel, lastSel; //当前Cell，上一次Cell，两个Cell行进交替
	int curPage;
	int frameCount;		//帧总数
	int curFrame;		//当前显示的动画帧
	TRACKMOUSEEVENT m_tme;

	HDC		m_hMemDCBkGnd;		//背景内存DC
	HDC		m_hMemDC;			//内存DC
	HBITMAP m_hMemBitmapBkGnd;	//背景位图
	HBITMAP m_hMemBitmap;		//内存位图

	//获取某个Cell的蓝色矩形框（选中时绘制）
	void GetBlueRect(int cellIndex, LPRECT pRect);

	int  GetCellIndex(int x, int y);

	//释放图片资源
	void FreeImages();

	//获取表情文件夹完整路径！
	void GetFaceFolderPath(TCHAR* path, TCHAR* folderName);

	int LoadImages(LPTSTR folder);
	int _LoadImages(IN CString folder);

	void SwitchPage(int curPage);

	CxImage* GetSelectedImage(int curPage, int curSel);
	//画图标的边框
	void UpdateSelectedFace(int curPage, int curSel, int curFrame, int pvstatus);

	//左，右两个缩略图矩形
	RECT	rcLeft, rcRight;
	int m_ImageCount;
	int m_PageCount; //页数 
	int pvstatus;		//当前显示那个矩形，-1-不显示，0-左侧，1-右侧
	CxImage* m_CxImages;

	//缩略图状态
	enum _PVStatus
	{
		Hide = 0,
		Left = 1,
		Right = 2,
	};

	//缩略图位置如何改变，高4位：之前显示状态，低4位：新的显示状态
	enum _PosChangeType
	{
		NoChange = 0,
		HideToLeft = 0x01,
		HideToRight = 0x02,
		LeftToHide = 0x10,
		LeftToRight = 0x12,
		RightToHide = 0x20,
		RightToLeft = 0x21,
	};

	std::map<UInt32, CString>	m_mapImagePath;
};
