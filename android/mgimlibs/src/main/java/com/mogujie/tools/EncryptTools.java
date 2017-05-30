package com.mogujie.tools;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 加密工具类,
 * 
 * @author 6a209
 * 11:04:05 AM Jul 10, 2012
 */
public class EncryptTools {
	
	private static EncryptTools sEncrypt;
	
	private EncryptTools(){
		
	}
	
	public static EncryptTools instance(){
		if(null == sEncrypt){
			sEncrypt = new EncryptTools(); 
		}
		return sEncrypt;
	}

	/**
	 * md5加密-
	 * @param str
	 * @return
	 */
	 public String toMD5(String str) {  
	        MessageDigest messageDigest = null;  
	  
	        try {  
	            messageDigest = MessageDigest.getInstance("MD5");  
	            messageDigest.reset();  
	            messageDigest.update(str.getBytes("UTF-8"));  
	        } catch (NoSuchAlgorithmException e) {  
	            System.out.println("NoSuchAlgorithmException caught!");  
	            System.exit(-1);  
	        } catch (UnsupportedEncodingException e) {  
	            e.printStackTrace();  
	        }  
	        byte[] byteArray = messageDigest.digest();  
	        StringBuffer md5StrBuff = new StringBuffer();  
	        for (int i = 0; i < byteArray.length; i++) {              
	            if (Integer.toHexString(0xFF & byteArray[i]).length() == 1)  
	                md5StrBuff.append("0").append(Integer.toHexString(0xFF & byteArray[i]));  
	            else  
	                md5StrBuff.append(Integer.toHexString(0xFF & byteArray[i]));  
	        }  
	        return md5StrBuff.toString();  
	    }  
	
}