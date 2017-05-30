package com.mogujie.tt.ui.activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.mogujie.tt.R;
import com.mogujie.tt.config.IntentConstant;
import com.mogujie.tt.imservice.entity.ImageMessage;
import com.mogujie.tt.imservice.support.IMServiceConnector;
import com.mogujie.tt.imservice.service.IMService;
import com.mogujie.tt.ui.fragment.MessageImageFragment;

import java.util.ArrayList;

public class PreviewMessageImagesActivity extends FragmentActivity implements ViewPager.OnPageChangeListener {
    private ViewPager viewPager;
    private LinearLayout group;
    private ImageView back;
    private int curImagePosition = -1;
    private ImageMessage messageInfo;
    ArrayList<ImageView> tips=new ArrayList<ImageView>();
    ArrayList<android.support.v4.app.Fragment> fragments=new ArrayList<>();
    private ArrayList<ImageMessage> imageList= null;
    public IMService imService;

    IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onIMServiceConnected() {
            imService = imServiceConnector.getIMService();
            if(imService!=null)
            {
                loadFragments();
//                loadTips();
            }
        }
        @Override
        public void onServiceDisconnected() {
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_preview_message_images);
        imageList=ImageMessage.getImageMessageList();
        try {
            messageInfo = (ImageMessage) getIntent().getSerializableExtra(IntentConstant.CUR_MESSAGE);
            initRes();
            imServiceConnector.connect(this);
        }catch (Exception e){
        }
    }

    /**
     * 初始化资源
     */
    private void initRes() {
        try {
            viewPager = (ViewPager) findViewById(R.id.viewpager);
            viewPager.setOnPageChangeListener(this);
            group = (LinearLayout) findViewById(R.id.viewGroup);
            back = (ImageView) findViewById(R.id.back_btn);
            back.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    PreviewMessageImagesActivity.this.finish();
                }
            });

            //加载页面
            //loadFragments();
            //设置点点
            //loadTips();
        }catch (Exception e){
        }
    }

    /**
     * 加载页面
     */
    private void loadFragments(){
        if (null == viewPager||null==fragments) {
            return;
        }
        try {
            viewPager.removeAllViews();
            fragments.clear();
            if (null != imageList && null != messageInfo) {
                for (int i = 0; i < imageList.size(); i++) {
                    ImageMessage item =imageList.get(imageList.size()-i-1);
                    if(null==item){
                        continue;
                    }
                    MessageImageFragment fragment = new MessageImageFragment();
                    fragment.setImageInfo(item);
                    fragment.setImService(imService);
                    fragments.add(fragment);
                    if (item.getMsgId()==messageInfo.getMsgId()&&messageInfo.getId().equals(item.getId())) {
                        curImagePosition = i;
                    }
                }
            }
            viewPager.setAdapter(new FragmentAdapter(getSupportFragmentManager(), fragments));
            if (curImagePosition >= 0) {
                viewPager.setCurrentItem(curImagePosition);
            }
        }catch (Exception e){
        }
    }

    /**
     * 加载点点
     */
    private void loadTips(){
        try {
            if (null==imageList||imageList.size()==0){
                return;
            }
            group.removeAllViews();
            tips.clear();
            for (int i = 0; i < imageList.size(); i++) {
                ImageMessage item =imageList.get(i);
                if(null==item){
                    continue;
                }
                ImageView imageView = new ImageView(this);
                if (i == curImagePosition) {
                    imageView.setBackgroundResource(R.drawable.tt_default_dot_down);
                } else {
                    imageView.setBackgroundResource(R.drawable.tt_default_dot_up);
                }
                tips.add(imageView);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
                        new ViewGroup.LayoutParams(12, 12));
                layoutParams.leftMargin = 5;
                layoutParams.rightMargin = 5;
                group.addView(imageView, layoutParams);
            }
        }catch (Exception e){
        }
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        try {
            if (null==tips){
                loadTips();
            }
            if (null!=tips) {
                for (int i = 0; i < tips.size(); i++) {
                    if (i == position) {
                        tips.get(i).setBackgroundResource(R.drawable.tt_default_dot_down);
                    } else {
                        tips.get(i).setBackgroundResource(R.drawable.tt_default_dot_up);
                    }
                }
            }
        }catch (Exception e){
        }
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    public class FragmentAdapter  extends FragmentPagerAdapter {
        ArrayList<Fragment> list;
        public FragmentAdapter(FragmentManager fm,ArrayList<Fragment> list) {
            super(fm);
            this.list = list;
        }

        @Override
        public int getCount() {
            return list.size();
        }

        @Override
        public android.support.v4.app.Fragment getItem(int arg0) {
            return list.get(arg0);
        }
    }


    @Override
    protected void onDestroy() {
        fragments.clear();
        imServiceConnector.disconnect(this);
        super.onDestroy();
    }
}
