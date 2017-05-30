package com.mogujie.tools;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;

import com.mogujie.im.libs.R;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * 自动下载更新,~
 * @author 6a209
 * Feb 17, 2013
 */
public class MGAutoUpdate {  
	private Context mCtx;
	private ProgressDialog mProgressDialog;
	private long mCount;
	private static final int UPDATE = 0x01;
    private Handler mHandler = new Handler(){
    	@Override
    	public void handleMessage(Message msg){
    		switch(msg.what){
    		case UPDATE:
    			mProgressDialog.setProgress((int)(mCount / 1000));
    			break;
    		}
    	}
    };
    
    private boolean isCancle = false;
    private UpdateOnCancleListener updateOnCancleListener;
    private OnUpdateFinishListener mUpdateFinishListener;
  
    public MGAutoUpdate(Context ctx) {  
    	 mCtx = ctx;
    	 mProgressDialog = new ProgressDialog(mCtx);
         mProgressDialog.setTitle(R.string.downloading);
         mProgressDialog.setMessage(mCtx.getString(R.string.wait_moment));
         mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
         //默认100
         mProgressDialog.setMax(100);
         mProgressDialog.show();
         mProgressDialog.setOnCancelListener(new OnCancelListener() {
			@Override
			public void onCancel(DialogInterface dialog) {
				if(null != updateOnCancleListener){
					isCancle = true;
					updateOnCancleListener.cancel();
				}
			}
		});
    }  
  
    public void startDown(final String url) {  
        new Thread() {  
            public void run() {  
                HttpClient client = new DefaultHttpClient();  
                // params[0]代表连接的url  
                HttpGet get = new HttpGet(url);  
                HttpResponse response;  
                try {  
                    response = client.execute(get);  
                    HttpEntity entity = response.getEntity();  
                    long length = entity.getContentLength();  
                    mProgressDialog.setMax((int)(length / 1000));
                    InputStream is = entity.getContent();  
                    FileOutputStream fileOutputStream = null;  
                    if (is != null) {  
  
                        File file = new File(Environment  
                                .getExternalStorageDirectory(), "OA.apk");  
                        fileOutputStream = new FileOutputStream(file);  
                          
                        byte[] buf = new byte[1024];  
                        int ch = -1;  
                        mCount = 0;  
                        while ((ch = is.read(buf)) != -1) {  
                            // baos.write(buf, 0, ch);  
                            fileOutputStream.write(buf, 0, ch);  
                            mCount += ch; 
                            
                            if (length > 0) {  
                              
                            }  
                            mHandler.sendEmptyMessage(UPDATE);
                        }  
                    }
                    
                    fileOutputStream.flush();  
                    if (fileOutputStream != null) {  
                        fileOutputStream.close();  
                    }  
                    down();  
                } catch (ClientProtocolException e) {  
                    e.printStackTrace();
                } catch (IOException e) {  
                    e.printStackTrace();
                }  
            }  
        }.start();  
  
    }  
  
    void down() {  
        mHandler.post(new Runnable() {  
            public void run() {  
                update();  
            }  
        });  
    }  
  
    void update() {
    	if(mProgressDialog.isShowing()){
        	mProgressDialog.dismiss();
    	}
    	
    	if(isCancle){
    		return;
    	}
        if(null != mUpdateFinishListener){
            mUpdateFinishListener.onFinish();
        }
        Intent intent = new Intent(Intent.ACTION_VIEW);  
        intent.setDataAndType(Uri.fromFile(new File("/sdcard/OA.apk")),  
                "application/vnd.android.package-archive");  
        mCtx.startActivity(intent); 
    }  
    
    public void setUpdateOnCancleListener(UpdateOnCancleListener updateOnCancleListener){
    	this.updateOnCancleListener = updateOnCancleListener;
    }

    public void setOnFinishListener(OnUpdateFinishListener listener){
        mUpdateFinishListener = listener;
    }
    
    public interface UpdateOnCancleListener {
    	public void cancel();
    }

    public interface OnUpdateFinishListener{
        public void onFinish();
    }
  
}  