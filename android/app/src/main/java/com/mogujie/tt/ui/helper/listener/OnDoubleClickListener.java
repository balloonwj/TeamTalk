package com.mogujie.tt.ui.helper.listener;

import android.os.Handler;
import android.os.Message;
import android.view.MotionEvent;
import android.view.View;

/**
 * @author : yingmu on 15-1-10.
 * @email : yingmu@mogujie.com.
 *
 */
public  abstract class OnDoubleClickListener implements View.OnTouchListener {
    private volatile int count = 0;
    private final int HANDLER_ON_CLICK = 1;

    /**
     * Called when a touch event is dispatched to a view. This allows listeners to
     * get a chance to respond before the target view.
     *
     * @param v     The view the touch event has been dispatched to.
     * @param event The MotionEvent object containing full information about
     *              the event.
     * @return True if the listener has consumed the event, false otherwise.
     */
    @Override
    public boolean onTouch(final View v, MotionEvent event) {
        if (MotionEvent.ACTION_DOWN == event.getAction()) {
            count++;
            if (count == 1) {
                Handler handler = new Handler(){
                    @Override
                    public void handleMessage(Message msg) {
                        super.handleMessage(msg);
                        switch (msg.what){
                            case HANDLER_ON_CLICK:{
                                if(count == 1){
                                    count = 0;
                                    onClick(v);
                                }

                            }break;
                        }
                    }
                };

                Message m = Message.obtain(handler);
                m.what = HANDLER_ON_CLICK;
                handler.sendMessageDelayed(m, 200);
                /**事件没有被消费完*/
                return false;
            } else if (count == 2) {
                count = 0;
                onDoubleClick(v);
                /**事件不再往下面传递*/
                return true;
            }
        }
        return false;
    }

    public abstract void onDoubleClick(View view);
    public abstract void onClick(View view);
}
