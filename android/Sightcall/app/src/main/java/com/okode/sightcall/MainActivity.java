package com.okode.sightcall;

import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.sightcall.universal.Universal;
import com.sightcall.universal.agent.Code;
import com.sightcall.universal.agent.CreateCode;
import com.sightcall.universal.agent.CreateCodeCallback;
import com.sightcall.universal.agent.FetchUsecasesCallback;
import com.sightcall.universal.agent.RegisterCallback;
import com.sightcall.universal.agent.Registration;
import com.sightcall.universal.agent.UniversalAgent;
import com.sightcall.universal.agent.Usecase;
import com.sightcall.universal.api.Environment;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import static com.okode.sightcall.Constants.*;

public class MainActivity extends AppCompatActivity {

    private EditText txtUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        this.txtUrl = (EditText) findViewById(R.id.txtInv);
        init();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void onRegister(View v) {
        this.registerAgent("2401bc90d90");
    }

    public void fetchUserCases(View v) {
        this.fetchUseCases();
    }

    public void generateURL(View v) { this.generateURL(); }

    public void startURL(View v) {
        String url = this.txtUrl.getText() != null ? this.txtUrl.getText().toString() : "";
        startURL(url);
    }

    private void init() {
        Universal.settings().defaultEnvironment().set(Environment.PPR);
        Universal.settings().loggerVerbosity().set(Log.VERBOSE); // SDK logs will be visible in Logcat
        Universal.settings().apiInterceptor().set(true); // API calls will be visible in Logcat
    }

    private void registerAgent(final String token) {
        getFirebaseToken(new OnSuccessListener<InstanceIdResult>() {
            @Override
            public void onSuccess(final InstanceIdResult result) {
                Registration registration = new Registration.Builder(MainActivity.this.getApplicationContext())
                        .temporaryToken(token)
                        .fcmToken(result.getToken())
                        .build();
                Universal.agent().register(registration, new RegisterCallback() {
                    @Override
                    public void onRegisterSuccess(@androidx.annotation.NonNull Success success) {
                        Toast.makeText(MainActivity.this, "Agent registered", Toast.LENGTH_LONG).show();
                    }

                    @Override
                    public void onRegisterError(@androidx.annotation.NonNull Error error) {
                        Toast.makeText(MainActivity.this, "Agent failed", Toast.LENGTH_LONG).show();
                    }
                });
            }
        });
    }

    private void getFirebaseToken(OnSuccessListener<InstanceIdResult> successListener) {
        FirebaseInstanceId.getInstance().getInstanceId()
                .addOnSuccessListener(successListener)
                .addOnFailureListener(new OnFailureListener() {
                    @Override public void onFailure(Exception e) {
                        Toast.makeText(MainActivity.this, "Error getting firebase token", Toast.LENGTH_LONG).show();
                    }
                });
    }

    private void fetchUseCases(final FetchUseCasesCallback callback) {
        if (!Universal.agent().isAvailable()) {
            Log.e(TAG, "Register the agent before");
            Toast.makeText(MainActivity.this, "Error fetching use cases", Toast.LENGTH_LONG).show();
            return;
        }
        UniversalAgent agent = Universal.agent();
        agent.fetchUsecases(new FetchUsecasesCallback() {
            @Override public void onFetchUsecasesSuccess(FetchUsecasesCallback.Success success) {
                callback.onFetchUsecasesSuccess();
            }
            @Override public void onFetchUsecasesError(Error error) {
                callback.onFetchUsecasesFailure("Error fetching use cases");
            }
        });
    }

    private void fetchUseCases() {
        this.fetchUseCases(new FetchUseCasesCallback() {
            @Override
            public void onFetchUsecasesSuccess() {
                Toast.makeText(MainActivity.this, "Fetched usecases", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onFetchUsecasesFailure(String message) {
                Toast.makeText(MainActivity.this, "Error fetching usecases", Toast.LENGTH_LONG).show();
            }
        });
    }

    private void generateURL() {
        this.fetchUseCases(new FetchUseCasesCallback() {
            @Override
            public void onFetchUsecasesSuccess() {
                UniversalAgent agent = Universal.agent();
                Usecase usecase = agent.usecases().get(0);
                CreateCode code = CreateCode.url(usecase).reference("REFERENCE_ID").build();
                Universal.agent().createCode(code, new CreateCodeCallback() {
                    @Override public void onCreateCodeSuccess(Success success) {
                        Code code = success.code();
                        String url = code.url();
                        Toast.makeText(MainActivity.this, "URL generated: " + url, Toast.LENGTH_LONG).show();
                        MainActivity.this.txtUrl.setText(url);
                    }
                    @Override public void onCreateCodeError(Error error) {
                        Toast.makeText(MainActivity.this, "Error generating url", Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void onFetchUsecasesFailure(String message) {
                Toast.makeText(MainActivity.this, "Error fetching use cases", Toast.LENGTH_LONG).show();
            }
        });

    }

    private void startURL(String url) {
        Universal.start(url);
    }
}
