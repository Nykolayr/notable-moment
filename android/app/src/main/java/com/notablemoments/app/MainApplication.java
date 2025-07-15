package com.notablemoments.app;

import android.app.Application;
import com.yandex.mapkit.MapKitFactory;

public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        MapKitFactory.setLocale("ru_RU");
        MapKitFactory.setApiKey("8be32f5b-3719-4f7e-b9a1-755305320727");
    }
} 