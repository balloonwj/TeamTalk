
package com.mogujie.tt.ui.widget;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.mogujie.tt.R;
import com.mogujie.tt.ui.adapter.ViewPageAdapter;
import com.mogujie.tt.ui.adapter.YayaEmoGridViewAdapter;
import com.mogujie.tt.config.SysConstant;
import com.mogujie.tt.ui.helper.Emoparser;
import com.mogujie.tt.utils.CommonUtil;

import java.util.ArrayList;
import java.util.List;

public class YayaEmoGridView extends LinearLayout {
    private Context _context;
    private ViewPager _viewPager;
    private LinearLayout _llDot;

    private OnEmoGridViewItemClick onEmoGridViewItemClick;

    private ImageView[] dots;
    /** ViewPager当前页 */
    private int currentIndex;
    /** ViewPager页数 */
    private int viewPager_size;
    /** 默认一页20个item */
    private double pageItemCount = 8d;

    /** 保存每个页面的GridView视图 */
    private List<GridView> list_Views;

    /** viewpage高度 */

    public YayaEmoGridView(Context cxt) {
        super(cxt);
        _context = cxt;
        initViewPage();
        initFootDots();
    }

    public YayaEmoGridView(Context cxt, AttributeSet attrs) {
        super(cxt, attrs);
        _context = cxt;
        initViewPage();
        initFootDots();
    }

    private void initViewPage() {
        setOrientation(VERTICAL);
        _viewPager = new ViewPager(_context);
        _llDot = new LinearLayout(_context);

        LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT,
                CommonUtil.getDefaultPannelHeight(_context));
        params.gravity=Gravity.BOTTOM;
        _viewPager.setLayoutParams(params);
        _llDot.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT));
        _llDot.setGravity(Gravity.CENTER);
        _llDot.setOrientation(HORIZONTAL);
        addView(_viewPager);
        addView(_llDot);
    }
    // 底部的三点
    private void initFootDots() {
        viewPager_size = (int) Math.ceil(Emoparser.getInstance(_context)
                .getYayaResIdList().length / pageItemCount);
        int mod = Emoparser.getInstance(_context).getResIdList().length
                % (SysConstant.pageSize - 1);
        if (mod == 1)
            --viewPager_size;
        if (0 < viewPager_size) {
            if (viewPager_size == 1) {
                _llDot.setVisibility(View.GONE);
            } else {
                _llDot.setVisibility(View.VISIBLE);
                for (int i = 0; i < viewPager_size; i++) {
                    ImageView image = new ImageView(_context);
                    image.setTag(i);
                    // LinearLayout.LayoutParams params = new
                    // LinearLayout.LayoutParams(
                    // 20, 20);
                    LayoutParams params = new LayoutParams(
                            LayoutParams.WRAP_CONTENT,
                            LayoutParams.WRAP_CONTENT);
                    params.setMargins(5,
                            CommonUtil.getElementSzie(_context) / 2, 5,
                            CommonUtil.getElementSzie(_context) / 2);
                    image.setBackgroundResource(R.drawable.tt_default_emo_dots);
                    image.setEnabled(false);
                    _llDot.addView(image, params);
                }
            }
        }
        if (1 != viewPager_size) {
            dots = new ImageView[viewPager_size];
            for (int i = 0; i < viewPager_size; i++) {
                dots[i] = (ImageView) _llDot.getChildAt(i);
                dots[i].setEnabled(true);
                dots[i].setTag(i);
            }
            currentIndex = 0;
            dots[currentIndex].setEnabled(false);
            _viewPager
                    .setOnPageChangeListener(new ViewPager.OnPageChangeListener() {

                        @Override
                        public void onPageSelected(int arg0) {
                            setCurDot(arg0);
                        }

                        @Override
                        public void onPageScrolled(int arg0, float arg1,
                                int arg2) {

                        }

                        @Override
                        public void onPageScrollStateChanged(int arg0) {
                        }
                    });
        }
    }

    private void setCurDot(int position) {
        if (position < 0 || position > viewPager_size - 1
                || currentIndex == position) {
            return;
        }
        dots[position].setEnabled(false);
        dots[currentIndex].setEnabled(true);
        currentIndex = position;
    }

    public void setAdapter() {
        if (onEmoGridViewItemClick == null) {
            return;
        }
        list_Views = new ArrayList<GridView>();
        for (int i = 0; i < viewPager_size; i++) {
            list_Views.add(getViewPagerItem(i));
        }
        _viewPager.setAdapter(new ViewPageAdapter(list_Views));

    }

    /** 生成gridView数据 */
    private int[] getGridViewData(int index) {
        ++index;
        int startPos = (index - 1) * SysConstant.yayaPageSize;
        int endPos = index * SysConstant.yayaPageSize - 1;

        if (endPos > Emoparser.getInstance(_context).getYayaResIdList().length) {
            endPos = Emoparser.getInstance(_context).getYayaResIdList().length-1;
        }
        int[] tmps = new int[endPos - startPos + 1];

        int num = 0;
        for (int i = startPos; i <= endPos; i++) {
            tmps[num] = Emoparser.getInstance(_context).getYayaResIdList()[i];
            num++;
        }
        return tmps;
    }

    private GridView getViewPagerItem(final int index) {
        GridView gridView = new GridView(_context);
        gridView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT));
        gridView.setNumColumns(4);
        gridView.setVerticalScrollBarEnabled(false);
        gridView.setHorizontalScrollBarEnabled(false);
        gridView.setPadding(8, 8, 8, 0);
        gridView.setVerticalSpacing(20);
        gridView.setSelector(new ColorDrawable(Color.TRANSPARENT));

        gridView.setAdapter(new YayaEmoGridViewAdapter(_context,
                getGridViewData(index)));
        gridView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                    int position, long id) {
                int start = index * SysConstant.yayaPageSize;
                onEmoGridViewItemClick.onItemClick(position + start, index);
            }
        });
        return gridView;
    }

    public void setOnEmoGridViewItemClick(
            OnEmoGridViewItemClick onFaceGridViewItemClick) {
        this.onEmoGridViewItemClick = onFaceGridViewItemClick;
    }

    public interface OnEmoGridViewItemClick {
        public void onItemClick(int facesPos, int viewIndex);
    }
}
