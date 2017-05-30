/*******************************************************************************
 *  @file      SysConfigModule_Impl.h 2014\8\4 10:56:38 $
 *  @author    快刀<kuaidao@mogujie.com>
 *  @brief     系统配置信息，包括系统设置和全局配置信息
 ******************************************************************************/

#ifndef SYSCONFIGMODULE_IMPL_9E63D68E_676C_49DB_A936_7F97A626D551_H__
#define SYSCONFIGMODULE_IMPL_9E63D68E_676C_49DB_A936_7F97A626D551_H__


#include "Modules/ISysConfigModule.h"
/******************************************************************************/

namespace module
{
	IOperationDelegate;
}
/**
 * The class <code>系统配置信息，包括系统设置和全局配置信息</code> 
 *
 */
class SysConfigModule_Impl final : public module::ISysConfigModule
{
public:
    /** @name Constructors and Destructor*/

    //@{
    /**
     * Constructor 
     */
    SysConfigModule_Impl();
    /**
     * Destructor
     */
    virtual ~SysConfigModule_Impl();
    //@}

public:
	virtual module::TTConfig* getSystemConfig();
	virtual BOOL saveData();
	virtual std::string userID()const;
	virtual CString UserID()const;
	virtual UInt32 userId()const;
	virtual void showSysConfigDialog(HWND hParentWnd);
	virtual BOOL showServerConfigDialog(HWND hParentWnd);
	virtual void setSysConfigDialogFlag(BOOL bIsExist);

	virtual UInt32 getUserInfoLatestUpdateTime(void);//总的用户更新时间
	virtual void saveUserInfoLatestUpdateTime(IN const UInt32 nLatestUpdateTime);

	virtual UInt32 getDepartmentInfoLatestUpdateTime(void);
	virtual void saveDepartmentInfoLatestUpdateTime(IN const UInt32 nLatestUpdateTime);

	virtual UInt32 getRecentSessionLatestUpdateTime(void);
	virtual void saveRecentSessionLatestUpdateTime(IN const UInt32 nLatestUpdateTime);

	//TODO 统一图片获取的逻辑
	virtual BOOL getImage(IN std::string sid, IN std::string url, IN BOOL bGrayScale
		, IN std::string& format, IN module::IOperationDelegate callback
		, OUT std::string& sLocalPath);
private:
	/**
	 * 加载序列化的数据
	 *
	 * @return  BOOL
	 * @exception there is no any exception to throw.
	 */	
	BOOL _loadData();
	/**
	* 保存序列化的数据
	*
	* @return  BOOL
	* @exception there is no any exception to throw.
	*/
	BOOL _saveData();
	/**
	 * 反序列化
	 *
	 * @param   CArchive & ar
	 * @return  void
	 * @exception there is no any exception to throw.
	 */
	void _unMarshal(CArchive& ar);
	/**
	* 序列化
	*
	* @param   CArchive & ar
	* @return  void
	* @exception there is no any exception to throw.
	*/
	void _marshal(CArchive& ar);

private:
	module::TTConfig			m_Config;
	BOOL						m_bSysConfigDialogFlag;//确保单个窗口实例
};
/******************************************************************************/
#endif// SYSCONFIGMODULE_IMPL_9E63D68E_676C_49DB_A936_7F97A626D551_H__
