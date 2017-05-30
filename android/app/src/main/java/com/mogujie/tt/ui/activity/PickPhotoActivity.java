
package com.mogujie.tt.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.mogujie.tt.R;
import com.mogujie.tt.ui.adapter.album.AlbumHelper;
import com.mogujie.tt.ui.adapter.album.ImageBucket;
import com.mogujie.tt.ui.adapter.album.ImageBucketAdapter;
import com.mogujie.tt.config.IntentConstant;
import com.mogujie.tt.utils.Logger;

import java.io.Serializable;
import java.util.List;

/**
 * @Description 相册列表
 * @author Nana
 * @date 2014-5-6
 */
public class PickPhotoActivity extends Activity  {
    List<ImageBucket> dataList = null;
    ListView listView = null;
    ImageBucketAdapter adapter = null;
    AlbumHelper helper = null;
    TextView cancel = null;
    public static Bitmap bimap = null;
    boolean touchable = true;
    private String currentSessionKey;
	private Logger logger = Logger.getLogger(PickPhotoActivity.class);

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(resultCode==Activity.RESULT_OK)
        {
            this.finish();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
    	logger.d("pic#PickPhotoActivity onCreate");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tt_activity_pick_photo);
        initData();
        initView();
    }

    /**
     * 初始化数据
     */
    private void initData() {
        Bundle bundle =  getIntent().getExtras();
        currentSessionKey = bundle.getString(IntentConstant.KEY_SESSION_KEY);
        helper = AlbumHelper.getHelper(getApplicationContext());
        dataList = helper.getImagesBucketList(true);
        bimap = BitmapFactory.decodeResource(getResources(),
                R.drawable.tt_default_album_grid_image);
    }

    /**
     * 初始化view
     */
    private void initView() {
        listView = (ListView) findViewById(R.id.list);
        adapter = new ImageBucketAdapter(this, dataList);

        listView.setAdapter(adapter);
//        listView.setOnTouchListener(this);

        listView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                    int position, long id) {
                Intent intent = new Intent(PickPhotoActivity.this,
                        ImageGridActivity.class);
                intent.putExtra(IntentConstant.EXTRA_IMAGE_LIST,
                        (Serializable) dataList.get(position).imageList);
                intent.putExtra(IntentConstant.EXTRA_ALBUM_NAME,
                        dataList.get(position).bucketName);
                intent.putExtra(IntentConstant.KEY_SESSION_KEY,currentSessionKey);
                startActivityForResult(intent, 1);//requestcode》＝0
//                PickPhotoActivity.this.finish();
            }
        });
        cancel = (TextView) findViewById(R.id.cancel);
        cancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                setResult(Activity.RESULT_OK, null);
                PickPhotoActivity.this.finish();
                overridePendingTransition(R.anim.tt_stay, R.anim.tt_album_exit);
            }
        });

    }

}
