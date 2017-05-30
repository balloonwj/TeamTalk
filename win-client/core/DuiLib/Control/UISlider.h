//===========================================================================================
//  2014.7.28 redrain修改，QQ：491646717，有疑问或者bug2请联系我
//	修改的代码的DoEvent部分的逻辑借鉴和复制了网友 快樂每一天（群昵称 花落半歌，QQ：848861075 ）的代码
//  问题说明：我正在制作仿酷狗播放器，做到音乐播放的部分时用到CSliderUI控件，后台的音频类回去控制CSliderUI的行为
//  CSliderUI的行为与酷狗的很不一样，有几样缺陷
//	问题1：只能通过点击CSliderUI的某个位置才能触发valuechanged消息，无法通过滑动滑块去触发，这个bug最严重
//  问题2：点击CSliderUI的某个位置，当鼠标弹起时滑块才改变位置，而其他软件都是鼠标按下时就改变了
//  问题3：后台有代码一直调用SetValue函数改变滑块的位置时，会和鼠标土洞滑块冲突，表现在滑块会一直来回跳动
//  问题4：滑块滑动过程中无法通知主窗体正在改变，这点用在音量改变时，通常我们是一边滑动一边就改变了音量，而不是滑动完成后再改变，
//       为此我们添加一个新的消息DUI_MSGTYPE_VALUECHANGED_MOVE，把这个消息的定义放到UIDefine.h文件中
//		 #define DUI_MSGTYPE_VALUECHANGED_MOVE      (_T("movevaluechanged"))
//		 出于效率考虑，要让CSliderUI发出这个消息，应该设置属性sendmove为真，默认为假
//
//	我修改的代码可以通过搜索字符串“2014.7.28 redrain”，来查找，方便大家查看源码
//	此次修改不会影响控件原有的属性，我个人水平有限，如果有任何问题，可以联系我
//===========================================================================================
#ifndef __UISLIDER_H__
#define __UISLIDER_H__

#pragma once

namespace DuiLib
{
	class UILIB_API CSliderUI : public CProgressUI
	{
	public:
		CSliderUI();

		LPCTSTR GetClass() const;
		UINT GetControlFlags() const;
		LPVOID GetInterface(LPCTSTR pstrName);

		void SetEnabled(bool bEnable = true);

		int GetChangeStep();
		void SetChangeStep(int step);
		void SetThumbSize(SIZE szXY);
		RECT GetThumbRect() const;
		LPCTSTR GetThumbImage() const;
		void SetThumbImage(LPCTSTR pStrImage);
		LPCTSTR GetThumbHotImage() const;
		void SetThumbHotImage(LPCTSTR pStrImage);
		LPCTSTR GetThumbPushedImage() const;
		void SetThumbPushedImage(LPCTSTR pStrImage);

		void DoEvent(TEventUI& event);//2014.7.28 redrain
		void SetAttribute(LPCTSTR pstrName, LPCTSTR pstrValue);
		void PaintStatusImage(HDC hDC);

		void SetValue(int nValue);//2014.7.28 redrain
		void SetCanSendMove(bool bCanSend);//2014.7.28 redrain
		bool GetCanSendMove() const;//2014.7.28 redrain
	protected:
		SIZE m_szThumb;
		UINT m_uButtonState;
		int m_nStep;

		CDuiString m_sThumbImage;
		CDuiString m_sThumbHotImage;
		CDuiString m_sThumbPushedImage;

		CDuiString m_sImageModify;
		bool	   m_bSendMove;//2014.7.28 redrain
	};
}

#endif // __UISLIDER_H__