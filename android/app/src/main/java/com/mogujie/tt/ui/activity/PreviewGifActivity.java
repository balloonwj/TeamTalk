
package com.mogujie.tt.ui.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import com.mogujie.tt.R;
import com.mogujie.tt.config.IntentConstant;
import com.mogujie.tt.ui.helper.Emoparser;
import com.mogujie.tt.ui.helper.GifAnimationDrawable;
import com.mogujie.tt.ui.widget.GifLoadTask;
import com.mogujie.tt.ui.widget.GifView;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;

/**
 * @author : fengzi on 15-1-25.
 * @email : fengzi@mogujie.com.
 *
 * preview a GIF image when click on the gif message
 */
public class PreviewGifActivity extends Activity implements View.OnClickListener {
    GifView gifView = null;
    ImageView backView = null;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tt_activity_preview_gif);
        gifView = (GifView) findViewById(R.id.gif);
        backView = (ImageView)findViewById(R.id.back_btn);
        backView.setOnClickListener(this);
        String content = getIntent().getStringExtra(IntentConstant.PREVIEW_TEXT_CONTENT);
        if(Emoparser.getInstance(this).isMessageGif(content))
        {
            InputStream is = getResources().openRawResource(Emoparser.getInstance(this).getResIdByCharSequence(content));
            int lenght = 0;
            try {
                lenght = is.available();
                byte[]  buffer = ByteBuffer.allocate(lenght).array();
                is.read(buffer);
                gifView.setBytes(buffer);
                gifView.startAnimation();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        else
        {
            new GifLoadTask() {
                @Override
                protected void onPostExecute(byte[] bytes) {
                    gifView.setBytes(bytes);
                    gifView.startAnimation();
                }
                @Override
                protected void onPreExecute() {
                    super.onPreExecute();
                }
            }.execute(content);
        }


    }

    @Override
    public void onClick(View view) {
        gifView.stopAnimation();
        PreviewGifActivity.this.finish();
    }
}
