package com.mogujie.tt.imservice.entity;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mogujie.tt.config.DBConstant;
import com.mogujie.tt.DB.entity.MessageEntity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * @author : yingmu on 15-1-14.
 * @email : yingmu@mogujie.com.
 */
public class MixMessage extends MessageEntity {

    public List<MessageEntity> msgList ;


    /**
     * 从net端解析需要
     * @param entityList
     */
    public MixMessage(List<MessageEntity> entityList){
        if(entityList ==null || entityList.size()<=1){
            throw new RuntimeException("MixMessage# type is error!");
        }

        MessageEntity justOne = entityList.get(0);
        id =  justOne.getId();
        msgId   = justOne.getMsgId();
        fromId  = justOne.getFromId();
        toId    = justOne.getToId();
        sessionKey = justOne.getSessionKey();
        msgType = justOne.getMsgType();
        status  = justOne.getStatus();
        created = justOne.getCreated();
        updated = justOne.getUpdated();
        msgList = entityList;
        displayType= DBConstant.SHOW_MIX_TEXT;

        /**分配主键Id
         * 图文混排的之间全部从-1开始
         * 在messageAdapter中 结合msgId进行更新
         *
         * dbinterface 结合id sessionKey msgid来替换具体的消息
         * {insertOrUpdateMix}
         * */
         long index = -1;
         for(MessageEntity msg:entityList){
             msg.setId(index);
             index --;
         }
    }

    /**
     * Not-null value.
     */
    @Override
    public String getContent() {
        return getSerializableContent(msgList);
    }

    /**
     *sessionKey是在外边设定的，所以子对象是没有的
     * 所以在设定的时候，都需要加上
     * */
    @Override
    public void setSessionKey(String sessionKey) {
        super.setSessionKey(sessionKey);
        for(MessageEntity msg:msgList){
            msg.setSessionKey(sessionKey);
        }
    }

    @Override
    public void setToId(int toId) {
        super.setToId(toId);
        for(MessageEntity msg:msgList){
            msg.setToId(toId);
        }
    }

    public MixMessage(MessageEntity dbEntity){
        id =  dbEntity.getId();
        msgId   = dbEntity.getMsgId();
        fromId  = dbEntity.getFromId();
        toId    = dbEntity.getToId();
        msgType = dbEntity.getMsgType();
        status  = dbEntity.getStatus();
        created = dbEntity.getCreated();
        updated = dbEntity.getUpdated();
        content = dbEntity.getContent();
        displayType = dbEntity.getDisplayType();
        sessionKey = dbEntity.getSessionKey();

    }

    private String getSerializableContent(List<MessageEntity> entityList){
        Gson gson = new Gson();
        String json = gson.toJson(entityList);
        return json;
    }

    public static MixMessage parseFromDB(MessageEntity entity) throws JSONException {
        if(entity.getDisplayType() != DBConstant.SHOW_MIX_TEXT){
            throw new RuntimeException("#MixMessage# parseFromDB,not SHOW_MIX_TEXT");
        }
        Gson gson = new GsonBuilder().create();
        MixMessage mixMessage = new MixMessage(entity);
        List<MessageEntity> msgList = new ArrayList<>();
        JSONArray jsonArray = new JSONArray(entity.getContent());

        for (int i = 0, length = jsonArray.length(); i < length; i++) {
            JSONObject jsonOb = (JSONObject) jsonArray.opt(i);
            int displayType = jsonOb.getInt("displayType");
            String jsonMessage = jsonOb.toString();
            switch (displayType){
                case DBConstant.SHOW_ORIGIN_TEXT_TYPE:{
                    TextMessage textMessage = gson.fromJson(jsonMessage,TextMessage.class);
                    textMessage.setSessionKey(entity.getSessionKey());
                    msgList.add(textMessage);
                }break;

                case DBConstant.SHOW_IMAGE_TYPE:
                    ImageMessage imageMessage = gson.fromJson(jsonMessage,ImageMessage.class);
                    imageMessage.setSessionKey(entity.getSessionKey());
                    msgList.add(imageMessage);
                    break;
            }
        }
        mixMessage.setMsgList(msgList);
        return mixMessage;
    }


    public List<MessageEntity> getMsgList() {
        return msgList;
    }

    public void setMsgList(List<MessageEntity> msgList) {
        this.msgList = msgList;
    }
}
