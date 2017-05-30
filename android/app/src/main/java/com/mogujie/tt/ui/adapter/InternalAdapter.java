package com.mogujie.tt.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.BaseJsonHttpResponseHandler;
import com.mogujie.tt.DB.sp.SystemConfigSp;
import com.mogujie.tt.R;
import com.mogujie.tt.utils.Logger;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;
import java.util.Comparator;
import java.util.Collections;

/**
 * Created by zhujian on 15/3/12.
 */
public class InternalAdapter extends BaseAdapter {
    private Context ctx = null;
    private List<InternalItem> datalist = new ArrayList<>();
    private Logger logger = Logger.getLogger(ChatAdapter.class);
    private AsyncHttpClient client;

    public InternalAdapter(Context context) {
        ctx = context;
        client = new AsyncHttpClient();
    }

    @Override
    public int getCount() {
        return datalist.size();
    }

    @Override
    public InternalItem getItem(int position) {
        logger.d("recent#getItem position:%d", position);
        if (position >= datalist.size() || position < 0) {
            return null;
        }
        return datalist.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    /**
     * 基本HOLDER
     */
    public static class ViewHoler {
        public TextView title;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        try {
            InternalItem info = datalist.get(position);
            ViewHoler holder;
            if (null == convertView) {
                convertView = LayoutInflater.from(ctx).inflate(R.layout.tt_item_internalitem, parent, false);
                holder = new ViewHoler();
                holder.title = (TextView) convertView.findViewById(R.id.tt_internal_item_title);
                convertView.setTag(holder);
            } else {
                holder = (ViewHoler) convertView.getTag();
            }
            holder.title.setText(info.getItemName());
            return convertView;
        } catch (Exception e) {
            logger.e(e.toString());
            return null;
        }
    }

    public void update() {
        client.setUserAgent("Android-TT");
        SystemConfigSp.instance().init(ctx.getApplicationContext());
        client.get(SystemConfigSp.instance().getStrConfig(SystemConfigSp.SysCfgDimension.DISCOVERYURI), new BaseJsonHttpResponseHandler() {
            @Override
            public void onSuccess(int i, Header[] headers, String s, Object o) {
            }

            @Override
            public void onFailure(int i, Header[] headers, Throwable throwable, String responseString, Object o) {
                try {
                    convertJson2Data();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            protected Object parseResponse(String s, boolean b) throws Throwable {
                /*子类需要提供实现，将请求结果解析成需要的类型 异常怎么处理*/
                SystemConfigSp.instance().setStrConfig(SystemConfigSp.SysCfgDimension.DISCOVERYDATA, s);
                convertJson2Data();
                return null;
            }
        });
    }

    private void convertJson2Data() throws JSONException {
        String strData = SystemConfigSp.instance().getStrConfig(SystemConfigSp.SysCfgDimension.DISCOVERYDATA);
        if (!TextUtils.isEmpty(strData)) {
            JSONArray jsonArray = new JSONArray(strData);
            int len = jsonArray.length();
            datalist.clear();
            for (int i = 0; i < len; i++) {
                JSONObject item = (JSONObject) jsonArray.get(i);
                InternalItem info = new InternalItem();
                info.setItemName(item.getString("itemName"));
                info.setItemUrl(item.getString("itemUrl"));
                info.setItemPriority(item.getInt("itemPriority"));
                datalist.add(info);
            }
            Collections.sort(datalist, new SortByPriority());
        } else {
            datalist.clear();
        }
        notifyDataSetChanged();
    }

    public class InternalItem {

        private int id;
        private String itemName;
        private String itemUrl;
        private int itemPriority;
        private int status;
        private int created;
        private int updated;

        public void setId(int id) {
            this.id = id;
        }

        public int getId() {
            return this.id;
        }

        public String getItemName() {
            return itemName;
        }

        public void setItemName(String name) {
            this.itemName = name;
        }

        public String getItemUrl() {
            return this.itemUrl;
        }

        public void setItemUrl(String url) {
            this.itemUrl = url;
        }

        public int getItemPriority() {
            return this.itemPriority;
        }

        public void setItemPriority(int priority) {
            this.itemPriority = priority;
        }

        public int getStatus() {
            return this.status;
        }

        public void setStatus(int status) {
            this.status = status;
        }

        public int getCreated() {
            return this.created;
        }

        public void setCreated(int created) {
            this.created = created;
        }

        public int getUpdated() {
            return this.updated;
        }

        public void setUpdated(int updated) {
            this.updated = updated;
        }

    }

    class SortByPriority implements Comparator {
        public int compare(Object o1, Object o2) {
            InternalItem s1 = (InternalItem) o1;
            InternalItem s2 = (InternalItem) o2;
            if (s1.getItemPriority() > s2.getItemPriority())
                return 1;
            return 0;
        }
    }

}
