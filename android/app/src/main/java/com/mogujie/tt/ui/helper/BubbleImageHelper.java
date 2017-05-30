
package com.mogujie.tt.ui.helper;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;

//not use now
public class BubbleImageHelper {
	private final static int MIN_WIDTH =120;
    private final static int MAX_HEIGHT =300;
    private final static int MAX_WIDTH =290;
    private final static int MIN_HEIGHT =130;
	
    private Context context = null;
    private static BubbleImageHelper instance = null;

    public static synchronized BubbleImageHelper getInstance(Context c) {
        if (null == instance) {
            instance = new BubbleImageHelper(c);
        }
        return instance;
    }

    private BubbleImageHelper(Context c) {
        context = c;
    }

    private Bitmap getScaleImage(Bitmap bitmap, float width, float height) {
        if (null == bitmap || width < 0.0f || height < 0.0f) {
            return null;
        }
        Matrix matrix = new Matrix();
        float scaleWidth = width / bitmap.getWidth();
        float scaleHeight = height / bitmap.getHeight();
        matrix.postScale(scaleWidth, scaleHeight);
        Bitmap resizeBmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(),
                bitmap.getHeight(), matrix, true);
        return resizeBmp;
    }

    public Bitmap getBubbleImageBitmap(Bitmap srcBitmap, int backgroundResourceID) {
        if (null == srcBitmap) {
            return null;
        }
        Bitmap background = null;
        background = BitmapFactory.decodeResource(context.getResources(),
                backgroundResourceID);
        if (null == background) {
            return null;
        }

        Bitmap mask = null;
        Bitmap newBitmap = null;
        mask = srcBitmap;
        resetSrcImgSize(srcBitmap);
        
        Bitmap tmp = getScaleImage(background, srcBitmap.getWidth(), srcBitmap.getHeight());
	    if (null != tmp) {
	    	background = tmp;
	    } else {
	    	tmp = getScaleImage(srcBitmap, srcBitmap.getWidth(),srcBitmap.getHeight());
	    	if (null != tmp) {
	    		mask = tmp;
	    	}
	    }    
        
        Config config = background.getConfig();
        if (null == config) {
            config = Bitmap.Config.ARGB_8888;
        }

        newBitmap = Bitmap.createBitmap(background.getWidth(),
                background.getHeight(), config);
        Canvas newCanvas = new Canvas(newBitmap);

        newCanvas.drawBitmap(background, 0, 0, null);

        Paint paint = new Paint();

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_ATOP));
        newCanvas.drawBitmap(mask, new Rect(0, 0, mask.getWidth(),mask.getHeight()),
                new Rect(0, 0, background.getWidth(), background.getHeight()),
                paint);

        return newBitmap;
    }
    
    private void resetSrcImgSize(Bitmap srcBitmap){
    	int srcWidth = srcBitmap.getWidth();
        int srcHeight = srcBitmap.getHeight();
        
        if(srcWidth>srcHeight) {
            srcWidth= MAX_WIDTH;
            if (srcHeight < MIN_HEIGHT) {
            	srcHeight = MIN_HEIGHT;
            }
            if (srcHeight > MAX_HEIGHT) {
            	srcHeight = MAX_HEIGHT;
            }
        }else if(srcWidth<srcHeight){
            srcHeight= MAX_HEIGHT;
            if(srcWidth< MIN_WIDTH){
                srcWidth= MIN_WIDTH;
            }
            if (srcWidth> MAX_WIDTH){
                srcWidth= MAX_WIDTH;
            }
        }else{
        	if(srcWidth< MIN_WIDTH){
                srcWidth= MIN_WIDTH;
                srcHeight = MIN_WIDTH;
            }
            if (srcHeight> MAX_HEIGHT){
                srcWidth= MAX_HEIGHT;
                srcHeight = MAX_HEIGHT;
            }
        }
        
        srcBitmap = getScaleImage(srcBitmap, srcWidth, srcHeight);
    }
    
}
