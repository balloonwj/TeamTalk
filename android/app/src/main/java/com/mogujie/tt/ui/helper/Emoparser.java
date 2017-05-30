
package com.mogujie.tt.ui.helper;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.ImageSpan;

import com.mogujie.tt.R;
import com.mogujie.tt.utils.CommonUtil;
import com.mogujie.tt.utils.Logger;

import java.io.IOException;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @Description 表情解析
 * @author Nana
 * @date 2014-4-16
 */
@SuppressLint("UseSparseArrays")
public class Emoparser {
    private static Logger logger = Logger.getLogger(Emoparser.class);

    private Context context;
    private String[] emoList;
    private String[] yayaEmoList;
    private Pattern mPattern;
    private Pattern mYayaPattern;
    private static HashMap<String, Integer> phraseIdMap;
    private static HashMap<Integer, String> idPhraseMap;
    private static HashMap<String, Integer> yayaPhraseIdMap;
    private static HashMap<Integer, String> yayaIdPhraseMap;
    private static Emoparser instance = null;

    public static boolean isGifEmo = false;
    private final int DEFAULT_SMILEY_TEXTS = R.array.default_emo_phrase;
    private final int YAYA_EMO_TEXTS = R.array.yaya_emo_phrase;
    private final int[] DEFAULT_EMO_RES_IDS = {
            R.drawable.tt_e0, R.drawable.tt_e1,
            R.drawable.tt_e2, R.drawable.tt_e3, R.drawable.tt_e4, R.drawable.tt_e5,
            R.drawable.tt_e6, R.drawable.tt_e7, R.drawable.tt_e8, R.drawable.tt_e9,
            R.drawable.tt_e10, R.drawable.tt_e11, R.drawable.tt_e12, R.drawable.tt_e13,
            R.drawable.tt_e14, R.drawable.tt_e15, R.drawable.tt_e16, R.drawable.tt_e17,
            R.drawable.tt_e18, R.drawable.tt_e19, R.drawable.tt_e20, R.drawable.tt_e21,
            R.drawable.tt_e22, R.drawable.tt_e23, R.drawable.tt_e24, R.drawable.tt_e25,
            R.drawable.tt_e26, R.drawable.tt_e27, R.drawable.tt_e28, R.drawable.tt_e29,
            R.drawable.tt_e30, R.drawable.tt_e31, R.drawable.tt_e32, R.drawable.tt_e33,
            R.drawable.tt_e34, R.drawable.tt_e35, R.drawable.tt_e36, R.drawable.tt_e37,
            R.drawable.tt_e38, R.drawable.tt_e39, R.drawable.tt_e40, R.drawable.tt_e41,
            R.drawable.tt_e42, R.drawable.tt_e43, R.drawable.tt_e44, R.drawable.tt_e45
    };

    private final int[] YAYA_EMO_RES_IDS = {
            R.drawable.tt_yaya_e1, R.drawable.tt_yaya_e2, R.drawable.tt_yaya_e3, R.drawable.tt_yaya_e4,
            R.drawable.tt_yaya_e5, R.drawable.tt_yaya_e6, R.drawable.tt_yaya_e7, R.drawable.tt_yaya_e8,
            R.drawable.tt_yaya_e9, R.drawable.tt_yaya_e10, R.drawable.tt_yaya_e11, R.drawable.tt_yaya_e12,
            R.drawable.tt_yaya_e13, R.drawable.tt_yaya_e14, R.drawable.tt_yaya_e15, R.drawable.tt_yaya_e16,
            R.drawable.tt_yaya_e17, R.drawable.tt_yaya_e18, R.drawable.tt_yaya_e19
    };

    public int[] getResIdList() {
        return DEFAULT_EMO_RES_IDS;
    }

    public int[] getYayaResIdList() {
        return YAYA_EMO_RES_IDS;
    }

    public static synchronized Emoparser getInstance(Context cxt) {
        if (null == instance && null != cxt) {
            instance = new Emoparser(cxt);
        }
        return instance;
    }

    private Emoparser(Context cxt) {
        context = cxt;
        emoList = context.getResources().getStringArray(DEFAULT_SMILEY_TEXTS);
        yayaEmoList = context.getResources().getStringArray(YAYA_EMO_TEXTS);
        buildMap();
        buildYayaEmoMap();
        mPattern = buildPattern();
        mYayaPattern = buildYayaEmoPattern();
    }

