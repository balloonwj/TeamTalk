
package com.mogujie.tt.ui.widget;

import android.app.Dialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup.MarginLayoutParams;
import android.widget.Button;
import android.widget.TextView;

import com.mogujie.tools.ScreenTools;
import com.mogujie.tt.R;

/**
 * Dialog基类，提供基本的“确定”，“取消”按钮和title与message的显示。子类可以继承Builder,在content
 * layout中添加其他控件进行自定义。tips:cancel的回调不需要调用dialog.dismiss()，控件会自动调用
 * 
 * @author dolphinWang
 */

public class MGDialog extends Dialog implements View.OnClickListener {

    private OnButtonClickListener mOnButtonClickListener;

    protected View mDialogContentView;

    private boolean mButtonInverse;

    public MGDialog(Context context) {
        super(context);
    }

    public MGDialog(Context context, int Theme) {
        super(context, Theme);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (R.id.imPositiveButton == id)
        {
            if (mOnButtonClickListener != null) {
                if (mButtonInverse) {
                    mOnButtonClickListener.onCancelButtonClick(this);
                    dismiss();
                } else {
                    mOnButtonClickListener.onOKButtonClick(this);
                }
            }
        }
        else if (R.id.imNegativeButton == id) {
            if (mOnButtonClickListener != null) {
                if (mButtonInverse) {
                    mOnButtonClickListener.onOKButtonClick(this);
                } else {
                    mOnButtonClickListener.onCancelButtonClick(this);
                    dismiss();
                }
            }
        }
    }

    public void setOnButtonClickListener(OnButtonClickListener l) {
        mOnButtonClickListener = l;
    }

    public void setTitleText(String text) {
        if (TextUtils.isEmpty(text)) {
            return;
        }

        ((TextView) mDialogContentView.findViewById(R.id.imTitle)).setText(text);
    }

    public void setSubTitleText(String text) {
        if (TextUtils.isEmpty(text)) {
            return;
        }

        ((TextView) mDialogContentView.findViewById(R.id.imSubTitle))
                .setText(text);
    }

    @Override
    public void show() {
        super.show();
        setContentView(mDialogContentView);
    }

    public interface OnButtonClickListener {
        public void onOKButtonClick(MGDialog dialog);

        public void onCancelButtonClick(MGDialog dialog);
    }

    public static class DialogBuilder {
        protected String positiveButtonText;
        protected String negativeButtonText;
        protected String titleText;
        protected String subTitleText;
        protected boolean buttonInverse;

        protected int subTitleTextGravity = Integer.MIN_VALUE;

        protected MGDialog dialog;

        protected Context context;

        protected View dialogLayout;

        protected LayoutInflater mInflater;

        public DialogBuilder(Context context) {
            this.context = context;

            mInflater = LayoutInflater.from(context);
        }

        public DialogBuilder setPositiveButtonText(String positiveButtonText) {
            this.positiveButtonText = positiveButtonText;

            return this;
        }

        public DialogBuilder setNegativeButtonText(String negativeButtonText) {
            this.negativeButtonText = negativeButtonText;

            return this;
        }

        public DialogBuilder setTitleText(String titleText) {
            this.titleText = titleText;

            return this;
        }

        public DialogBuilder setSubTitleText(String subTitleText) {
            this.subTitleText = subTitleText;

            return this;
        }

        public DialogBuilder setSubTitleTextGravity(int gravity) {
            this.subTitleTextGravity = gravity;

            return this;
        }

        public DialogBuilder inverseButton() {
            buttonInverse = true;

            return this;
        }

        protected void setupViews() {

            dialog.getWindow().getAttributes().gravity = Gravity.CENTER;
            // dialog.getWindow().setWindowAnimations(R.style.PopupAnimation);

            dialogLayout = mInflater.inflate(R.layout.tt_view_dialog_base, null);

            Button okBtn = (Button) dialogLayout
                    .findViewById(R.id.imPositiveButton);
            if (!TextUtils.isEmpty(positiveButtonText)) {
                okBtn.setOnClickListener(dialog);
                okBtn.setText(positiveButtonText);
            } else {
                okBtn.setVisibility(View.GONE);
            }

            Button cancelBtn = (Button) dialogLayout
                    .findViewById(R.id.imNegativeButton);
            if (!TextUtils.isEmpty(negativeButtonText)) {
                cancelBtn.setOnClickListener(dialog);
                cancelBtn.setText(negativeButtonText);
            } else {
                cancelBtn.setVisibility(View.GONE);

                MarginLayoutParams mlp = (MarginLayoutParams) okBtn.getLayoutParams();
                mlp.leftMargin = 0;
            }

            TextView titleView = (TextView) dialogLayout
                    .findViewById(R.id.imTitle);
            if (!TextUtils.isEmpty(titleText)) {
                titleView.setVisibility(View.VISIBLE);
                titleView.setText(titleText);
            }

            if (!TextUtils.isEmpty(subTitleText)) {
                TextView subTitleView = (TextView) dialogLayout
                        .findViewById(R.id.imSubTitle);
                subTitleView.setVisibility(View.VISIBLE);
                subTitleView.setText(subTitleText);

                if (subTitleTextGravity != Integer.MIN_VALUE) {
                    subTitleView.setGravity(subTitleTextGravity);
                }
            } else {
                // title 需要设置一下bottom margin
                MarginLayoutParams mlp = (MarginLayoutParams) titleView
                        .getLayoutParams();
                mlp.bottomMargin = ScreenTools.instance(context).dip2px(30);
            }

            dialog.mDialogContentView = dialogLayout;
            dialog.mButtonInverse = buttonInverse;
        }

        /**
         * @return
         */
        public MGDialog build() {
            dialog = new MGDialog(context, R.style.imDialog);

            setupViews();
            return dialog;
        }
    }
}
