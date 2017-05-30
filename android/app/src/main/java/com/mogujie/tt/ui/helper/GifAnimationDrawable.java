package com.mogujie.tt.ui.helper;

import android.graphics.Bitmap;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.BitmapDrawable;
import android.os.Handler;
import android.os.HandlerThread;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * @author : fengzi on 15-1-25.
 * @email : fengzi@mogujie.com.
 *
 * Creates an AnimationDrawable from a GIF image.
 */
public class GifAnimationDrawable extends AnimationDrawable
{
	private GifDecoder mGifDecoder;
	private Bitmap mTmpBitmap;
	private int height, width;
    public Handler uiHandler;

    public GifAnimationDrawable(InputStream is,HandlerThread handlerThread,Handler workHandler,Handler uiHandler) throws IOException {
        this(is, false,handlerThread,workHandler,uiHandler);
    }

	public GifAnimationDrawable(InputStream is) throws IOException
	{
		this(is, false,null,null,null);
	}

	public GifAnimationDrawable(InputStream is, boolean inline,HandlerThread handlerThread,Handler workHandler,Handler uiHandler) throws IOException
	{
		super();
		InputStream bis = is;
		if(!BufferedInputStream.class.isInstance(bis)) bis = new BufferedInputStream(is, 32768);
		mGifDecoder = new GifDecoder();
		mGifDecoder.read(bis);
		mTmpBitmap = mGifDecoder.getFrame(0);
		height = mTmpBitmap.getHeight();
    	width = mTmpBitmap.getWidth();
        addFrame(new BitmapDrawable(mTmpBitmap), mGifDecoder.getDelay(0));
//        setOneShot(mGifDecoder.getLoopCount() != 0);
//        setVisible(true, true);
        this.uiHandler = uiHandler;
        //TODO 临时解决方案 因为卡顿，所以暂时关闭播放
        if(inline){
            loader.run();
        }else{
            if(handlerThread!=null)
            {
                workHandler.postDelayed(loader, 0);
            }
        }
	}

	private Runnable loader = new Runnable(){
		public void run() 
		{
			mGifDecoder.complete();
			int i, n = mGifDecoder.getFrameCount(), t;
	        for(i=1;i<n;i++){
	            mTmpBitmap = mGifDecoder.getFrame(i);
	            t = mGifDecoder.getDelay(i);
	            addFrame(new BitmapDrawable(mTmpBitmap), t);
	        }
            if(!isRunning()||isOneShot()||!isVisible())
            {
                setOneShot(mGifDecoder.getLoopCount() != 0);
                uiHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        setVisible(true, true);
                    }
                });
            }

	        mGifDecoder = null;
	    }
	};
	
	public int getMinimumHeight(){ return height; }
	public int getMinimumWidth(){ return width; }
	public int getIntrinsicHeight(){ return height; }
	public int getIntrinsicWidth(){ return width; }
}