    private void buildMap() {
        if (DEFAULT_EMO_RES_IDS.length != emoList.length) {
            throw new IllegalStateException("Smiley resource ID/text mismatch");
        }
        phraseIdMap = new HashMap<String, Integer>(emoList.length);
        idPhraseMap = new HashMap<Integer, String>(emoList.length);
        for (int i = 0; i < emoList.length; i++) {
            phraseIdMap.put(emoList[i], DEFAULT_EMO_RES_IDS[i]);
            idPhraseMap.put(DEFAULT_EMO_RES_IDS[i], emoList[i]);
        }
    }

    private void buildYayaEmoMap(){
        if (YAYA_EMO_RES_IDS.length != yayaEmoList.length) {
            throw new IllegalStateException("Yaya emo resource ID/text mismatch");
        }
        yayaPhraseIdMap = new HashMap<>(yayaEmoList.length);
        yayaIdPhraseMap = new HashMap<>(yayaEmoList.length);
        for (int i = 0; i < yayaEmoList.length; i++) {
            yayaPhraseIdMap.put(yayaEmoList[i], YAYA_EMO_RES_IDS[i]);
            yayaIdPhraseMap.put(YAYA_EMO_RES_IDS[i], yayaEmoList[i]);
        }
    }

    public HashMap<String, Integer> getPhraseIdMap() {
        return phraseIdMap;
    }

    public HashMap<Integer, String> getIdPhraseMap() {
        return idPhraseMap;
    }

    public HashMap<String, Integer> getYayaPhraseIdMap() {
        return yayaPhraseIdMap;
    }

    public HashMap<Integer, String> getYayaIdPhraseMap() {
        return yayaIdPhraseMap;
    }

    private Pattern buildPattern() {
        StringBuilder patternString = new StringBuilder(emoList.length * 3);
        patternString.append('(');
        for (String s : emoList) {
            patternString.append(Pattern.quote(s));
            patternString.append('|');
        }
        patternString.replace(patternString.length() - 1,
                patternString.length(), ")");

        return Pattern.compile(patternString.toString());
    }

    private Pattern buildYayaEmoPattern() {
        StringBuilder patternString = new StringBuilder(yayaEmoList.length * 3);
        patternString.append('(');
        for (String s : yayaEmoList) {
            patternString.append(Pattern.quote(s));
            patternString.append('|');
        }
        patternString.replace(patternString.length() - 1,
                patternString.length(), ")");

        return Pattern.compile(patternString.toString());
    }

    public CharSequence emoCharsequence(CharSequence text) {
        SpannableStringBuilder builder = new SpannableStringBuilder(text);
        Matcher matcher = mPattern.matcher(text);
        while (matcher.find()) {
            int resId = phraseIdMap.get(matcher.group());
            Drawable drawable = context.getResources().getDrawable(resId);
            int size = (int) (CommonUtil.getElementSzie(context) * 0.8);
            drawable.setBounds(0, 0, size, size);
            ImageSpan imageSpan = new ImageSpan(drawable,
                    ImageSpan.ALIGN_BOTTOM);
            builder.setSpan(imageSpan, matcher.start(), matcher.end(),
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }

        matcher = mYayaPattern.matcher(text);
        while (matcher.find()) {
            isGifEmo = true;
            int resId = yayaPhraseIdMap.get(matcher.group());
            Drawable drawable = context.getResources().getDrawable(resId);
            drawable.setBounds(0, 0, 105, 115);
            ImageSpan imageSpan = new ImageSpan(drawable,
                    ImageSpan.ALIGN_BOTTOM);
            builder.setSpan(imageSpan, matcher.start(), matcher.end(),
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        return builder;
    }

    public int getResIdByCharSequence(CharSequence text) {

        Matcher matcher = mYayaPattern.matcher(text);
        while (matcher.find()) {
            int resId = yayaPhraseIdMap.get(matcher.group());
            return resId;
        }
        return 0;
    }

    public boolean isMessageGif(CharSequence text){

        Matcher matcher = mYayaPattern.matcher(text);
        while (matcher.find()) {
            return true;
        }
        return false;
    }

}
