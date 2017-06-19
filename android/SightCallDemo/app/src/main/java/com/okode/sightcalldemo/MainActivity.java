package com.okode.sightcalldemo;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import com.sightcall.universal.Universal;
import com.sightcall.universal.event.UniversalStatusEvent;

import net.rtccloud.sdk.Event;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Universal.settings().rtccLogger().set(true); // or Logger.verbose();
        Universal.settings().universalLogger().set(true); // or Trace.verbose();
        setContentView(R.layout.activity_main);
    }

    @Override
    protected void onStart() {
        super.onStart();
        Universal.register(this);
    }

    @Override
    protected void onStop() {
        Universal.unregister(this);
        super.onStop();
    }

    /**
     * Then declare `@net.rtccloud.sdk.Event` methods to receive the corresponding events.
     */
    @Event
    public void onStatusEvent(UniversalStatusEvent event) {
        switch (event.status()) {
            case INITIALIZING:  break;
            case CONNECTING:    break;
            case ACTIVE:        break;
            case IDLE:          break;
        }
    }
}
