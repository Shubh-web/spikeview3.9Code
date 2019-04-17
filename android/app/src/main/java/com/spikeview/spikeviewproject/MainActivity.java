package com.spikeview.spikeviewproject;


import android.annotation.TargetApi;
import android.app.ProgressDialog;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.AsyncTask;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.SyncStateContract;
import android.util.Log;
import android.widget.Toast;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.UUID;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.io/battery";
    public Result result;
    String path = "";
    boolean serverResponse;
    // ProgressDialog pd;
    String sasToken, imagePath, uploadPath;
    ProgressDialog pd;
    boolean isshow = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);


        GeneratedPluginRegistrant.registerWith(this);

        pd = new ProgressDialog(this);
        pd.setMessage("Uploading...!");

        //pd.show();
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {


                    public Result result;

                    @TargetApi(Build.VERSION_CODES.CUPCAKE)
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        this.result = result;
                        if (call.method.equals("getBatteryLevel")) {
                            sasToken = call.argument("sasToken");
                            imagePath = call.argument("imagePath");
                            uploadPath = call.argument("uploadPath");
                            Log.e("uploadPath", uploadPath);
                            try {

                                new SendfeedbackJob2().execute().get();
                            } catch (Exception e) {

                            }
                            if (serverResponse) {
                                pd.cancel();
                                result.success(path);
                            } else {
                                pd.cancel();
                                result.success("false");
                            }


                        } else if (call.method.equals("encryption")) {
                            String pass = call.argument("password");
                            String encrypt = crossAes(pass, result);
                            result.success(encrypt);
                        } else {
                            result.notImplemented();
                        }
                    }
                });
    }

    private String crossAes(String pass, Result result) {
        try {
            CryptLib _crypt = new CryptLib();
            String output = "";
            String plainText = pass;
            String key = CryptLib.SHA256("sd5b75nb7577#^%$%*&G#CGF*&%@#%*&", 32); //32 bytes = 256 bit
            String iv = "F@$%^*GD$*(*#!12";
            String encrypt = _crypt.encrypt(plainText, key, iv); //encrypt
            Log.e("encrypted text=", "-------------------" + encrypt);

            return encrypt;
           /* output = _crypt.decrypt(encrypt, key,iv); //decrypt

            Log.e("decrypted text=","-------------------" + output);*/
        } catch (Exception e) {
            // TODO Auto-generated catch block
            result.success("");
            e.printStackTrace();
        }
        return "";
    }

    @TargetApi(Build.VERSION_CODES.CUPCAKE)
    private class SendfeedbackJob2 extends AsyncTask<String, Void, String> {
        @Override
        protected void onPreExecute() {
            pd.show();
            super.onPreExecute();
        }

        @Override
        protected String doInBackground(String[] params) {
            // do above Server call here

            try {
                Log.e("uploadPath2", uploadPath);
                Log.e("imagePath2", imagePath);
                // Get the file data
                File file = new File(imagePath);
                if (!file.exists()) {

                }
                String extantion = file.getAbsolutePath().substring(file.getAbsolutePath().lastIndexOf("."));
                String type = "image_";
                String uniqueID = type + UUID.randomUUID().toString().replace("-", "") + extantion;

                String sasUrl2 = uploadPath + uniqueID + "?";
                Log.e("sasurl", "path:-" + sasUrl2);
                String sasUrl = sasUrl2 + sasToken;
                String absoluteFilePath = file.getAbsolutePath();
                path = uniqueID;
                FileInputStream fis = new FileInputStream(absoluteFilePath);
                int bytesRead = 0;
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                byte[] b = new byte[1024];
                while ((bytesRead = fis.read(b)) != -1) {
                    bos.write(b, 0, bytesRead);
                }
                fis.close();
                byte[] bytes = bos.toByteArray();
                // Post our image data (byte array) to the server
                URL url = new URL(sasUrl.replace("\"", ""));
                HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                urlConnection.setDoOutput(true);
                urlConnection.setConnectTimeout(1000 * 60 * 2);
                urlConnection.setReadTimeout(1000 * 60 * 2);
                urlConnection.setRequestMethod("PUT");
                urlConnection.addRequestProperty("Content-Type", "image");
                urlConnection.setRequestProperty("Content-Length", "" + bytes.length);
                urlConnection.setRequestProperty("x-ms-blob-type", "BlockBlob");
                // Write file data to server
                DataOutputStream wr = new DataOutputStream(urlConnection.getOutputStream());
                wr.write(bytes);
                wr.flush();
                wr.close();
                int response = urlConnection.getResponseCode();
                //    pd.cancel();
                if (response == 201 && urlConnection.getResponseMessage().equals("Created")) {
                    Log.e("created", "created shubh");
                    serverResponse = true;
                    pd.cancel();
                    pd.dismiss();
                    return "fvf";

                }
            } catch (Exception e) {
                pd.cancel();
                pd.dismiss();
                serverResponse = false;
                e.printStackTrace();
            }
            return "some message";
        }

        @Override
        protected void onPostExecute(String message) {
            pd.cancel();
            pd.dismiss();
            //process message
        }
    }


}

