
package com.mogujie.tt.ui.adapter;

import android.support.v4.view.PagerAdapter;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import com.mogujie.tt.utils.Logger;
import java.util.List;

public class ViewPageAdapter extends PagerAdapter {
    private List<GridView> mListViews;
    private Logger logger = Logger.getLogger(ViewPageAdapter.class);

    public ViewPageAdapter(List<GridView> mListViews) {
        this.mListViews = mListViews;// 构造方法，参数是我们的页卡，这样比较方便。
    }

    @Override
    public int getCount() {
        return mListViews.size();// 返回页卡的数量
    }

    @Override
    public int getItemPosition(Object object) {
        return super.getItemPosition(object);
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        try {
            container.removeView(mListViews.get(position));// 删除页卡
        } catch (Exception e) {
            logger.e(e.getMessage());
        }
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        try {
            container.addView(mListViews.get(position), 0);// 添加页卡
            return mListViews.get(position);
        } catch (Exception e) {
            logger.e(e.getMessage());
            return null;
        }
    }

    @Override
    public boolean isViewFromObject(View arg0, Object arg1) {
        return arg0 == arg1;// 官方建议这样写
    }

}
