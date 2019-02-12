package com.okode.sightcalldemo;

/**
 * Created by rpanadero on 29/6/17.
 */

public interface FetchUseCasesCallback {

    void onFetchUsecasesFailure(String message);
    void onFetchUsecasesSuccess();
    
}
