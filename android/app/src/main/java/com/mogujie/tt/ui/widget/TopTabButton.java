
package com.mogujie.tt.ui.widget;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;

import com.mogujie.tt.R;
import com.mogujie.tt.config.HandlerConstant;
import com.mogujie.tt.ui.fragment.ContactFragment;

public class TopTabButton extends FrameLayout {
    private Context context = null;
    private Button tabALLBtn = null;
    private Button tabDepartmentBtn = null;

    public Button getTabDepartmentBtn() {
		return tabDepartmentBtn;
	}

	public TopTabButton(Context cxt) {
        super(cxt);
        this.context = cxt;
        initView();
    }

    public TopTabButton(Context cxt, AttributeSet attrs) {
        super(cxt,attrs);
        this.context = cxt;
        initView();
    }

    public TopTabButton(Context cxt, AttributeSet attrs, int defStyle) {
        super(cxt, attrs, defStyle);
        this.context = cxt;
        initView();
    }

    private void initView() {
        // 加载布局
        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        inflater.inflate(R.layout.tt_top_tab_button, this);

        tabALLBtn = (Button) findViewById(R.id.all_btn);
        tabDepartmentBtn = (Button) findViewById(R.id.department_btn);

        // tabDepartmentBtn.setText(context.getString(R.string.contact_department));
        // tabDepartmentBtn.setBackgroundResource(R.drawable.contact_top_right_nor);
        tabDepartmentBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Handler handler = ContactFragment.getHandler();
                Message message = handler.obtainMessage();
                message.what=HandlerConstant.HANDLER_CHANGE_CONTACT_TAB;
                message.obj = 1;
                handler.sendMessage(message);

                setSelTextColor(1);
                tabDepartmentBtn.setBackgroundResource(R.drawable.tt_contact_top_right_sel);
                tabALLBtn.setBackgroundResource(R.drawable.tt_contact_top_left_nor);
            }
        });

        // tabALLBtn.setText(context.getString(R.string.contact_all));
        // tabALLBtn.setBackgroundResource(R.drawable.contact_top_left_sel);
        tabALLBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Handler handler = ContactFragment.getHandler();
                Message message = handler.obtainMessage();
                message.what=HandlerConstant.HANDLER_CHANGE_CONTACT_TAB;
                message.obj = 0;
                handler.sendMessage(message);

                setSelTextColor(0);
                tabALLBtn.setBackgroundResource(R.drawable.tt_contact_top_left_sel);
                tabDepartmentBtn.setBackgroundResource(R.drawable.tt_contact_top_right_nor);
            }
        });

    }

    private void setSelTextColor(int index) {
        if (0 == index) {
            tabALLBtn.setTextColor(getResources().getColor(android.R.color.white));
            tabDepartmentBtn.setTextColor(getResources().getColor(R.color.default_blue_color));
        } else {
            tabDepartmentBtn.setTextColor(getResources().getColor(android.R.color.white));
            tabALLBtn.setTextColor(getResources().getColor(R.color.default_blue_color));
        }

    }
}
