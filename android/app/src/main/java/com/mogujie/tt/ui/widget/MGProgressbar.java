
package com.mogujie.tt.ui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.mogujie.tt.R;

public class MGProgressbar extends LinearLayout {

    private ProgressBar mProgressBar;
    private TextView mLoadingText;
    private Button mRefreshButton;
    private boolean mbTextShow = true;

    public interface OnRefreshBtnListener {
        void onRefresh();
    }

    public MGProgressbar(Context context) {
        this(context, null);
    }

    public MGProgressbar(Context context, AttributeSet attrs) {
        super(context, attrs);
        setOrientation(LinearLayout.VERTICAL);
        LayoutInflater inflater = (LayoutInflater) context.getSystemService
                (Context.LAYOUT_INFLATER_SERVICE);

        inflater.inflate(R.layout.tt_progress, this, true);
        mProgressBar = (ProgressBar) findViewById(R.id.progress_bar);
        mLoadingText = (TextView) findViewById(R.id.loading_text);
        mRefreshButton = (Button) findViewById(R.id.refresh_button);

        hideProgress();
    }

    public void showProgress() {
        mProgressBar.setVisibility(View.VISIBLE);
        if (mbTextShow) {
            mLoadingText.setVisibility(View.VISIBLE);
        }
        mRefreshButton.setVisibility(View.GONE);
    }

    public void hideProgress() {
        mProgressBar.setVisibility(View.GONE);
        mLoadingText.setVisibility(View.GONE);
        mRefreshButton.setVisibility(View.GONE);
    }

    public void showRefreshBtn() {
        mRefreshButton.setVisibility(View.VISIBLE);
        mProgressBar.setVisibility(View.GONE);
        mLoadingText.setVisibility(View.GONE);
    }

    public void setRefreshBtnListener(final OnRefreshBtnListener listener) {
        mRefreshButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                showProgress();
                listener.onRefresh();
            }
        });
    }

    public void setShowText(boolean bShow) {
        mbTextShow = bShow;
    }

    public void setText(String text) {
        mLoadingText.setText(text);
    }
}
