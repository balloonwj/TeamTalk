package com.mogujie.tt.ui.fragment;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.mogujie.tt.DB.entity.GroupEntity;
import com.mogujie.tt.DB.entity.PeerEntity;
import com.mogujie.tt.DB.entity.UserEntity;
import com.mogujie.tt.R;
import com.mogujie.tt.config.DBConstant;
import com.mogujie.tt.config.IntentConstant;
import com.mogujie.tt.imservice.event.GroupEvent;
import com.mogujie.tt.imservice.support.IMServiceConnector;
import com.mogujie.tt.imservice.manager.IMGroupManager;
import com.mogujie.tt.imservice.service.IMService;
import com.mogujie.tt.ui.adapter.GroupSelectAdapter;
import com.mogujie.tt.ui.widget.SearchEditText;
import com.mogujie.tt.ui.widget.SortSideBar;
import com.mogujie.tt.ui.widget.SortSideBar.OnTouchingLetterChangedListener;
import com.mogujie.tt.utils.IMUIHelper;
import com.mogujie.tt.utils.Logger;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import de.greenrobot.event.EventBus;


/**
 * @YM  - -!
 * 1. 创建群的时候，跳到聊天页面
 * 2. 新增人员的时候，返回到聊天详情页面
 */
public class GroupMemberSelectFragment extends MainFragment
        implements OnTouchingLetterChangedListener {

    private static Logger logger = Logger.getLogger(GroupMemberSelectFragment.class);

    private View curView = null;
    private IMService imService;

    /**列表视图
     * 1. 需要两种状态:选中的成员List  --》确定之后才会回话页面或者详情
     * 2. 已经被选的状态 -->已经在群中的成员
     * */
    private GroupSelectAdapter adapter;
    private ListView contactListView;

    private SortSideBar sortSideBar;
    private TextView dialog;
    private SearchEditText searchEditText;

    private String curSessionKey;
    private PeerEntity peerEntity;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EventBus.getDefault().register(this);
        imServiceConnector.connect(getActivity());
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
        imServiceConnector.disconnect(getActivity());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        if (null != curView) {
            ((ViewGroup) curView.getParent()).removeView(curView);
            return curView;
        }
        curView = inflater.inflate(R.layout.tt_fragment_group_member_select, topContentView);
        super.init(curView);
        initRes();
        return curView;
    }


    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }


    /**
     * 获取列表中 默认选中成员列表
     * @return
     */
    private Set<Integer> getAlreadyCheckList(){
        Set<Integer> alreadyListSet = new HashSet<>();
        if(peerEntity == null){
            Toast.makeText(getActivity(), getString(R.string.error_group_info), Toast.LENGTH_SHORT).show();
            getActivity().finish();
            logger.e("[fatal error,groupInfo is null,cause by SESSION_TYPE_GROUP]");
            //return Collections.emptySet();
        }
        switch (peerEntity.getType()){
            case DBConstant.SESSION_TYPE_GROUP:{
                GroupEntity entity = (GroupEntity) peerEntity;
                alreadyListSet.addAll(entity.getlistGroupMemberIds());
            }break;

            case DBConstant.SESSION_TYPE_SINGLE:{
                int loginId = imService.getLoginManager().getLoginId();
                alreadyListSet.add(loginId);
                alreadyListSet.add(peerEntity.getPeerId());
            }break;
        }
        return alreadyListSet;
    }

    private IMServiceConnector imServiceConnector = new IMServiceConnector(){
        @Override
        public void onIMServiceConnected() {
            logger.d("groupselmgr#onIMServiceConnected");

            imService = imServiceConnector.getIMService();
            Intent intent = getActivity().getIntent();
            curSessionKey = intent.getStringExtra(IntentConstant.KEY_SESSION_KEY);
            peerEntity = imService.getSessionManager().findPeerEntity(curSessionKey);
            /**已经处于选中状态的list*/
            Set<Integer> alreadyList = getAlreadyCheckList();
            initContactList(alreadyList);
        }

        @Override
        public void onServiceDisconnected() {}
    };


    private void initContactList(final Set<Integer> alreadyList) {
        // 根据拼音排序
        adapter = new GroupSelectAdapter(getActivity(),imService);
        contactListView.setAdapter(adapter);

        contactListView.setOnItemClickListener(adapter);
        contactListView.setOnItemLongClickListener(adapter);

        List<UserEntity> contactList = imService.getContactManager().getContactSortedList();
        adapter.setAllUserList(contactList);
        adapter.setAlreadyListSet(alreadyList);
    }


    /**
     * @Description 初始化资源
     */
    private void initRes() {
        // 设置标题栏
        // todo eric
        setTopTitle(getString(R.string.choose_contact));
        setTopRightText(getActivity().getString(R.string.confirm));
        topLeftContainerLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getActivity().finish();
            }
        });
        setTopLeftText(getResources().getString(R.string.cancel));

        topRightTitleTxt.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View arg0) {
                logger.d("tempgroup#on 'save' btn clicked");

                if(adapter.getCheckListSet().size()<=0){
                    Toast.makeText(getActivity(), getString(R.string.select_group_member_empty), Toast.LENGTH_SHORT).show();
                    return;
                }

                Set<Integer> checkListSet =  adapter.getCheckListSet();
                IMGroupManager groupMgr = imService.getGroupManager();
                //从个人过来的，创建群，默认自己是加入的，对方的sessionId也是加入的
                //自己与自己对话，也能创建群的，这个时候要判断，群组成员一定要大于2个
                int sessionType = peerEntity.getType();
                if (sessionType == DBConstant.SESSION_TYPE_SINGLE) {
                    int loginId = imService.getLoginManager().getLoginId();
                    logger.d("tempgroup#loginId:%d", loginId);
                    checkListSet.add(loginId);
                    checkListSet.add(peerEntity.getPeerId());
                    logger.d("tempgroup#memberList size:%d", checkListSet.size());
                    ShowDialogForTempGroupname(groupMgr, checkListSet);
                } else if (sessionType == DBConstant.SESSION_TYPE_GROUP) {
                    showProgressBar();
                    imService.getGroupManager().reqAddGroupMember(peerEntity.getPeerId(),checkListSet);
                }
            }


            private void ShowDialogForTempGroupname(final IMGroupManager groupMgr,final Set<Integer> memberList) {
                AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(getActivity(),
                        android.R.style.Theme_Holo_Light_Dialog));

                LayoutInflater inflater = (LayoutInflater)getActivity().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                View dialog_view = inflater.inflate(R.layout.tt_custom_dialog, null);
                final EditText editText = (EditText)dialog_view.findViewById(R.id.dialog_edit_content);
                TextView textText = (TextView)dialog_view.findViewById(R.id.dialog_title);
                textText.setText(R.string.create_temp_group_dialog_title);
                builder.setView(dialog_view);

                builder.setPositiveButton(getString(R.string.tt_ok), new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        String tempGroupName = editText.getText().toString();
                        tempGroupName = tempGroupName.trim();
                        showProgressBar();
                        groupMgr.reqCreateTempGroup(tempGroupName,memberList);
                    }
                });
                builder.setNegativeButton(getString(R.string.tt_cancel), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        InputMethodManager inputManager =
                                (InputMethodManager)editText.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                        inputManager.hideSoftInputFromWindow(editText.getWindowToken(),0);
                    }
                });
                final AlertDialog alertDialog = builder.create();

                /**只有输入框中有值的时候,确定按钮才可以按下*/
                editText.addTextChangedListener(new TextWatcher() {
                    @Override
                    public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
                    @Override
                    public void onTextChanged(CharSequence s, int start, int before, int count) {}

                    @Override
                    public void afterTextChanged(Editable s) {
                       if(TextUtils.isEmpty(s.toString().trim())){
                           alertDialog.getButton(AlertDialog.BUTTON_POSITIVE).setEnabled(false);
                        }else{
                           alertDialog.getButton(AlertDialog.BUTTON_POSITIVE).setEnabled(true);
                       }
                    }
                });

                alertDialog.show();
                alertDialog.getButton(AlertDialog.BUTTON_POSITIVE).setEnabled(false);

                /**对话框弹出的时候，下面的键盘也要跟上来*/
                Timer timer = new Timer();
                timer.schedule(new TimerTask(){
                    @Override
                    public void run() {
                        InputMethodManager inputManager =
                                (InputMethodManager)editText.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);

                        inputManager.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
                    }
                }, 100);
            }
        });

        sortSideBar = (SortSideBar) curView.findViewById(R.id.sidrbar);
        sortSideBar.setOnTouchingLetterChangedListener(this);

        dialog = (TextView) curView.findViewById(R.id.dialog);
        sortSideBar.setTextView(dialog);

        contactListView = (ListView) curView.findViewById(R.id.all_contact_list);
        contactListView.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                 //如果存在软键盘，关闭掉
                InputMethodManager imm = (InputMethodManager)getActivity().getSystemService(
                        Context.INPUT_METHOD_SERVICE);
                //txtName is a reference of an EditText Field
                imm.hideSoftInputFromWindow(searchEditText.getWindowToken(), 0);
                }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
            }
        });

        searchEditText = (SearchEditText) curView.findViewById(R.id.filter_edit);
        searchEditText.addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                                      int count) {

                String key = s.toString();
                if(TextUtils.isEmpty(key)){
                    adapter.recover();
                    sortSideBar.setVisibility(View.VISIBLE);
                }else{
                    sortSideBar.setVisibility(View.INVISIBLE);
                    adapter.onSearch(key);
                }
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
    }


    public void onEventMainThread(GroupEvent event){
        switch (event.getEvent()){
            case CHANGE_GROUP_MEMBER_SUCCESS:
                handleGroupMemChangeSuccess(event);
                break;
            case CHANGE_GROUP_MEMBER_FAIL:
            case CHANGE_GROUP_MEMBER_TIMEOUT:
                handleChangeGroupMemFail();
                break;
            case CREATE_GROUP_OK:
                handleCreateGroupSuccess(event);
                break;
            case CREATE_GROUP_FAIL:
            case CREATE_GROUP_TIMEOUT:
                handleCreateGroupFail();
                break;

        }
    }

    /**
     * 处理群创建成功、失败事件
     * @param event
     */
    private void handleCreateGroupSuccess(GroupEvent event) {
        logger.d("groupmgr#on CREATE_GROUP_OK");
        String groupSessionKey = event.getGroupEntity().getSessionKey();
        IMUIHelper.openChatActivity(getActivity(),groupSessionKey);
        getActivity().finish();
    }

    private void handleCreateGroupFail() {
        logger.d("groupmgr#on CREATE_GROUP_FAIL");
        hideProgressBar();
        Toast.makeText(getActivity(), getString(R.string.create_temp_group_failed), Toast.LENGTH_SHORT).show();
    }

    /**
     * 处理 群成员增加删除成功、失败事件
     * 直接返回群详情管理页面
     * @param event
     */
    private void handleGroupMemChangeSuccess(GroupEvent event) {
        logger.d("groupmgr#on handleGroupMemChangeSuccess");
        getActivity().finish();
    }


    private void handleChangeGroupMemFail() {
        logger.d("groupmgr#on handleChangeGroupMemFail");
        hideProgressBar();
        Toast.makeText(getActivity(), getString(R.string.change_temp_group_failed), Toast.LENGTH_SHORT).show();
    }


    @Override
    protected void initHandler() {
        // TODO Auto-generated method stub
    }

    @Override
    public void onTouchingLetterChanged(String s) {
        // TODO Auto-generated method stub
        int position = adapter.getPositionForSection(s.charAt(0));
        if (position != -1) {
            contactListView.setSelection(position);
        }
    }

}
