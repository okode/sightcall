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
        setContentView(R.layout.activity_main);
        this.txtInv = (EditText) findViewById(R.id.txtInv);
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    public void onRegister(View v) {
        if (Universal.agent().isAvailable()) {
            Toast.makeText(MainActivity.this, "Already registered", Toast.LENGTH_LONG).show();
            return;
        }
        //We get the credentials (token and pin) by invoking a API method with POSTMAN.
        Universal.agent().register("ExJq3KB1oG1QBEXIzXddgC3wusvISViF", "988954", new UniversalAgent.RegisterCallback() {
            @Override
            public void onRegisterSuccess(@NonNull SightCallCredentials sightCallCredentials) {
                Toast.makeText(MainActivity.this, "Registration success", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onRegisterFailure() {
                Toast.makeText(MainActivity.this, "Registration fail", Toast.LENGTH_LONG).show();
            }
        });
    }

    public void fetchUserCases(View v) {
        if (!Universal.agent().isAvailable()) {
            Toast.makeText(MainActivity.this, "Register the user before", Toast.LENGTH_LONG).show();
            return;
        }
        UniversalAgent agent = Universal.agent();
        agent.fetchUsecases(new UniversalAgent.FetchUsecasesCallback() {
            @Override
            public void onFetchUsecasesSuccess() {
                Toast.makeText(MainActivity.this, "Fetch success", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onFetchUsecasesFailure() {
                Toast.makeText(MainActivity.this, "Fetch error", Toast.LENGTH_LONG).show();
            }
        });
    }

    public void invite(View v) {
        if (!Universal.agent().isAvailable()) {
            Toast.makeText(MainActivity.this, "Register the user before", Toast.LENGTH_LONG).show();
            return;
        }
        UniversalAgent agent = Universal.agent();
        GuestUsecase usecase = agent.getGuestUsecase();
        GuestInvite invite = GuestInvite.sms(usecase, txtInv.getText().toString()).build();
        agent.inviteGuest(invite, new UniversalAgent.InviteGuestCallback() {
            @Override
            public void onInviteGuestSuccess() {
                Toast.makeText(MainActivity.this, "Invitation success", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onInviteGuestFailure() {
                Toast.makeText(MainActivity.this, "Invitation error", Toast.LENGTH_LONG).show();
            }
        });
    }

    public void generateURL(View v) {
        if (!Universal.agent().isAvailable()) {
            Toast.makeText(MainActivity.this, "Register the user before", Toast.LENGTH_LONG).show();
            return;
        }
        UniversalAgent agent = Universal.agent();
        GuestUsecase usecase = agent.getGuestUsecase();
        GuestInvite invite = GuestInvite.url(usecase).build();
        agent.inviteGuest(invite, new UniversalAgent.InviteGuestUrlCallback() {
            private String url;
            @Override public void onInviteGuestUrl(String url) {
                this.url = url;
            }
            @Override public void onInviteGuestSuccess() {
                /* Now send the url */
                Toast.makeText(MainActivity.this, "URL generada: " + this.url, Toast.LENGTH_LONG).show();
                MainActivity.this.txtInv.setText(this.url);
            }
            @Override public void onInviteGuestFailure() {
                Toast.makeText(MainActivity.this, "Error generando la URL", Toast.LENGTH_LONG).show();
            }
        });
    }

    public void startURL(View v) {
        String url = this.txtInv.getText() != null ? this.txtInv.getText().toString() : "";
        Universal.start(this.txtInv.getText().toString());
    }
}
