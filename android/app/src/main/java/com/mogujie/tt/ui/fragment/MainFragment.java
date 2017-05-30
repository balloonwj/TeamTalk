package com.mogujie.tt.ui.fragment;

import android.view.View;
import android.widget.ProgressBar;

import com.mogujie.tt.R;
import com.mogujie.tt.ui.base.TTBaseFragment;

public abstract class MainFragment extends TTBaseFragment {
	private ProgressBar progressbar;

	public void init(View curView) {
		progressbar = (ProgressBar) curView.findViewById(R.id.progress_bar);
	}

	public void showProgressBar() {
		progressbar.setVisibility(View.VISIBLE);
	}

	public void hideProgressBar() {
		progressbar.setVisibility(View.GONE);
	}

}
