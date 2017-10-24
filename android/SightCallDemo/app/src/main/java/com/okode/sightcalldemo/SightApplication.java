package com.okode.sightcalldemo;

import android.app.Application;
import android.util.Log;

import com.sightcall.universal.Universal;
import com.sightcall.universal.agent.model.GuestInvite;
import com.sightcall.universal.agent.model.GuestUsecase;
import com.sightcall.universal.event.UniversalCallReportEvent;
import com.sightcall.universal.event.UniversalStatusEvent;
import com.sightcall.universal.media.MediaSavedEvent;

import net.rtccloud.sdk.Event;

import java.io.File;

/**
 * Created by rpanadero on 24/7/17.
 */

public class SightApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        Universal.register(this);
    }

    @Event
    public void onStatusEvent(UniversalStatusEvent event) {
        switch (event.status()) {
            case INITIALIZING:
                Log.e("DEMO", "Initializing");
                break;
            case CONNECTING:
                Log.e("DEMO", "Connecting");
                break;
            case ACTIVE:
                Log.e("DEMO", "Active");
                break;
            case IDLE:
                Log.e("DEMO", "Idle");
                break;
        }
    }

    @Event
    public void onCallReport(UniversalCallReportEvent e) {
        Log.e("DEMO", "REPORT END");
    }

    @Event
    public void onMediaSavedEvent(MediaSavedEvent event) {
        File image = event.media().image();
        switch (event.metadata().storage()) {
            case CLOUD: /* Will be automatically uploaded */ break;
            case LOCAL: /* Do what you want with it */ break;
        }
    }

}
