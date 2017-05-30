
package com.mogujie.tt.ui.widget;

import android.app.Activity;
import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.mogujie.tt.R;

public class SpeekerToast {
    public static void show(Context context, CharSequence text, int duration) {
        LayoutInflater inflater = ((Activity) context).getLayoutInflater();
        View view = inflater.inflate(R.layout.tt_speeker_layout, null);
        TextView title = (TextView) view.findViewById(R.id.top_tip);
        title.setText(text);
        Toast toast = new Toast(context.getApplicationContext());
        toast.setGravity(
                Gravity.FILL_HORIZONTAL | Gravity.TOP,
                0,
                (int) context.getResources().getDimension(
                        R.dimen.top_bar_default_height));
        toast.setDuration(duration);
        toast.setView(view);
        toast.show();
    }

}
