package com.mogujie.tt.ui.fragment;

import android.annotation.SuppressLint;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.mogujie.tt.R;

@SuppressLint("SetJavaScriptEnabled")
public class WebviewFragment extends MainFragment {
	private View curView = null;
	private static String url;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        extractUidFromUri();
		if (null != curView) {
            ((ViewGroup) curView.getParent()).removeView(curView);
            return curView;
        }
        curView = inflater.inflate(R.layout.tt_fragment_webview, topContentView);
        super.init(curView);
        showProgressBar();
        initRes();

        return curView;
    }
	
    private void initRes() {
        // 设置顶部标题栏
        setTopTitleBold(getActivity().getString(R.string.main_innernet));
		setTopLeftButton(R.drawable.tt_top_back);
		topLeftContainerLayout.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				getActivity().finish();
			}
		});
		setTopLeftText(getResources().getString(R.string.top_left_back));

        WebView webView = (WebView) curView.findViewById(R.id.webView1);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.loadUrl(url);
        webView.setVerticalScrollBarEnabled(false);
        webView.setHorizontalScrollBarEnabled(false);
        webView.setWebViewClient(new WebViewClient() {

			@Override
			public void onPageFinished(WebView view, String url) {
				setTopTitle(view.getTitle());
                hideProgressBar();
			}

			@Override
			public void onReceivedError(WebView view, int errorCode,
					String description, String failingUrl) {
				// TODO Auto-generated method stub
				super.onReceivedError(view, errorCode, description, failingUrl);
				hideProgressBar();
			}
        	
        });
    }

	@Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected void initHandler() {
    }
    
	/**
     * @param str
     */
	public static void setUrl(String str) {
		url = str;
	}

    private static final String SCHEMA ="com.mogujie.tt://message_private_url";
    private static final String PARAM_UID ="uid";
    private static final Uri PROFILE_URI = Uri.parse(SCHEMA);
    private void extractUidFromUri() {
        Uri uri = getActivity().getIntent().getData();
        if (uri !=null && PROFILE_URI.getScheme().equals(uri.getScheme())) {
            url = uri.getQueryParameter(PARAM_UID);
        }
        if(url.indexOf("www") == 0){
            url = "http://"+url;
        }else if(url.indexOf("https") == 0){
            String bUid = url.substring(5, url.length());
            url = "http"+bUid;
        }
    }
}