/*

import android.annotation.TargetApi;
import android.app.ProgressDialog;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.AsyncTask;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.SyncStateContract;
import android.util.Log;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.UUID;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.io/battery";
    public Result result;
    String path = "";
    boolean serverResponse;
    // ProgressDialog pd;
    String sasToken, imagePath, uploadPath;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        //   pd = new ProgressDialog(this);
        //  pd.setMessage("Uploading...!");
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {


                    public Result result;

                    @TargetApi(Build.VERSION_CODES.CUPCAKE)
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        this.result = result;
                        if (call.method.equals("getBatteryLevel")) {

                            sasToken = call.argument("sasToken");
                            imagePath = call.argument("imagePath");
                            uploadPath = call.argument("uploadPath");
                            Log.e("uploadPath", uploadPath);
                            try {
                                //    pd.show();
                                new SendfeedbackJob2().execute().get();
                            } catch (Exception e) {

                            }
                            if (serverResponse) {
                                result.success(path);
                            } else {
                                result.success("false");
                            }


                        } else {
                            result.notImplemented();
                        }
                    }
                });
    }


    @TargetApi(Build.VERSION_CODES.CUPCAKE)
    private class SendfeedbackJob2 extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String[] params) {
            // do above Server call here

            try {
                Log.e("uploadPath2", uploadPath);
                Log.e("imagePath2", imagePath);
                // Get the file data
                File file = new File(imagePath);
                if (!file.exists()) {

                }
                String extantion = file.getAbsolutePath().substring(file.getAbsolutePath().lastIndexOf("."));
                String type = "image_";
                String uniqueID = type + UUID.randomUUID().toString().replace("-", "") + extantion;

                String sasUrl2 = uploadPath + uniqueID + "?";
                Log.e("sasurl", "path:-" + sasUrl2);
                String sasUrl = sasUrl2 + sasToken;
                String absoluteFilePath = file.getAbsolutePath();
                path = uniqueID;
                FileInputStream fis = new FileInputStream(absoluteFilePath);
                int bytesRead = 0;
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                byte[] b = new byte[1024];
                while ((bytesRead = fis.read(b)) != -1) {
                    bos.write(b, 0, bytesRead);
                }
                fis.close();
                byte[] bytes = bos.toByteArray();
                // Post our image data (byte array) to the server
                URL url = new URL(sasUrl.replace("\"", ""));
                HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                urlConnection.setDoOutput(true);
                urlConnection.setConnectTimeout(15000);
                urlConnection.setReadTimeout(15000);
                urlConnection.setRequestMethod("PUT");
                urlConnection.addRequestProperty("Content-Type", "image");
                urlConnection.setRequestProperty("Content-Length", "" + bytes.length);
                urlConnection.setRequestProperty("x-ms-blob-type", "BlockBlob");
                // Write file data to server
                DataOutputStream wr = new DataOutputStream(urlConnection.getOutputStream());
                wr.write(bytes);
                wr.flush();
                wr.close();
                int response = urlConnection.getResponseCode();
                //    pd.cancel();
                if (response == 201 && urlConnection.getResponseMessage().equals("Created")) {
                    Log.e("created", "created shubh");
                    serverResponse = true;
                    return "fvf";

                }
            } catch (Exception e) {

                serverResponse = false;
                e.printStackTrace();
            }
            return "some message";
        }

        @Override
        protected void onPostExecute(String message) {
            //process message
        }
    }


}*/
