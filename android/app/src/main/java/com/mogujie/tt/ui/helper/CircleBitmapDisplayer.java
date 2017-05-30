package com.mogujie.tt.ui.helper;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;

import com.nostra13.universalimageloader.core.assist.LoadedFrom;
import com.nostra13.universalimageloader.core.display.BitmapDisplayer;
import com.nostra13.universalimageloader.core.imageaware.ImageAware;

/**
 * Created by zhujian on 15/1/14.
 */
public class CircleBitmapDisplayer implements BitmapDisplayer {

    private float borderWidth = 0;
    private int borderColor;

    public CircleBitmapDisplayer() {
        super();
    }

    public CircleBitmapDisplayer(int borderColor, int borderWidth){
        super();
        this.borderColor = borderColor;
        this.borderWidth = borderWidth;
    }

    @Override
    public void display(Bitmap bitmap, ImageAware imageAware, LoadedFrom loadedFrom) {
        Bitmap output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Bitmap.Config.ARGB_4444);

        Canvas canvas = new Canvas(output);

        final int color = 0xff424242;
        final Paint paint = new Paint();
        final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());

        paint.setAntiAlias(true);
        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);

        //--CROP THE IMAGE
        canvas.drawCircle(bitmap.getWidth() / 2, bitmap.getHeight() / 2, bitmap.getWidth() / 2 - 1, paint);
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, rect, rect, paint);

        //--ADD BORDER IF NEEDED
        if(this.borderWidth > 0){
            final Paint paint2 = new Paint();
            paint2.setAntiAlias(true);
            paint2.setColor(this.borderColor);
            paint2.setStrokeWidth(this.borderWidth);
            paint2.setStyle(Paint.Style.STROKE);
            canvas.drawCircle(bitmap.getWidth() / 2, bitmap.getHeight() / 2, (float) (bitmap.getWidth() / 2 - Math.ceil(this.borderWidth / 2)), paint2);
        }
        imageAware.setImageBitmap(output);
    }

}
