
package com.mogujie.tt.ui.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.mogujie.tt.R;
import com.mogujie.tt.ui.adapter.album.ImageGridAdapter;
import com.mogujie.tt.ui.adapter.album.ImageGridAdapter.TextCallback;
import com.mogujie.tt.ui.adapter.album.ImageItem;
import com.mogujie.tt.config.IntentConstant;
import com.mogujie.tt.config.SysConstant;
import com.mogujie.tt.imservice.event.SelectEvent;
import com.mogujie.tt.imservice.service.IMService;
import com.mogujie.tt.imservice.support.IMServiceConnector;
import com.mogujie.tt.utils.Logger;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import de.greenrobot.event.EventBus;

/**
 * @Description 相册图片列表
 * @author Nana
 * @date 2014-5-9
 */
public class ImageGridActivity extends Activity implements OnTouchListener {
    private List<ImageItem> dataList = null;
    private GridView gridView = null;
    private TextView title = null;
    private TextView cancel = null;
    private static TextView finish = null;
    private TextView preview = null;
    private String name = null;
    private ImageView leftBtn = null;
    private static Context context = null;
    private static ImageGridAdapter adapter = null;
	private Logger logger = Logger.getLogger(ImageGridActivity.class);

    private IMService imService;

	private IMServiceConnector imServiceConnector = new IMServiceConnector(){
        @Override
        public void onIMServiceConnected() {
            imService = imServiceConnector.getIMService();
            if(imService == null){
                throw new RuntimeException("#connect imservice success,but is null");
            }
        }

        @Override
        public void onServiceDisconnected() {

        }
    };

    private Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 0:
                    Toast.makeText(ImageGridActivity.this,
                            "最多选择" + SysConstant.MAX_SELECT_IMAGE_COUNT + "张图片",
                            Toast.LENGTH_LONG).show();
                    break;
                default:
                    break;
            }
        }
    };

    OnScrollListener onScrollListener = new OnScrollListener() {
        @Override
        public void onScrollStateChanged(AbsListView view, int scrollState) {
            switch (scrollState) {
                case OnScrollListener.SCROLL_STATE_FLING:
                    adapter.lock();
                    break;
                case OnScrollListener.SCROLL_STATE_IDLE:
                    adapter.unlock();
                    break;
                case OnScrollListener.SCROLL_STATE_TOUCH_SCROLL:
                    adapter.lock();
                    break;
                default:
                    break;
            }
        }

        @Override
        public void onScroll(AbsListView view, int firstVisibleItem,
                int visibleItemCount, int totalItemCount) {
        }
    };

    @SuppressWarnings("unchecked")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        imServiceConnector.connect(this);
        setContentView(R.layout.tt_activity_image_grid);
        context = this;
        name = (String) getIntent().getSerializableExtra(
                IntentConstant.EXTRA_ALBUM_NAME);
        dataList = (List<ImageItem>) getIntent().getSerializableExtra(
                IntentConstant.EXTRA_IMAGE_LIST);
        initView();
        initAdapter();
    }

    private void initAdapter() {
        adapter = new ImageGridAdapter(ImageGridActivity.this, dataList,
                mHandler);
        adapter.setTextCallback(new TextCallback() {
            public void onListen(int count) {
                setSendText(count);
            }
        });
        gridView.setAdapter(adapter);
        gridView.setOnScrollListener(onScrollListener);
    }

    private void initView() {
        gridView = (GridView) findViewById(R.id.gridview);
        gridView.setSelector(new ColorDrawable(Color.TRANSPARENT));
        gridView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                    int position, long id) {
                adapter.notifyDataSetChanged();
            }
        });

        title = (TextView) findViewById(R.id.base_fragment_title);
        if (name.length() > 12) {
            name = name.substring(0, 11) + "...";
        }
        title.setText(name);
        leftBtn = (ImageView) findViewById(R.id.back_btn);
        leftBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ImageGridActivity.this.finish();
            }
        });
        cancel = (TextView) findViewById(R.id.cancel);
        cancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                adapter.setSelectMap(null);
                ImageGridActivity.this.finish();
            }
        });
        finish = (TextView) findViewById(R.id.finish);
        finish.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {
            	logger.d("pic#click send image btn");
                if (adapter.getSelectMap().size() > 0) {
                    List<ImageItem> itemList = new ArrayList<>();
                    Iterator<Integer> iter = adapter.getSelectMap().keySet()
                            .iterator();

                    for(Map.Entry<Integer,ImageItem> entity :adapter.getSelectMap().entrySet()){
                         int position = entity.getKey();
                         ImageItem imageItem = entity.getValue();

                    }
                    while (iter.hasNext()) {
                        int position = iter.next();
                        ImageItem imgItem = adapter.getSelectMap()
                                .get(position);
                        itemList.add(imgItem);
                    }

                    setSendText(0);
                    EventBus.getDefault().post(new SelectEvent(itemList));
                    ImageGridActivity.this.setResult(RESULT_OK, null);
                    ImageGridActivity.this.finish();
                } else {
                    Toast.makeText(ImageGridActivity.this,
                            R.string.need_choose_images, Toast.LENGTH_SHORT)
                            .show();
                }
            }

        });
        preview = (TextView) findViewById(R.id.preview);
        preview.setOnClickListener(new OnClickListener() {

            public void onClick(View v) {

                if (adapter.getSelectMap().size() > 0) {
                    Intent intent = new Intent(ImageGridActivity.this,
                            PreviewActivity.class);
                    startActivityForResult(intent,
                            SysConstant.ALBUM_PREVIEW_BACK);
                } else {
                    Toast.makeText(ImageGridActivity.this,
                            R.string.need_choose_images, Toast.LENGTH_SHORT)
                            .show();
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        setAdapterSelectedMap(null);
        imServiceConnector.disconnect(this);
        super.onStop();
    }

    public static void setSendText(int selNum) {
        if (selNum == 0) {
            finish.setText(context.getResources().getString(R.string.send));
        } else {
            finish.setText(context.getResources().getString(R.string.send)
                    + "(" + selNum + ")");
        }
    }

    public static void setAdapterSelectedMap(Map<Integer, ImageItem> map) {
        Iterator<Integer> it = adapter.getSelectMap().keySet().iterator();
        if (map != null) {
            while (it.hasNext()) {
                int key = (Integer) it.next();
                if (map.containsKey(key)) {
                    adapter.updateSelectedStatus(key, true);
                } else {
                    adapter.updateSelectedStatus(key, false);
                }
            }
            adapter.setSelectMap(map);
            adapter.setSelectTotalNum(map.size());
        } else {
            while (it.hasNext()) {
                int key = (Integer) it.next();
                adapter.updateSelectedStatus(key, false);
            }
            adapter.setSelectMap(null);
            adapter.setSelectTotalNum(0);
        }
        adapter.notifyDataSetChanged();
    }

    public static ImageGridAdapter getAdapter() {
        return adapter;
    }

    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        switch (motionEvent.getAction()) {
            case MotionEvent.ACTION_DOWN:
                adapter.unlock();
                break;
        }
        return false;
    }
}
