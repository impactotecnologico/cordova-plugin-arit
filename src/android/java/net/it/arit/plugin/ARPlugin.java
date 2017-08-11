package net.it.arit.plugin;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Environment;
import android.util.Log;
import android.widget.Button;

import com.tecnoboda.josejulianyloiry.MainActivity;
import com.tecnoboda.josejulianyloiry.R;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;
import java.util.concurrent.ExecutionException;

public class ARPlugin extends CordovaPlugin {

  private static final int REQUEST_CAMERA_PERMISSION = 200;
  public static final String CONFIG_JSON = "config.json";
  public static final String TECHNOIMPACT = "http://technoimpact.net/";
  private final String TAG = "MainActivity";
  public static String baseUrl = TECHNOIMPACT;
  public static JSONObject JSON_REMOTE;
  private JSONArray imagesAR;
  private Button buttonMenuAR;
  private Button buttonVideoAR;
  private int btnMenu;
  private int btnVideo;
  private JSONArray videosAR;
  private JSONArray minis;
  private Activity activity;
  private Context context;
  private String action;

  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
     }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.context = cordova.getActivity().getApplicationContext();
        this.activity = cordova.getActivity();
        this.action = action;

        try {
            JSONObject json = new GetRemoteAssets().execute(TECHNOIMPACT + CONFIG_JSON).get();

            try {
                AugmentedActivity.delayVisualScan = json.getInt("delay");
                AugmentedActivity.CLOUD_COLLECTION_TOKEN = json.getString("arCollection");
                AugmentedActivity.arDirectory = json.getString("arMobileDirectory");
                baseUrl = json.getString("urlBase");
                imagesAR = json.getJSONArray("imagesAR");
                videosAR = json.getJSONArray("videosAR");
                minis = json.getJSONArray("minis");
                int items = imagesAR.length();
                for (int i= 0; i <items; i++){
                    imagesAR.put(items+i,"info"+(i+1)+".png"); // para incluir tantas imagenes info como imagenes base existan
                }
                items = imagesAR.length();

                ArrayList<String> simpleListImages = new ArrayList<String>();
                for (int i=0;i<items;i++){
                    simpleListImages.add(imagesAR.get(i).toString());
                }

                items = videosAR.length();

                ArrayList<String> simpleListVideos = new ArrayList<String>();
                for (int i=0;i<items;i++){
                    simpleListVideos.add(videosAR.get(i).toString());
                }

                items = minis.length();

                ArrayList<String> simpleListMinis = new ArrayList<String>();
                for (int i=0;i<items;i++){
                    simpleListMinis.add(minis.get(i).toString());
                }


                new SendHttpRequestTask(this.activity).execute(simpleListImages, simpleListVideos, simpleListMinis);

            } catch (JSONException e) {
                AugmentedActivity.delayVisualScan = 1000;
                e.printStackTrace();
            }


        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }

        return true;
    }

    private void openNewActivity(Context context, String action) {
        Intent intent = new Intent(context, AugmentedActivity.class);

        if(action.equals("bienvenida")) {
            intent.putExtra(AugmentedActivity.ACCION,Acciones.BIENVENIDA);
        }
        if(action.equals("menu")){
            intent.putExtra(AugmentedActivity.ACCION,Acciones.MENU);
        }
        System.out.println("Entra en vista");
        this.cordova.getActivity().startActivity(intent);
    }

  private class GetRemoteAssets extends AsyncTask<String, Integer, JSONObject> {
    @Override
    protected JSONObject doInBackground(String... params) {
      try {
        URL url = new URL(params[0]);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setDoOutput(true);
        connection.setInstanceFollowRedirects(false);
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("charset", "utf-8");
        connection.connect();
        InputStream inStream = connection.getInputStream();
        String json = streamToString(inStream);
        return new JSONObject(json);
      } catch (MalformedURLException e) {
        e.printStackTrace();
      } catch (JSONException e) {
        e.printStackTrace();
      } catch (IOException e) {
        e.printStackTrace();
      }
      return null;

    }

    @Override
    protected void onPostExecute(JSONObject result) {
      ARPlugin.JSON_REMOTE = result;
      System.out.println(JSON_REMOTE);
    }

    private String streamToString(InputStream inputStream) {
      String text = new Scanner(inputStream, "UTF-8").useDelimiter("\\Z").next();
      return text;
    }
  }

  private class SendHttpRequestTask extends AsyncTask<ArrayList<String>, Integer, Map<String,InputStream>> {

    private ProgressDialog dialog;
    private Activity activity;
    private String mobileImagePath;
    private static final int BUFFER_SIZE = 4096;

    public SendHttpRequestTask(Activity activity){
      this.activity = activity;
      this.dialog = new ProgressDialog(activity);
      this.mobileImagePath = Environment.getExternalStorageDirectory() + "/" + AugmentedActivity.arDirectory + "/";
    }

    @Override
    protected void onPreExecute() {
      this.dialog.setMessage("Preparando Realidad Aumentada....");
      this.dialog.show();
    }

    @Override
    protected void onProgressUpdate(Integer... values) {
      super.onProgressUpdate(values);
      this.dialog.setMessage("Preparando Realidad Aumentada..." + values[0]);
    }

    @Override
    protected Map<String,InputStream> doInBackground(ArrayList<String>... remoteResources) {
      try {

        if (remoteResources.length != 3){
            Log.e(TAG,"Error en listado de recursos para descarga",new Exception("Error en remoteResources. Size: " + remoteResources.length));
        }

        ArrayList<String> imagesArray = remoteResources[0];
        ArrayList<String> videosArray = remoteResources[1];
        ArrayList<String> minisArray = remoteResources[2];

        int contador = (imagesArray.size() + videosArray.size() + minisArray.size()) * 2;

        contador = downloadAndCreate(imagesArray, contador);
        contador = downloadAndCreate(videosArray, contador);
        downloadAndCreate(minisArray, contador);

        Log.d(TAG,"PLATOS:" +AugmentedActivity.platosURL.toString().replace('[', '{').replace(']', '}'));

        //return itemsMap;
    }catch (Exception e){
        Log.e(TAG,e.getMessage(),e);
    }
    return null;
  }

  private int downloadAndCreate(ArrayList<String> filesArray, int contador) throws IOException {

    for (String singleName : filesArray) {

        publishProgress(contador);
        File file = new File(new File(mobileImagePath), singleName);

        if (file.exists()){
            if (singleName.contains("mini")){
                AugmentedActivity.miniaturas.add(singleName);
            } else if (singleName.contains("mp4")){
                AugmentedActivity.videos.add(singleName);
            } else if (singleName.contains("info")){
                Log.d(TAG,"Archivo info"); // solo se indica que se tiene. Por ahora se usan directamente según nombre en AugmentedActivity
            } else {
                AugmentedActivity.platosURL.add(singleName);
            }
            publishProgress(contador-=1);
            continue;
        }

        URL url = new URL(baseUrl + singleName);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setDoInput(true);
        connection.connect();
        InputStream inputStream = connection.getInputStream();

        Log.d(TAG,"Archivo Obtenido: " + singleName);

        publishProgress(contador-=1);

        try {
            FileOutputStream out = new FileOutputStream(file);

            int bytesRead = -1;
            byte[] buffer = new byte[BUFFER_SIZE];
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }

            inputStream.close();
            out.flush();
            out.close();

            Log.d(TAG,"Archivo creado: " + file.exists() + " - " + file.getAbsolutePath());

            if (!singleName.contains("mp4") && !singleName.contains("mini") && !singleName.contains("info")){
                AugmentedActivity.platosURL.add(singleName);
            }

            if (singleName.contains("mini")){
                AugmentedActivity.miniaturas.add(singleName);
            } else if (singleName.contains("mp4")){
                AugmentedActivity.videos.add(singleName);
            } else if (singleName.contains("info")){
                AugmentedActivity.platosURL.add(singleName);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        contador-=1;
    }
    return contador;
  }


    @Override
    protected void onPostExecute(Map<String,InputStream> images) {

      if (dialog.isShowing()) {
        dialog.dismiss();
      }

      ARPlugin.this.openNewActivity(ARPlugin.this.context,ARPlugin.this.action);
    }
  }
}
