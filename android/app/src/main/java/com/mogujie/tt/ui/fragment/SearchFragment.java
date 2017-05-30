package com.mogujie.tt.ui.fragment;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import com.mogujie.tools.ScreenTools;
import com.mogujie.tt.DB.entity.DepartmentEntity;
import com.mogujie.tt.DB.entity.GroupEntity;
import com.mogujie.tt.DB.entity.UserEntity;
import com.mogujie.tt.R;
import com.mogujie.tt.imservice.support.IMServiceConnector;
import com.mogujie.tt.imservice.service.IMService;
import com.mogujie.tt.ui.adapter.SearchAdapter;
import com.mogujie.tt.ui.base.TTBaseFragment;
import com.mogujie.tt.utils.Logger;

import java.util.List;

/**
 * @yingmu  modify
 */
public class SearchFragment extends TTBaseFragment {

	private Logger logger = Logger.getLogger(SearchFragment.class);
	private View curView = null;
	private ListView listView;
    private View noSearchResultView;
	private SearchAdapter adapter;
	IMService imService;

    private IMServiceConnector imServiceConnector = new IMServiceConnector(){
        @Override
        public void onIMServiceConnected() {
            logger.d("config#onIMServiceConnected");
            imService = imServiceConnector.getIMService();
            //init set adapter service
            initAdapter();
        }
        @Override
        public void onServiceDisconnected() {
        }
    };

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		imServiceConnector.connect(this.getActivity());
		if (null != curView) {
			((ViewGroup) curView.getParent()).removeView(curView);
			return curView;
		}
		curView = inflater.inflate(R.layout.tt_fragment_search, topContentView);
        noSearchResultView = curView.findViewById(R.id.layout_no_search_result);
		initTopBar();
        listView = (ListView) curView.findViewById(R.id.search);
		return curView;
	}

	@Override
	public void onResume() {
		super.onResume();
	}

	private void initTopBar() {
		setTopBar(R.drawable.tt_top_default_bk);
		showTopSearchBar();
		setTopLeftButton(R.drawable.tt_top_back);
		hideTopRightButton();

        topLeftBtn.setPadding(0, 0, ScreenTools.instance(getActivity()).dip2px(30), 0);
		topLeftBtn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View arg0) {
                getActivity().finish();
            }
        });

		topSearchEdt.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				String key = s.toString();
				adapter.setSearchKey(key);
                if(key.isEmpty())
                {
                    adapter.clear();
                    noSearchResultView.setVisibility(View.GONE);
                }else{
                    searchEntityLists(key);
                }
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {}
			@Override
			public void afterTextChanged(Editable s) {
			}
		});
	}

    private void initAdapter(){
        adapter = new SearchAdapter(getActivity(),imService);
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(adapter);
        listView.setOnItemLongClickListener(adapter);
    }

    // 文字高亮search 模块
	private void searchEntityLists(String key) {
        List<UserEntity> contactList = imService.getContactManager().getSearchContactList(key);
        int contactSize = contactList.size();
        adapter.putUserList(contactList);

        List<GroupEntity> groupList = imService.getGroupManager().getSearchAllGroupList(key);
        int groupSize = groupList.size();
        adapter.putGroupList(groupList);

        List<DepartmentEntity> departmentList = imService.getContactManager().getSearchDepartList(key);
        int deptSize = departmentList.size();
        adapter.putDeptList(departmentList);

        int sum = contactSize + groupSize +deptSize;
        adapter.notifyDataSetChanged();
        if(sum <= 0){
            noSearchResultView.setVisibility(View.VISIBLE);
        }else{
            noSearchResultView.setVisibility(View.GONE);
        }
	}

  	@Override
	protected void initHandler() {
	}

    @Override
    public void onDestroy() {
        imServiceConnector.disconnect(getActivity());
        super.onDestroy();
    }
}
