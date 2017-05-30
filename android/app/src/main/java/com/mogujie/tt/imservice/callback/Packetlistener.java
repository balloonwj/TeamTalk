package com.mogujie.tt.imservice.callback;

/**
 * @author : yingmu on 15-1-7.
 * @email : yingmu@mogujie.com.
 */
public abstract class Packetlistener implements IMListener {
    private long createTime;
    private long timeOut;
    public Packetlistener(long timeOut){
        this.timeOut = timeOut;
        long now = System.currentTimeMillis();
        createTime = now;
    }

    public Packetlistener(){
        this.timeOut = 8*1000;
        long now = System.currentTimeMillis();
        createTime = now;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public long getTimeOut() {
        return timeOut;
    }

    public void setTimeOut(long timeOut) {
        this.timeOut = timeOut;
    }

    public abstract void onSuccess(Object response);

    public abstract void onFaild();

    public abstract void onTimeout();
}
