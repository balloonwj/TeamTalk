package com.mogujie.tt.ui.widget;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Matrix;
import android.graphics.PointF;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Toast;

import com.mogujie.tt.R;
import com.mogujie.tt.ui.activity.DetailPortraitActivity;
import com.mogujie.tt.utils.Logger;

/**
 * Created by zhujian on 15/1/19.
 */
public class ZoomableImageView extends ImageView{

    private static Logger logger = Logger.getLogger(ZoomableImageView.class);
    private float maxScale = 3f;
    private float minScale = 1f;

    private enum State {
        INIT, DRAG, ZOOM
    }

    private State state;

    private Matrix matrix;
    private float[] finalTransformation = new float[9];
    private PointF last = new PointF();
    private float currentScale = 1f;

    private int viewWidth;
    private int viewHeight;
    private float afterScaleDrawableWidth;
    private float afterScaleDrawableHeight;
    private DetailPortraitActivity.finishActivity finishActivity;

    private ScaleGestureDetector scaleDetector;

    private GestureDetector doubleTapDetecture;

    public ZoomableImageView(Context context) {
        super(context);
        setUp(context);
    }

    public ZoomableImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        setUp(context);
    }

    public ZoomableImageView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        setUp(context);
    }

    public void setFinishActivity(DetailPortraitActivity.finishActivity finishInterface)
    {
        this.finishActivity = finishInterface;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        viewWidth = MeasureSpec.getSize(widthMeasureSpec);
        viewHeight = MeasureSpec.getSize(heightMeasureSpec);

        // Set up drawable at first load
        if (hasDrawable()) {
            resetImage();
        }
    }


    @Override
    public boolean onTouchEvent(MotionEvent event) {
        scaleDetector.onTouchEvent(event);
        doubleTapDetecture.onTouchEvent(event);

        PointF current = new PointF(event.getX(), event.getY());

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                last.set(current);
                state = State.DRAG;
                stopInterceptEvent();
                break;

            case MotionEvent.ACTION_MOVE:
                if (state == State.DRAG) {

                    //Edit by boris ����߽�
                    if (drag(current)) {
                        stopInterceptEvent();
                        last.set(current);
                    } else {
                        startInterceptEvent();
                        return false;
                    }

                }
                break;

            case MotionEvent.ACTION_UP:
                state = State.INIT;
                startInterceptEvent();
                break;

            case MotionEvent.ACTION_POINTER_UP:
                state = State.INIT;
                break;
        }

        setImageMatrix(matrix);
        invalidate();
        return true;
    }

    /** ���������Լ����� */
    private void stopInterceptEvent() {
        getParent().requestDisallowInterceptTouchEvent(true);
    }

    /** ����������view���� */
    private void startInterceptEvent() {
        getParent().requestDisallowInterceptTouchEvent(false);
    }

    /**
     * Set up the class. Method called by constructors.
     *
     * @param context
     */
    private void setUp(Context context) {
        super.setClickable(false);
        matrix = new Matrix();
        state = State.INIT;
        scaleDetector = new ScaleGestureDetector(context, new ScaleListener());
        doubleTapDetecture = new GestureDetector(context, new GestureListener());
        setScaleType(ScaleType.MATRIX);
    }

    public void resetImage() {

        // Scale Image
        float scale = getScaleForDrawable();
        matrix.setScale(scale, scale);

        // Center Image
        float marginY = ((float) viewHeight - (scale * getDrawable()
                .getIntrinsicHeight())) / 2;
        float marginX = ((float) viewWidth - (scale * getDrawable()
                .getIntrinsicWidth())) / 2;
        matrix.postTranslate(marginX, marginY);

        afterScaleDrawableWidth = (float) viewWidth - 2 * marginX;
        afterScaleDrawableHeight = (float) viewHeight - 2 * marginY;

        setImageMatrix(matrix);


        //Edit by boris
        currentScale = 1f;
        state = State.INIT;
    }

    /**
     * Getter and setter for max/min scale. Default are min=1 and max=3
     */

    public float getMaxScale() {
        return maxScale;
    }

    public void setMaxScale(float maxScale) {
        this.maxScale = maxScale;
    }

    public float getMinScale() {
        return minScale;
    }

    public void setMinScale(float minScale) {
        this.minScale = minScale;
    }

    /**
     * Drag method
     *   //Edit by boris,����϶����˱߽��򷵻�false
     *
     * @param current
     *            Current point to drag to.
     */
    private boolean drag(PointF current) {
        if (isXSide(current)) {
            return false;
        }

        float deltaX = getMoveDraggingDelta(current.x - last.x, viewWidth,
                afterScaleDrawableWidth * currentScale);
        float deltaY = getMoveDraggingDelta(current.y - last.y, viewHeight,
                afterScaleDrawableHeight * currentScale);

        beforLimitDragX = deltaX;

        matrix.postTranslate(deltaX, deltaY);

        limitDrag();

        return true;
    }

    /**
     * @param current
     * @return
     */
    private boolean isXSide(PointF current) {
        Matrix retainMatrix = new Matrix();
        retainMatrix.set(matrix);

        float deltaX = getMoveDraggingDelta(current.x - last.x, viewWidth,
                afterScaleDrawableWidth * currentScale);
        float deltaY = getMoveDraggingDelta(current.y - last.y, viewHeight,
                afterScaleDrawableHeight * currentScale);
        retainMatrix.postTranslate(deltaX, deltaY);

        retainMatrix.getValues(finalTransformation);
        float finalXTransformation = finalTransformation[Matrix.MTRANS_X];

        float deltaX1 = getScaleDraggingDelta(finalXTransformation, viewWidth,
                afterScaleDrawableWidth * currentScale);

        return deltaX + deltaX1 == 0;
    }

    /**
     * Scale method for zooming
     *
     * @param focusX
     *            X of center of scale
     * @param focusY
     *            Y of center of scale
     * @param scaleFactor
     *            scale factor to zoom in/out
     */
    private void scale(float focusX, float focusY, float scaleFactor) {
        float lastScale = currentScale;
        float newScale = lastScale * scaleFactor;

        // Calculate next scale with resetting to max or min if required
        if (newScale > maxScale) {
            currentScale = maxScale;
            scaleFactor = maxScale / lastScale;
        } else if (newScale < minScale) {
            currentScale = minScale;
            scaleFactor = minScale / lastScale;
        } else {
            currentScale = newScale;
        }

        // Do scale
        if (requireCentering()) {
            matrix.postScale(scaleFactor, scaleFactor, (float) viewWidth / 2,
                    (float) viewHeight / 2);
        } else
            matrix.postScale(scaleFactor, scaleFactor, focusX, focusY);

        limitDrag();
    }

    private float beforLimitDragX;

    /**
     * This method permits to keep drag and zoom inside the drawable. It makes
     * sure the drag is staying in bound.
     */
    private void limitDrag() {
        matrix.getValues(finalTransformation);
        float finalXTransformation = finalTransformation[Matrix.MTRANS_X];
        float finalYTransformation = finalTransformation[Matrix.MTRANS_Y];

        float deltaX = getScaleDraggingDelta(finalXTransformation, viewWidth,
                afterScaleDrawableWidth * currentScale);
        float deltaY = getScaleDraggingDelta(finalYTransformation, viewHeight,
                afterScaleDrawableHeight * currentScale);

        // Edit bu shao
        if (beforLimitDragX + deltaX == 0) {
            startInterceptEvent();
        } else {
            stopInterceptEvent();
        }

        matrix.postTranslate(deltaX, deltaY);
    }

    private float getScaleDraggingDelta(float delta, float viewSize,
                                        float contentSize) {
        float minTrans = 0;
        float maxTrans = 0;

        if (contentSize <= viewSize) {
            maxTrans = viewSize - contentSize;
        } else {
            minTrans = viewSize - contentSize;
        }

        if (delta < minTrans)
            return minTrans - delta;
        else if (delta > maxTrans)
            return maxTrans - delta;
        else
            return 0;
    }

    // Check if dragging is still possible if so return delta otherwise return 0
    // (do nothing)
    private float getMoveDraggingDelta(float delta, float viewSize,
                                       float contentSize) {
        if (contentSize <= viewSize) {
            return 0;
        }
        return delta;
    }

    private float getScaleForDrawable() {
        float scaleX = (float) viewWidth
                / (float) getDrawable().getIntrinsicWidth();
        float scaleY = (float) viewHeight
                / (float) getDrawable().getIntrinsicHeight();
        return Math.min(scaleX, scaleY);
    }

    private boolean hasDrawable() {
        return getDrawable() != null && getDrawable().getIntrinsicWidth() != 0
                && getDrawable().getIntrinsicHeight() != 0;
    }

    private boolean requireCentering() {
        return afterScaleDrawableWidth * currentScale <= (float) viewWidth
                || afterScaleDrawableHeight * currentScale <= (float) viewHeight;
    }

    private boolean isZoom() {
        return currentScale != 1f;
    }

    /**
     * Listener for detecting scale.
     *
     * @author jmartinez
     */
    private class ScaleListener extends
            ScaleGestureDetector.SimpleOnScaleGestureListener {
        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            state = State.ZOOM;
            return true;
        }

        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            scale(detector.getFocusX(), detector.getFocusY(),
                    detector.getScaleFactor());
            return true;
        }
    }

    /**
     * Listener for double tap detection
     *
     * @author jmartinez
     */
    private class GestureListener extends
            GestureDetector.SimpleOnGestureListener {

        @Override
        public boolean onDoubleTap(MotionEvent e) {
            if (isZoom()) {
                resetImage();
            } else {
                scale(e.getX(), e.getY(), maxScale);
            }
            return true;
        }

        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            if(finishActivity!=null)
            {
                finishActivity.finish();
            }
            return true;
        }

        @Override
        public void onLongPress(MotionEvent e) {
            final Dialog dialog = new Dialog(getContext() , R.style.phoneNumDialog);
            setupDialogViews(dialog);
            dialog.show();
        }

        public void setupDialogViews(final Dialog dialog){
            View dialogLyout = LayoutInflater.from(getContext()).inflate(R.layout.tt_dialog_call, null);

            Button callButton = (Button)dialogLyout.findViewById(R.id.call);
            callButton.setText(getContext().getText(R.string.save_image));
            callButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    dialog.dismiss();
                    Toast.makeText(getContext(), "图片已经保存到"+DetailPortraitActivity.imageUri.substring(8), Toast.LENGTH_LONG).show();
                }
            });
            dialog.setContentView(dialogLyout);
        }
    }

}
