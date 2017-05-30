package com.mogujie.tt.ui.activity;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.mogujie.tt.R;
import com.mogujie.tt.ui.adapter.album.ImageGridAdapter;
import com.mogujie.tt.ui.adapter.album.ImageItem;
import com.mogujie.tt.utils.ImageUtil;
import com.mogujie.tt.utils.Logger;
import com.mogujie.tt.ui.widget.CustomViewPager;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * @author Nana
 * @Description 图片预览
 * @date 2014-5-9
 */
public class PreviewActivity extends Activity
        implements
        OnPageChangeListener {

    private CustomViewPager viewPager;
    private ImageView[] tips;
    private ImageView[] mImageViews;
    private ViewGroup group;
    private ImageView back;
    private ImageView select;
    private final ImageGridAdapter adapter = ImageGridActivity.getAdapter();
    private Map<Integer, Integer> removePosition = new HashMap<Integer, Integer>();
    private int curImagePosition = -1;
    private Logger logger = Logger.getLogger(PreviewActivity.class);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        logger.d("pic#PreviewActivity onCreate");
        super.onCreate(savedInstanceState);

        setContentView(R.layout.tt_activity_preview);
        initView();
        loadView();
    }

    private void initView() {
        viewPager = (CustomViewPager) findViewById(R.id.viewPager);
        group = (ViewGroup) findViewById(R.id.viewGroup);
        back = (ImageView) findViewById(R.id.back_btn);
        select = (ImageView) findViewById(R.id.select_btn);
        back.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                @SuppressWarnings("rawtypes")
                Iterator it = removePosition.keySet().iterator();
                while (it.hasNext()) {
                    int key = (Integer) it.next();
                    if (adapter.getSelectMap().containsKey(key))
                        adapter.getSelectMap().remove(key);
                }
                ImageGridActivity.setAdapterSelectedMap(ImageGridActivity.getAdapter().getSelectMap());
                removePosition.clear();
                PreviewActivity.this.finish();
            }
        });
        select.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (adapter.getSelectMap().containsKey(curImagePosition)) {
                    ImageItem item = adapter.getSelectMap().get(curImagePosition);
                    item.setSelected(!item.isSelected());
                    if (item.isSelected()) {
                        int selTotal = adapter.getSelectTotalNum();
                        adapter.setSelectTotalNum(++selTotal);
                        if (removePosition.containsKey(curImagePosition)) {
                            removePosition.remove(curImagePosition);
                        }
                        ImageGridActivity.setSendText(selTotal);
                        select.setImageResource(R.drawable.tt_album_img_selected);
                    } else {
                        int selTotal = adapter.getSelectTotalNum();
                        adapter.setSelectTotalNum(--selTotal);
                        removePosition.put(curImagePosition, curImagePosition);
                        ImageGridActivity.setSendText(selTotal);
                        select.setImageResource(R.drawable.tt_album_img_select_nor);
                    }
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void loadView() {
        mImageViews = new ImageView[adapter.getSelectMap().size()];

        if (adapter.getSelectMap().size() > 1) {
            tips = new ImageView[adapter.getSelectMap().size()];
            for (int i = 0; i < tips.length; i++) {
                ImageView imageView = new ImageView(this);
                imageView.setLayoutParams(new LayoutParams(10, 10));
                tips[i] = imageView;
                if (i == 0) {
                    tips[i].setBackgroundResource(R.drawable.tt_default_dot_down);
                } else {
                    tips[i].setBackgroundResource(R.drawable.tt_default_dot_up);
                }
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(new ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
                layoutParams.leftMargin = 5;
                layoutParams.rightMargin = 5;
                group.addView(imageView, layoutParams);
            }
        }

        Iterator<?> it = adapter.getSelectMap().keySet().iterator();
        int index = -1;
        while (it.hasNext()) {
            int key = (Integer) it.next();
            ImageItem item = adapter.getSelectMap().get(key);
            ImageView imageView = new ImageView(this);
            mImageViews[++index] = imageView;
            Bitmap bmp = ImageUtil.getBigBitmapForDisplay(item.getImagePath(), PreviewActivity.this);
            if (bmp == null)
                bmp = ImageUtil.getBigBitmapForDisplay(item.getThumbnailPath(), PreviewActivity.this);
            if (bmp != null)
                imageView.setImageBitmap(bmp);
            if (index == 0) {
                curImagePosition = key;
            }
        }

        // 设置view pager
        viewPager.setAdapter(new PreviewAdapter());
        viewPager.setOnPageChangeListener(this);
        if (adapter.getSelectMap().size() == 1) {
            viewPager.setScanScroll(false);
        } else {
            viewPager.setScanScroll(true);
        }
        viewPager.setCurrentItem(0);
    }

    @Override
    public void onPageScrollStateChanged(int arg0) {
    }

    @Override
    public void onPageScrolled(int arg0, float arg1, int arg2) {

    }

    private void setImageBackground(int selectItems) {
        for (int i = 0; i < tips.length; i++) {
            if (i == selectItems) {
                tips[i].setBackgroundResource(R.drawable.tt_default_dot_down);
            } else {
                tips[i].setBackgroundResource(R.drawable.tt_default_dot_up);
            }
        }
    }

    @Override
    public void onPageSelected(int position) {
        @SuppressWarnings("rawtypes")
        Iterator it = adapter.getSelectMap().keySet().iterator();
        int index = -1;
        while (it.hasNext()) {
            int key = (Integer) it.next();
            if (++index == position) {
                curImagePosition = key;// 对应适配器中图片列表的真实位置
                if (adapter.getSelectMap().get(key).isSelected()) {
                    select.setImageResource(R.drawable.tt_album_img_selected);
                } else {
                    select.setImageResource(R.drawable.tt_album_img_select_nor);
                }
            }
        }
        setImageBackground(position);
    }

    public class PreviewAdapter extends PagerAdapter {

        @Override
        public int getCount() {
            return mImageViews.length;
        }

        @Override
        public boolean isViewFromObject(View view, Object obj) {
            return view == obj;
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object) {
            container.removeView((View) object);
        }

        @Override
        public Object instantiateItem(View container, int position) {
            try {
                ((ViewGroup) container).addView(mImageViews[position]);
            } catch (Exception e) {
            }
            return mImageViews[position];
        }
    }

}
