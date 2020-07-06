package com.lieweitek.numpakbis;


import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.provider.Settings;
import android.util.Log;
import io.socket.client.IO;
import io.socket.client.Socket;
import okhttp3.OkHttpClient;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;


import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SetOptions;

import org.json.JSONException;
import org.json.JSONObject;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URISyntaxException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import static android.content.ContentValues.TAG;


public class MyService extends Service {

    private String sender,senderKey,type,nameBus,ruteKey,ruteName,halteKey,halteName,halteLat,halteLong,latitude,longitude;
    private LocationListener listener;
    private LocationManager locationManager;
    private Handler handler;
    private Runnable runnable;
    private Socket mSocket;
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private List<RuteHalteBus> ruteHalteBusList = new ArrayList<RuteHalteBus>();
    private Integer lastIndex = 0;
    private Date startTime, stopTime;



    @SuppressLint("MissingPermission")
    @Override
    public void onCreate() {
        super.onCreate();
        locationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);

        Location locationGPS = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
        if (locationGPS != null) {
            double lat = locationGPS.getLatitude();
            double longi = locationGPS.getLongitude();
            latitude = String.valueOf(lat);
            longitude = String.valueOf(longi);
        }


        try {
            String socketUrl = "https://numpakbis-server.herokuapp.com/";
            HostnameVerifier hostnameVerifier = new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;
                }
            };
            TrustManager[] trustAllCerts = new TrustManager[]{new X509TrustManager() {
                @Override
                public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) {

                }

                @Override
                public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) {

                }

                @Override
                public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                    return new java.security.cert.X509Certificate[0];
                }
            }};
            X509TrustManager trustManager = (X509TrustManager) trustAllCerts[0];

            SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, null);
            SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            OkHttpClient okHttpClient = new OkHttpClient.Builder()
                    .hostnameVerifier(hostnameVerifier)
                    .sslSocketFactory(sslSocketFactory, trustManager)
                    .build();

            IO.Options opts = new IO.Options();
            opts.callFactory = okHttpClient;
            opts.webSocketFactory = okHttpClient;
            mSocket = IO.socket(socketUrl, opts);
        } catch (URISyntaxException e) {
            throw new RuntimeException(e);
        } catch (NoSuchAlgorithmException | KeyManagementException e) {
            e.printStackTrace();
        }




        mSocket.connect();
        handler = new Handler();
        listener = new LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                latitude = String.valueOf(location.getLatitude());
                longitude = String.valueOf(location.getLongitude());
            }

            @Override
            public void onStatusChanged(String provider, int status, Bundle extras) {

            }

            @Override
            public void onProviderEnabled(String provider) {

            }

            @Override
            public void onProviderDisabled(String provider) {
                Intent i  = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(i);
            }
        };


        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,3000,0,listener);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "messages")
                    .setContentText("Service running in Background...")
                    .setContentTitle("NumpakBis Operator")
                    .setOngoing(true)
                    .setSmallIcon(R.drawable.ic_airport_shuttle_black_24dp);
            PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                    new Intent(this, MainActivity.class), PendingIntent.FLAG_UPDATE_CURRENT);

            builder.setContentIntent(contentIntent);

            startForeground(101, builder.build());

        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (locationManager != null){
            locationManager.removeUpdates(listener);
        }
        if (handler != null){
            handler.removeCallbacks(runnable);
        }
        if (mSocket.connected()){
            //do something
            JSONObject obj = new JSONObject();
            try {
                obj.put("nameBus", nameBus);
                obj.put("ruteKey", ruteKey);
                obj.put("ruteName", ruteName);
                obj.put("halteKey", halteKey);
                obj.put("halteName", halteName);
                obj.put("halteLat", halteLat);
                obj.put("halteLong", halteLong);
                obj.put("latitude", latitude);
                obj.put("longitude", longitude);
                obj.put("status","inactive");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            if (mSocket.connected()){
                mSocket.emit("send_message", obj, sender);
            }

            // add report data to cloud firestore
            stopTime = Calendar.getInstance().getTime();
            long totalTime = stopTime.getTime() - startTime.getTime();
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            String formattedDate = df.format(startTime);
            Map<String, Object> reportData = new HashMap<>();
            reportData.put("name", sender);
            reportData.put("uid", senderKey);
            reportData.put("startTime", startTime);
            reportData.put("stopTime", stopTime);
            reportData.put("totalTime", totalTime);
            reportData.put("bus", nameBus);
            reportData.put("rute", ruteName);
            reportData.put("type", type);
            db.collection("report").document(formattedDate).collection("operator").document()
                    .set(reportData)
                    .addOnSuccessListener(new OnSuccessListener<Void>() {
                        @Override
                        public void onSuccess(Void aVoid) {
                            Log.d(TAG, "DocumentSnapshot successfully written!");
                        }
                    })
                    .addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception e) {
                            Log.w(TAG, "Error writing document", e);
                        }
                    });

            mSocket.disconnect();
        }

    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Bundle extras = intent.getExtras();
        if(extras == null)
            Log.d("Service","null");
        else
        {
            Log.d("Service","not null");
            nameBus = (String)extras.get("nameBus");
            ruteKey = (String)extras.get("ruteKey");
            ruteName = (String)extras.get("ruteName");
            halteKey = (String)extras.get("halteKey");
            halteName = (String)extras.get("halteName");
            halteLat = (String)extras.get("halteLat");
            halteLong = (String)extras.get("halteLong");
            sender = (String)extras.get("sender");
            senderKey = (String)extras.get("senderKey");
            type = (String)extras.get("type");


            db.collection("rute_bus").document(ruteKey).collection("halte_bus").orderBy("key")
                    .get()
                    .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<QuerySnapshot> task) {
                            if (task.isSuccessful()) {
                                for (QueryDocumentSnapshot document : task.getResult()) {
                                    RuteHalteBus temp = new RuteHalteBus(document.getString("name"),
                                            document.getId(), document.getString("latitude"), document.getString("longitude"));
                                    ruteHalteBusList.add(temp);
                                    lastIndex++;
                                    //Log.d("HALTE BUS", document.getId() + " => " + document.getData());
                                }
                            } else {
                                Log.w("HALTE BUS", "Error getting documents.", task.getException());
                            }
                            for (RuteHalteBus element : ruteHalteBusList) {
                               // Log.d("HALTE LIST",element.toString());
                            }
                            //Log.d("LAST INDEX", String.valueOf(lastIndex));
                        }
                    });

            int R = 6371; // km
            int delay = 10000; //milliseconds
            startTime = Calendar.getInstance().getTime();

            handler.postDelayed(runnable = new Runnable(){
                public void run(){
                    if(latitude == null){
                        latitude = (String)extras.get("latitude");
                    }
                    if(longitude == null){
                        longitude = (String)extras.get("longitude");
                    }



                    double distance = round(
                            CalculationByDistance(Double.valueOf(latitude),Double.valueOf(longitude),Double.valueOf(halteLat),Double.valueOf(halteLong)),
                            1
                    );

                    if (distance <= 0.1){
                        if (Integer.parseInt(halteKey) == lastIndex){
                            RuteHalteBus halte = ruteHalteBusList.get(0);
                            halteName = halte.getName();
                            halteLat = halte.getLatitude();
                            halteLong = halte.getLongitude();
                            halteKey = halte.getKey();
                        }else{
                            RuteHalteBus halte = ruteHalteBusList.get(Integer.parseInt(halteKey));
                            halteName = halte.getName();
                            halteLat = halte.getLatitude();
                            halteLong = halte.getLongitude();
                            halteKey = halte.getKey();
                        }

                    }
                    //do something
                    JSONObject obj = new JSONObject();
                    try {
                        obj.put("nameBus", nameBus);
                        obj.put("ruteKey", ruteKey);
                        obj.put("ruteName", ruteName);
                        obj.put("halteKey", halteKey);
                        obj.put("halteName", halteName);
                        obj.put("halteLat", halteLat);
                        obj.put("halteLong", halteLong);
                        obj.put("latitude", latitude);
                        obj.put("longitude", longitude);
                        obj.put("status","active");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    if (mSocket.connected()){
                        mSocket.emit("send_message", obj, sender);
                        Log.d("SendingMessage", String.valueOf(obj));
                        Log.d("Distance", String.valueOf(distance));
                    }
                    handler.postDelayed(this, delay);
                }
            }, delay);
        }
        return super.onStartCommand(intent, flags, startId);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public double CalculationByDistance(double initialLat, double initialLong,
                                        double finalLat, double finalLong){
        int R = 6371; // km (Earth radius)
        double dLat = toRadians(finalLat-initialLat);
        double dLon = toRadians(finalLong-initialLong);
        initialLat = toRadians(initialLat);
        finalLat = toRadians(finalLat);

        double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(initialLat) * Math.cos(finalLat);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c;
    }

    public double toRadians(double deg) {
        return deg * (Math.PI/180);
    }

    public static double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();

        BigDecimal bd = BigDecimal.valueOf(value);
        bd = bd.setScale(places, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }




}
