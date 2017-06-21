package com.okode.sightcalldemo;

import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.sightcall.universal.Universal;
import com.sightcall.universal.agent.UniversalAgent;
import com.sightcall.universal.agent.event.UniversalAgentRegistrationEvent;
import com.sightcall.universal.agent.model.GuestInvite;
import com.sightcall.universal.agent.model.GuestUsecase;
import com.sightcall.universal.event.UniversalStatusEvent;

import com.sightcall.universal.event.UniversalCallReportEvent;
import com.sightcall.universal.internal.api.model.SightCallCredentials;
import com.sightcall.universal.util.Environment;

import net.rtccloud.sdk.Event;

public class MainActivity extends AppCompatActivity {

    private EditText txtInv;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Universal.settings().rtccLogger().set(true); // or Logger.verbose();
        Universal.settings().universalLogger().set(true); // or Trace.verbose();
        Universal.agent().setDefaultEnvironment(Environment.PPR);
        setContentView(R.layout.activity_main);
        this.txtInv = (EditText) findViewById(R.id.txtInv);
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
     * Then declare {@link @net.rtccloud.sdk.Event} methods to receive the corresponding events.
     */
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
    public void onUniversalAgentRegistrationEvent(UniversalAgentRegistrationEvent event) {
        if (event.isSuccess()) {
            Toast.makeText(this, "Registration success event", Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(this, "Registration failed event", Toast.LENGTH_LONG).show();
        }
    }

    @Event
    public void onCallReport(UniversalCallReportEvent e) {
        Log.e("DEMO", "REPORT END");
    }

    public void onRegister(View v) {
        Universal.agent().register("eUPPfSCR6Kg6dTqI6rQ6qOOIURPN1u12", "171408", new UniversalAgent.RegisterCallback() {
            @Override
            public void onRegisterSuccess(@NonNull SightCallCredentials sightCallCredentials) {
                Toast.makeText(MainActivity.this, "Registration success", Toast.LENGTH_LONG).show();
            }

            @Override public void onRegisterFailure() {
                Toast.makeText(MainActivity.this, "Registration fail", Toast.LENGTH_LONG).show();
            }
        });
    }

    public void invite(View v) {
        UniversalAgent agent = Universal.agent();
        GuestUsecase usecase = agent.getGuestUsecase();
        GuestInvite invite = GuestInvite.sms(usecase, txtInv.getText().toString()).build();
        agent.inviteGuest(invite, new UniversalAgent.InviteGuestCallback() {
            @Override public void onInviteGuestSuccess() {
                Toast.makeText(MainActivity.this, "Invitation success", Toast.LENGTH_LONG).show();
            }
            @Override public void onInviteGuestFailure() {
                Toast.makeText(MainActivity.this, "Invitation error", Toast.LENGTH_LONG).show();
            }
        });
    }

}
