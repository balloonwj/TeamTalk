package com.mogujie.tt.ui.fragment;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.mogujie.tt.DB.entity.DepartmentEntity;
import com.mogujie.tt.DB.entity.GroupEntity;
import com.mogujie.tt.DB.entity.UserEntity;
import com.mogujie.tt.R;
import com.mogujie.tt.config.HandlerConstant;
import com.mogujie.tt.imservice.event.GroupEvent;
import com.mogujie.tt.imservice.event.UserInfoEvent;
import com.mogujie.tt.imservice.support.IMServiceConnector;
import com.mogujie.tt.imservice.manager.IMContactManager;
import com.mogujie.tt.imservice.service.IMService;
import com.mogujie.tt.ui.adapter.ContactAdapter;
import com.mogujie.tt.ui.adapter.DeptAdapter;
import com.mogujie.tt.ui.widget.SortSideBar;
import com.mogujie.tt.ui.widget.SortSideBar.OnTouchingLetterChangedListener;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.PauseOnScrollListener;

import java.util.List;

import de.greenrobot.event.EventBus;

/**
 * 通讯录 （全部、部门）
 */
public class ContactFragment extends MainFragment implements OnTouchingLetterChangedListener {
    private View curView = null;
    private static Handler uiHandler = null;
    private ListView allContactListView;
    private ListView departmentContactListView;
    private SortSideBar sortSideBar;
    private TextView dialog;

    private ContactAdapter contactAdapter;
    private DeptAdapter departmentAdapter;

    private IMService imService;
    private IMContactManager contactMgr;
    private int curTabIndex = 0;

    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onIMServiceConnected() {
            logger.d("contactUI#onIMServiceConnected");

            imService = imServiceConnector.getIMService();
            if (imService == null) {
                logger.e("ContactFragment#onIMServiceConnected# imservice is null!!");
                return;
            }
            contactMgr = imService.getContactManager();

            // 初始化视图
            initAdapter();
            renderEntityList();
            EventBus.getDefault().registerSticky(ContactFragment.this);
        }

