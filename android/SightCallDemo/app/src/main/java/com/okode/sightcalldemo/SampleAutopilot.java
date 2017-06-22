package com.okode.sightcalldemo;

import android.content.Context;
import android.content.SharedPreferences;

import com.urbanairship.Autopilot;
import com.urbanairship.UAirship;

/**
 * Created by rpanadero on 22/6/17.
 */

public class SampleAutopilot extends Autopilot {
    private static final String NO_BACKUP_PREFERENCES = "com.urbanairship.sample.no_backup";

    private static final String FIRST_RUN_KEY = "first_run";

    @Override
    public void onAirshipReady(UAirship airship) {
        SharedPreferences preferences = UAirship.getApplicationContext().getSharedPreferences(NO_BACKUP_PREFERENCES, Context.MODE_PRIVATE);

        boolean isFirstRun = preferences.getBoolean(FIRST_RUN_KEY, true);
        if (isFirstRun) {
            preferences.edit().putBoolean(FIRST_RUN_KEY, false).apply();

            // Enable user notifications on first run
            airship.getPushManager().setUserNotificationsEnabled(true);
        }
    }

}
