package com.lieweitek.numpakbis;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private Intent forService;
    private boolean onGPS;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!runtime_permisssions())
            enable_method();
    }



    private boolean runtime_permisssions() {
        if (Build.VERSION.SDK_INT >= 23 && ContextCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED){
            requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION}, 100);
            return true;
        }else{
            return false;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 100){
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED){
                enable_method();
            }else {
                runtime_permisssions();
            }
        }
    }

    private void enable_method() {
        forService = new Intent(MainActivity.this, MyService.class);
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),"com.lieweitek.numpakbis/services")
                .setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        if(call.method.equals("startService")){
                            String sender = call.argument("sender");
                            String senderKey = call.argument("senderKey");
                            String nameBus = call.argument("nameBus");
                            String ruteKey = call.argument("ruteKey");
                            String ruteName = call.argument("ruteName");
                            String halteKey = call.argument("halteKey");
                            String halteName = call.argument("halteName");
                            String halteLat = call.argument("halteLat");
                            String halteLong = call.argument("halteLong");
                            String latitude =  call.argument("lat");
                            String longitude =  call.argument("long");
                            String type =  call.argument("type");

                            forService.putExtra("sender",sender);
                            forService.putExtra("senderKey",senderKey);
                            forService.putExtra("nameBus",nameBus);
                            forService.putExtra("ruteKey",ruteKey);
                            forService.putExtra("ruteName",ruteName);
                            forService.putExtra("halteKey",halteKey);
                            forService.putExtra("halteName",halteName);
                            forService.putExtra("halteLat",halteLat);
                            forService.putExtra("halteLong",halteLong);
                            forService.putExtra("latitude",latitude);
                            forService.putExtra("longitude",longitude);
                            forService.putExtra("type",type);
                            startService();
                            result.success("Service Started");
                        }
                        if(call.method.equals("stopService")){
                            stopService(forService);
                            result.success("Service Stopped");
                        }
                    }
                });
    }

    private void startService(){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService);
        }else {
            startService(forService);
        }
    }
}

