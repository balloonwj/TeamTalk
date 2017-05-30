package com.mogujie.tools;


public class TimeTools{

	public static final int ONE_MINUTE = 1000 * 60;
	public static final int ONE_HOUR =  60 * ONE_MINUTE;
	public static final int ONE_DAY = 24 * ONE_HOUR;

	
	public static  int getIntervalHour(long time){
		return (int) (time / ONE_HOUR);
	}
	
	public static int getIntervalMinute(long time){
		return (int) (time % ONE_HOUR / ONE_MINUTE);
	}
	
	public static int getIntervalSecond(long time){
		return (int)(time % ONE_HOUR % ONE_MINUTE / 1000);
	}
	
	public static long getCurrentTime(long serverTimeDiff){
		return (int)(System.currentTimeMillis() - serverTimeDiff);
	}
}