        @Override
        public void onServiceDisconnected() {
            if (EventBus.getDefault().isRegistered(ContactFragment.this)) {
                EventBus.getDefault().unregister(ContactFragment.this);
            }
        }
    };


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        imServiceConnector.connect(getActivity());
        initHandler();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (EventBus.getDefault().isRegistered(ContactFragment.this)) {
            EventBus.getDefault().unregister(ContactFragment.this);
        }
        imServiceConnector.disconnect(getActivity());
    }


    @SuppressLint("HandlerLeak")
    @Override
    protected void initHandler() {
        uiHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                switch (msg.what) {
                    case HandlerConstant.HANDLER_CHANGE_CONTACT_TAB:
                        if (null != msg.obj) {
                            curTabIndex = (Integer) msg.obj;
                            if (0 == curTabIndex) {
                                allContactListView.setVisibility(View.VISIBLE);
                                departmentContactListView.setVisibility(View.GONE);
                            } else {
                                departmentContactListView.setVisibility(View.VISIBLE);
                                allContactListView.setVisibility(View.GONE);
                            }
                        }
                        break;
                }
            }
        };
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        if (null != curView) {
            ((ViewGroup) curView.getParent()).removeView(curView);
            return curView;
        }
        curView = inflater.inflate(R.layout.tt_fragment_contact, topContentView);
        initRes();
        return curView;
    }

    /**
     * @Description 初始化界面资源
     */
    private void initRes() {
        // 设置顶部标题栏
        showContactTopBar();
        hideTopBar();

        super.init(curView);
        showProgressBar();

        sortSideBar = (SortSideBar) curView.findViewById(R.id.sidrbar);
        dialog = (TextView) curView.findViewById(R.id.dialog);
        sortSideBar.setTextView(dialog);
        sortSideBar.setOnTouchingLetterChangedListener(this);

        allContactListView = (ListView) curView.findViewById(R.id.all_contact_list);
        departmentContactListView = (ListView) curView.findViewById(R.id.department_contact_list);

        //this is critical, disable loading when finger sliding, otherwise you'll find sliding is not very smooth
        allContactListView.setOnScrollListener(new PauseOnScrollListener(ImageLoader.getInstance(), true, true));
        departmentContactListView.setOnScrollListener(new PauseOnScrollListener(ImageLoader.getInstance(), true, true));
        // todo eric
        // showLoadingProgressBar(true);
    }

    private void initAdapter(){
        contactAdapter = new ContactAdapter(getActivity(),imService);
        departmentAdapter = new DeptAdapter(getActivity(),imService);
        allContactListView.setAdapter(contactAdapter);
        departmentContactListView.setAdapter(departmentAdapter);

        // 单击视图事件
        allContactListView.setOnItemClickListener(contactAdapter);
        allContactListView.setOnItemLongClickListener(contactAdapter);

        departmentContactListView.setOnItemClickListener(departmentAdapter);
        departmentContactListView.setOnItemLongClickListener(departmentAdapter);
    }

    public void locateDepartment(int departmentId) {
        logger.d("department#locateDepartment id:%s", departmentId);

        if (topContactTitle == null) {
            logger.e("department#TopTabButton is null");
            return;
        }
        Button tabDepartmentBtn = topContactTitle.getTabDepartmentBtn();
        if (tabDepartmentBtn == null) {
            return;
        }
        tabDepartmentBtn.performClick();
        locateDepartmentImpl(departmentId);
    }

    private void locateDepartmentImpl(int departmentId) {
        if (imService == null) {
            return;
        }
        DepartmentEntity department = imService.getContactManager().findDepartment(departmentId);
        if (department == null) {
            logger.e("department#no such id:%s", departmentId);
            return;
        }

        logger.d("department#go to locate department:%s", department);
        final int position = departmentAdapter.locateDepartment(department.getDepartName());
        logger.d("department#located position:%d", position);

        if (position < 0) {
            logger.i("department#locateDepartment id:%s failed", departmentId);
            return;
        }
        //the first time locate works
        //from the second time, the locating operations fail ever since
        departmentContactListView.post(new Runnable() {

            @Override
            public void run() {
                departmentContactListView.setSelection(position);
            }
        });
    }


    /**
     * 刷新单个entity
     * 很消耗性能
     */
    private void renderEntityList() {
        hideProgressBar();
        logger.d("contact#renderEntityList");

        if (contactMgr.isUserDataReady() ) {
            renderUserList();
            renderDeptList();
        }
        if (imService.getGroupManager().isGroupReady()) {
            renderGroupList();
        }
        showSearchFrameLayout();
    }


    private void renderDeptList(){
        /**---------------------部门数据的渲染------------------------------------------*/
        List<UserEntity> departmentList = contactMgr.getDepartmentTabSortedList();
        departmentAdapter.putUserList(departmentList);
    }

    private void renderUserList(){
        List<UserEntity> contactList = contactMgr.getContactSortedList();
        // 没有任何的联系人数据
        if (contactList.size() <= 0) {
            return;
        }
        contactAdapter.putUserList(contactList);
    }

    private void renderGroupList() {
        logger.d("group#onGroupReady");
        List<GroupEntity> originList = imService.getGroupManager().getNormalGroupSortedList();
        if(originList.size() <= 0){
            return;
        }
        contactAdapter.putGroupList(originList);
    }

    private ListView getCurListView() {
        if (0 == curTabIndex) {
            return allContactListView;
        } else {
            return departmentContactListView;
        }
    }

    @Override
    public void onTouchingLetterChanged(String s) {
        int position = -1;
        if (0 == curTabIndex) {
            position =  contactAdapter.getPositionForSection(s.charAt(0));
        } else {
            position =  departmentAdapter.getPositionForSection(s.charAt(0));
        }
        if (position != -1) {
            getCurListView().setSelection(position);
        }
    }

    public static Handler getHandler() {
        return uiHandler;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    public void onEventMainThread(GroupEvent event) {
        switch (event.getEvent()) {
            case GROUP_INFO_UPDATED:
            case GROUP_INFO_OK:
                renderGroupList();
                searchDataReady();
                break;
        }
    }

    public void onEventMainThread(UserInfoEvent event) {
        switch (event) {
            case USER_INFO_UPDATE:
            case USER_INFO_OK:
                renderDeptList();
                renderUserList();
                searchDataReady();
                break;
        }
    }

    public void searchDataReady() {
        if (imService.getContactManager().isUserDataReady() &&
                imService.getGroupManager().isGroupReady()) {
            showSearchFrameLayout();
        }
    }
}
