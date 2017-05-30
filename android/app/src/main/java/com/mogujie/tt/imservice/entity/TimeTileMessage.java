package com.mogujie.tt.imservice.entity;

/**
 * @author : yingmu on 15-1-8.
 * @email : yingmu@mogujie.com.
 */
public class TimeTileMessage {
    private int time;
    public TimeTileMessage(int mTime){
        time= mTime;
    }

    public int getTime() {
        return time;
    }

    public void setTime(int time) {
        this.time = time;
    }
}
