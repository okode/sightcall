package com.okode.sightcalldemo;

import android.app.Application;
import android.support.annotation.NonNull;
import android.util.Log;

import com.sightcall.universal.Universal;
import com.sightcall.universal.event.CallReportEvent;
import com.sightcall.universal.media.MediaSavedEvent;
import com.sightcall.universal.scenario.Scenario;
import com.sightcall.universal.scenario.Step;

import net.rtccloud.sdk.event.Event;
import net.rtccloud.sdk.event.call.StatusEvent;

import static com.okode.sightcalldemo.Constants.TAG;

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
    public void onCallStatusEvent(StatusEvent event) {
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

    @Event
    public void onStepStateEvent(@NonNull Step.StateEvent event) {
        Log.i(TAG, event.toString());
    }

}
