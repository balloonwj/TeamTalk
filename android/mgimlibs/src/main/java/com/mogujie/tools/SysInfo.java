package com.mogujie.tools;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Environment;
import android.telephony.TelephonyManager;

import java.net.URLEncoder;


/**
 * 获取系统信息,用于做统计
 * @author 6a209
 * 4:36:50 PM Jun 2, 2012
 */
public class SysInfo{
	
	private String mDeviceId;
	private String mImie;
	
	@SuppressWarnings("deprecation")
	public static final String INFO = 
			URLEncoder.encode(Build.MODEL);
	@SuppressWarnings("deprecation")
	public static String M_SYS = 
			URLEncoder.encode(Build.VERSION.RELEASE);
	
	private static String DEFAULT_STRING = "mgj_2012";
	
	
	@SuppressWarnings("deprecation")
	public String getDeviceId(Context ctx){
		if(null != mDeviceId && mDeviceId.length() > 0){
			return mDeviceId;
		}
		TelephonyManager tm = (TelephonyManager)ctx.getSystemService(Context.TELEPHONY_SERVICE);  
		String deviceId = tm.getDeviceId();
		if(null != deviceId && deviceId.length() > 0) {
			deviceId = URLEncoder.encode(deviceId);
		}else {
			//没取到-取mac地址-
			String mac = getMacAddress(ctx);
			if(null != mac && mac.length() > 0){
				deviceId = "mac" + mac;
			}else{
				//取不到-给个默认值-
				deviceId = DEFAULT_STRING;
			}
		}
		mDeviceId = deviceId;
		return deviceId;
	}
	
	private String getMacAddress(Context ctx){
		WifiManager wifiManager = (WifiManager) ctx.getSystemService(Context.WIFI_SERVICE);
		WifiInfo wifiInfo = wifiManager.getConnectionInfo();
		if(null == wifiInfo || null == wifiInfo.getMacAddress()){
			return "";
		}
		return wifiInfo.getMacAddress().replaceAll(":", "");
	}
	
	@SuppressWarnings("deprecation")
	public String getImie(Context ctx){
		if(null != mImie && mImie.length() > 0){
			return mImie;
		}
		TelephonyManager tm = (TelephonyManager)ctx.getSystemService(Context.TELEPHONY_SERVICE);  
		String scriber = tm.getSubscriberId();
		if(null != scriber){
			scriber = URLEncoder.encode(scriber);
		}else {
			scriber = DEFAULT_STRING;
		}
		return scriber;
	}
	
	public static boolean isWifi(Context ctx){
		ConnectivityManager manager = (ConnectivityManager) ctx
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo networkinfo = manager.getActiveNetworkInfo();
		if(null == networkinfo){
			return true;
		}
		if(ConnectivityManager.TYPE_WIFI == networkinfo.getType()){
			return true;
		}
		return false;
	}

	public static boolean hasSDCard(){
		return Environment.getExternalStorageState().equals(
			android.os.Environment.MEDIA_MOUNTED);
	}
}