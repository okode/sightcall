package com.okode.sightcalldemo;

import android.app.Application;
import android.util.Log;

import com.sightcall.universal.Universal;
import com.sightcall.universal.event.CallReportEvent;
import com.sightcall.universal.media.MediaSavedEvent;
import com.sightcall.universal.scenario.Scenario;

import net.rtccloud.sdk.Call;
import net.rtccloud.sdk.event.Event;

import static com.okode.sightcalldemo.Constants.*;

public class SightcallApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        Universal.register(this);
    }

    @Event
    public void onScenarioStatusEvent(Scenario.StatusEvent event) {
        Log.i(TAG, event.status().toString());
    }

    @Event
    public void onCallStatusEvent(Call event) {
        Log.i(TAG, event.status().toString());
    }

    @Event
    public void onCallFinished(CallReportEvent event) {
        Log.i(TAG, event.toString());
    }

    @Event
    public void onMediaSavedEvent(MediaSavedEvent event) {
        Log.i(TAG, event.toString());
    }

}
