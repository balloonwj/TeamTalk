
package com.mogujie.tt.ui.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.mogujie.tt.R;
import com.mogujie.tt.config.IntentConstant;

public class PreviewTextActivity extends Activity {
    TextView txtContent = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tt_activity_preview_text);

        txtContent = (TextView) findViewById(R.id.content);

        String displayText = getIntent().getStringExtra(IntentConstant.PREVIEW_TEXT_CONTENT);
        txtContent.setText(displayText);

        ((View) txtContent.getParent()).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PreviewTextActivity.this.finish();
            }
        });
    }

}
