/**
 * @author zhouzhengnan
 * @date 20 Oct 2013
 */

package com.mogujie.tt.ui.widget;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.mogujie.tools.ScreenTools;
import com.mogujie.tt.R;

/**
 * @author zhouzhengnan
 * @date 20 Oct 2013
 */
public class PinkToast extends Toast {

    /**
     * @param context
     */
    public PinkToast(Context context) {
        super(context);
    }

    public static Toast makeText(Context context, CharSequence text, int duration) {
        Toast result = Toast.makeText(context, text, duration);
        result.getView().setBackgroundResource(R.drawable.tt_waterfall_refresh_bg);
        result.setGravity(Gravity.CENTER, 0, 0);
        TextView tv = (TextView) ((ViewGroup) result.getView()).getChildAt(0);
        ScreenTools tools = ScreenTools.instance(context);

        tv.setPadding(tools.dip2px(5), tools.dip2px(8), tools.dip2px(5),
                tools.dip2px(8));
        tv.setShadowLayer(0, 0, 0, Color.TRANSPARENT);
        tv.setMinWidth(tools.dip2px(180));
        tv.setGravity(Gravity.CENTER);
        tv.setTextColor(context.getResources().getColor(android.R.color.white));
        return result;
    }

    public static Toast makeText(Context context, int id, int duration) {
        Toast result = Toast.makeText(context, id, duration);
        result.getView().setBackgroundResource(R.drawable.tt_waterfall_refresh_bg);
        result.setGravity(Gravity.CENTER, 0, 0);
        TextView tv = (TextView) ((ViewGroup) result.getView()).getChildAt(0);
        ScreenTools tools = ScreenTools.instance(context);

        tv.setPadding(tools.dip2px(5), tools.dip2px(8), tools.dip2px(5),
                tools.dip2px(8));
        tv.setShadowLayer(0, 0, 0, Color.TRANSPARENT);
        tv.setMinWidth(tools.dip2px(180));
        tv.setGravity(Gravity.CENTER);
        tv.setTextColor(context.getResources().getColor(android.R.color.white));
        return result;
    }

    public void show() {
        super.show();
    }

}
