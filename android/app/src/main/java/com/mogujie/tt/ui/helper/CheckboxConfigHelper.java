package com.mogujie.tt.ui.helper;

import android.view.View;
import android.widget.CheckBox;

import com.mogujie.tt.DB.sp.ConfigurationSp;
import com.mogujie.tt.utils.Logger;

import java.util.HashSet;
import java.util.TreeSet;

// 配置滑动按钮的简单封装
public class CheckboxConfigHelper {
    private Logger logger = Logger.getLogger(CheckboxConfigHelper.class);
	private ConfigurationSp configMgr;
	public CheckboxConfigHelper() {
	}
    public void init(ConfigurationSp configMgr){
        this.configMgr = configMgr;
    }

    public void initTopCheckBox(final CheckBox checkBox, final String sessionKey){
        if (configMgr == null || checkBox == null) {
            logger.e("config#configMgr is null");
            return;
        }
        boolean shouldCheck = false;
        HashSet<String> topList = configMgr.getSessionTopList();
        if(topList != null && topList.size() >0){
            shouldCheck = topList.contains(sessionKey);
        }
        checkBox.setChecked(shouldCheck);

        checkBox.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                configMgr.setSessionTop(sessionKey, checkBox.isChecked());
            }
        });
    }

	public void initCheckBox(CheckBox checkBox,String key,ConfigurationSp.CfgDimension dimension) {
		handleCheckBoxChanged(checkBox,key,dimension);
		configCheckBox(checkBox,key,dimension);
	}

	private void configCheckBox(CheckBox checkBox,String key,ConfigurationSp.CfgDimension dimension) {

		if (configMgr == null) {
			logger.e("config#configMgr is null");
			return;
		}

		boolean shouldCheck = configMgr.getCfg(key,dimension);
		logger.d("config#%s is set %s", dimension, shouldCheck);
		checkBox.setChecked(shouldCheck);
	}

	private void handleCheckBoxChanged(final CheckBox checkBox,final String key,final ConfigurationSp.CfgDimension dimension) {
		if (checkBox == null || configMgr == null) {
			return;
		}

		checkBox.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				configMgr.setCfg(key,dimension,checkBox.isChecked());
			}
		});
	}
}
