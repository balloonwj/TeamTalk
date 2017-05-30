package com.mogujie.tt.ui.widget;

import android.content.Context;
import android.text.Editable;
import android.util.AttributeSet;
import android.widget.EditText;

import com.mogujie.tt.ui.helper.Emoparser;

/**
 * Created by nana on 14-9-18.
 */
public class CustomEditView extends EditText {
    private static final int ID_PASTE = android.R.id.paste;

    public CustomEditView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public boolean onTextContextMenuItem(int id) {
        if(id == ID_PASTE){
            try {
                int currentapiVersion = android.os.Build.VERSION.SDK_INT;
                if (currentapiVersion >= android.os.Build.VERSION_CODES.HONEYCOMB) {
                    android.content.ClipboardManager clipboard =
                            (android.content.ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                    String value = clipboard.getText().toString();
                    Editable edit = getEditableText();
                    edit.clear();
                    edit.append(Emoparser.getInstance(getContext()).emoCharsequence(value));
                } else {
                    android.text.ClipboardManager clipboard =
                            (android.text.ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                    String value = clipboard.getText().toString();
                    Editable edit = getEditableText();
                    edit.clear();
                    edit.append(Emoparser.getInstance(getContext()).emoCharsequence(value));
                }
                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return super.onTextContextMenuItem(id);
    }
}