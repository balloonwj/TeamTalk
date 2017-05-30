package com.mogujie.tools;

import android.text.Html;
import android.text.Spanned;

/**
 * 字符串处理类
 * @author 6a209
 * Feb 16, 2013
 */
public class StringTools{
	
	public static boolean isEmpty(String str){
		if(str != null && str.length() > 0){
			return false;
		}
		return true;
	}

	public static String makeHtmlStr(String text, String color){
		return "<font color=\"" + color + "\">" + text + "</font>";
	}
	
	public static String makeHtmlStr(String text, int color){
		String strColor = String.valueOf(color);
		return makeHtmlStr(text, strColor);
	}
	
    public static String getUnNullString(String content) {
        if (null == content) {
            return "";
        }
        return content;
    }
    
    public static Spanned getColorfulString(String color, String content, String rightContent,
        String leftContent) {
      return Html.fromHtml(rightContent + "<font color=\"" + color + "\">" + content + "</font>"
          + leftContent);
    }
}