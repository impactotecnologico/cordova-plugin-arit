package net.it.arit.plugin;

import java.io.File;
import java.util.ArrayList;

import android.app.Activity;
import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.craftar.CloudSearchController;
import com.craftar.CraftARActivity;
import com.craftar.CraftARCloudRecognition;
import com.craftar.CraftARContent;
import com.craftar.CraftARContentImage;
import com.craftar.CraftARContentVideo;
import com.craftar.CraftARError;
import com.craftar.CraftARItem;
import com.craftar.CraftARItemAR;
import com.craftar.CraftARResult;
import com.craftar.CraftARSDK;
import com.craftar.CraftARSearchResponseHandler;
import com.craftar.CraftARTouchEventInterface;
import com.craftar.CraftARTracking;
import com.craftar.SetCloudCollectionListener;

import org.json.JSONArray;

public class AugmentedActivity extends CraftARActivity implements CraftARSearchResponseHandler, SetCloudCollectionListener {

  public static String CLOUD_COLLECTION_TOKEN = "augmentedreality";
    public static final String MINUTA = "minuta";
    public static final String BIENVENIDA = "bienvenida";
    public static final String ACCION = "ACCION";
    private final String TAG = "AugmentedActivity";

  public Acciones accionActual;

  private View mScanningLayout;
  private CraftARItemAR myARItem;
  public static ArrayList<String> platosURL = new ArrayList<String>();

  private ArrayList<Scenes> platosScenes = new ArrayList<Scenes>();

  public static ArrayList<String> miniaturas = new ArrayList<String>();

  public static ArrayList<String> videos = new ArrayList<String>();

  private Scenes changeButton;

  private Scenes prevButtonScene;

  public float[] scale = {1.5f,2.2f,1.5f};

  private CraftARSDK mCraftARSDK;

  private CraftARTracking mTracking;

  private CraftARCloudRecognition mCloudIR;

  private CraftARContentVideo mCraftARContentVideo;

  private CloudSearchController mcloudSearchController;

  public boolean isCardShow = false;

  public boolean firstTimeChange = true;

  private Scenes currentCard;

  private int contador = 0;

  private boolean isVideoPlaying = false;

  public static int delayVisualScan = 1000;

  public static String arDirectory = "ARITDirectory";

  public static boolean isCollectionReady = false;

  private int layoutAumented;
  private int layoutScanning;
  private int layoutWelcome;
  private int layoutScanningW;
  private int stringWelcome;
  private int stringMenu;
  private int layoutInfo;
  private int colorRosa;
  private int textHelp;
  private int textHelpMessage;
  private int menuCreditos;
  private int imgViewMenu;
  private int imgViewBienvenida;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

      this.layoutAumented = getResources().getIdentifier("activity_augmented_menu", "layout", getPackageName());
      this.layoutWelcome = getResources().getIdentifier("activity_augmented_welcome", "layout", getPackageName());
      this.layoutScanning = getResources().getIdentifier("layout_scanning", "id", getPackageName());
      this.layoutScanningW = getResources().getIdentifier("layout_scanning_w", "id", getPackageName());
      this.stringWelcome = getResources().getIdentifier("title_welcome", "string", getPackageName());
      this.stringMenu = getResources().getIdentifier("title_menu", "string", getPackageName());
      this.layoutInfo = getResources().getIdentifier("layout_info", "id", getPackageName());
      this.colorRosa = getResources().getIdentifier("rosa_boda", "color", getPackageName());
      this.textHelp = getResources().getIdentifier("textHelp", "id", getPackageName());
      this.textHelpMessage = getResources().getIdentifier("help_menu_step2", "string", getPackageName());
      this.menuCreditos = getResources().getIdentifier("menu_creditos", "id", getPackageName());
      this.imgViewMenu =(getResources().getIdentifier("imageViewMenu","id",getPackageName()));
      this.imgViewBienvenida = getResources().getIdentifier("imageViewBienvenida","id",getPackageName());

    }

    @Override
    public void onPostCreate() {

        Bundle bundle = getIntent().getExtras();

      accionActual = (Acciones) bundle.get(ACCION);

      switch (accionActual.accion()){
        case 1:
          Log.d(TAG, "Boton de Menu");
          View menuLayout = getLayoutInflater().inflate(this.layoutAumented, null);
          setContentView(menuLayout);
          isVideoPlaying = false;
          mScanningLayout = findViewById(this.layoutScanning);
          setTitle(getString(this.stringMenu));
          ImageView imageViewMenu = (ImageView) menuLayout.findViewById(this.imgViewMenu);
          imageViewMenu.setImageURI(Uri.parse(Environment.getExternalStorageDirectory() + "/" + AugmentedActivity.arDirectory + "/" + this.miniaturas.get(0)));
          break;
        case 2:
          Log.d(TAG,"Boton de Bienvenida");
          View welcomeLayout = getLayoutInflater().inflate(this.layoutWelcome, null);
          setContentView(welcomeLayout);
          isVideoPlaying = true;
          mScanningLayout = findViewById(this.layoutScanningW);
          setTitle(getString(this.stringWelcome));
          ImageView imageViewBien = (ImageView) welcomeLayout.findViewById(this.imgViewBienvenida);
          imageViewBien.setImageURI(Uri.parse(Environment.getExternalStorageDirectory() + "/" + AugmentedActivity.arDirectory + "/" + this.miniaturas.get(1)));
          break;
        }


      mCraftARSDK =  CraftARSDK.Instance();

      mCraftARSDK.init(getApplicationContext());

      mCraftARSDK.startCapture(this);

      mCloudIR = CraftARCloudRecognition.Instance();

      mCloudIR.setCraftARSearchResponseHandler(this);

      mCraftARSDK.setSearchController(mCloudIR.getSearchController());

      mCloudIR.setCollection(CLOUD_COLLECTION_TOKEN, this);

      mcloudSearchController = (CloudSearchController) mCloudIR.getSearchController();
      mcloudSearchController.setSearchPeriod(this.delayVisualScan);

      mTracking = CraftARTracking.Instance();

    }

    public void addItemFromURL(String URL) {
        

        String imageURL = Environment.getExternalStorageDirectory() + "/" + AugmentedActivity.arDirectory + "/" + URL;

        System.out.println("Agregando imagen " + imageURL);

        //String imageURL = getApplicationContext().getExternalFilesDir(null) + "/"+URL;

        if(!this.getAllScenesURL().contains(URL))
        {
            Scenes addedScene = Scenes.createScene(new CraftARContentImage(imageURL), imageURL);
            this.platosScenes.add(addedScene);
        }

        this.platosScenes.get(this.contador).getARContent().setScale(this.scale);
        this.platosScenes.get(this.contador).getARContent().setWrapMode(CraftARContent.ContentWrapMode.WRAP_MODE_ASPECT_FIT);
        this.myARItem.addContent(this.platosScenes.get(this.contador).getARContent());

    }

    @Override
    public void onPreviewStarted(int width, int height) {
        Log.d(TAG,"***** startCapture() was completed successfully");

        mCraftARSDK.setOnContentTouchListener(new CraftARTouchEventInterface.OnTouchEventListener() {
            @Override
            public void onTouchIn(CraftARContent craftARContent) {
                System.out.println("touch in");
                System.out.println(craftARContent.getUUID());
            }

            @Override
            public void onTouchOut(CraftARContent craftARContent) {
                System.out.println("touch out");
                System.out.println(craftARContent.getUUID());

            }

            @Override
            public void onTouchDown(CraftARContent craftARContent) {
                System.out.println("touch down");
                System.out.println(craftARContent.toString());

                if (isVideoPlaying){
                  AugmentedActivity.this.myARItem.removeContent(mCraftARContentVideo);
                  return;
                }

                
                System.out.println(AugmentedActivity.this.changeButton.getClassID());
                System.out.println(AugmentedActivity.this.prevButtonScene.getClassID());
                if (craftARContent.toString().equals(AugmentedActivity.this.changeButton.getClassID())) {

                    CraftARContentImage contentToRemove = AugmentedActivity.this.platosScenes.get(AugmentedActivity.this.contador).getARContent();

                    AugmentedActivity.this.myARItem.removeContent(contentToRemove);

                    if (AugmentedActivity.this.contador == 3) {
                        AugmentedActivity.this.contador = 0;
                    } else {
                        AugmentedActivity.this.contador++;
                    }

                    if(AugmentedActivity.this.firstTimeChange)
                    {
                      AugmentedActivity.this.myARItem.addContent(prevButtonScene.getARContent());
                      AugmentedActivity.this.firstTimeChange = false;
                    }
                    AugmentedActivity.this.addItemFromURL(AugmentedActivity.this.platosURL.get(AugmentedActivity.this.contador));

                } else if(craftARContent.toString().equals(AugmentedActivity.this.prevButtonScene.getClassID())) {
                    System.out.println("Plato previo");
                    CraftARContentImage contentToRemove = AugmentedActivity.this.platosScenes.get(AugmentedActivity.this.contador).getARContent();

                    AugmentedActivity.this.myARItem.removeContent(contentToRemove);

                    if (AugmentedActivity.this.contador == 0) {
                        AugmentedActivity.this.contador = 3;
                    } else {
                        AugmentedActivity.this.contador--;
                    }

                    AugmentedActivity.this.addItemFromURL(AugmentedActivity.this.platosURL.get(AugmentedActivity.this.contador));


                }else{
                    System.out.println(AugmentedActivity.this.getAllScenesID());

                    if (AugmentedActivity.this.isCardShow) {
                        System.out.println("ocultando card");
                        AugmentedActivity.this.myARItem.removeContent(AugmentedActivity.this.currentCard.getARContent());
                        AugmentedActivity.this.isCardShow = false;
                    }else
                    {
                        if (AugmentedActivity.this.getAllScenesID().contains(craftARContent.toString())) {
                            System.out.println("mostrando card");
                            AugmentedActivity.this.showCard(AugmentedActivity.this.getAllScenesID().indexOf(craftARContent.toString()));
                        }
                    }
                }
            }

            @Override
            public void onTouchUp(CraftARContent craftARContent) {
                System.out.println("touch up");
            }
        });
    }

    public void showCard(int index)
    {
        try {
            findViewById(getResources().getIdentifier("layout_info","id",getPackageName())).setVisibility(View.INVISIBLE);
            Integer trueIndex = index + 1;
            System.out.println(trueIndex);
            String imageURL = Environment.getExternalStorageDirectory() + "/" + AugmentedActivity.arDirectory + "/info"+trueIndex.toString()+ ".png";
//            String imageURL = getApplicationContext().getExternalFilesDir(null) + "/info"+trueIndex.toString()+".png";
            System.out.println(imageURL.toString());
            this.currentCard = Scenes.createScene(new CraftARContentImage(imageURL),imageURL);
            this.currentCard.getARContent().setWrapMode(CraftARContent.ContentWrapMode.WRAP_MODE_ASPECT_FIT);
            this.currentCard.getARContent().setTranslation(new float[]{0f, 0f, 142.63f});
            this.currentCard.getARContent().setScale(new float[]{1.6f, 1.6f, 1.6f});
            this.myARItem.addContent(this.currentCard.getARContent());
            this.isCardShow = true;
        }catch (Exception e){
            System.out.println(e);
        }
    }

    public void addPrevButton()
    {
        String imageURL = getApplicationContext().getExternalFilesDir(null) + "/prev.png";
        this.prevButtonScene = Scenes.createScene(new CraftARContentImage(imageURL),imageURL);
        float[] translationPrev = new float[]{-240f,-261.33f,82.68f};
        float[] scaleButton = new float[]{0.6f,0.6f,0.6f};
        this.prevButtonScene.getARContent().setWrapMode(CraftARContent.ContentWrapMode.WRAP_MODE_ASPECT_FIT);
        this.prevButtonScene.getARContent().setTranslation(translationPrev);
        this.prevButtonScene.getARContent().setScale(scaleButton);
    }

    public void removePrevButton()
    {
        this.myARItem.removeContent(this.prevButtonScene.getARContent());
    }

    private ArrayList<String> getAllScenesID()
    {
        ArrayList<String> returnArray = new ArrayList<>(this.platosScenes.size());

        for (Scenes scene : this.platosScenes)
            returnArray.add(scene.getClassID());

        return returnArray;

    }

    private ArrayList<String> getAllScenesURL()
    {
        ArrayList<String> returnArray = new ArrayList<>(this.platosScenes.size());

        for (Scenes scene : this.platosScenes)
            returnArray.add(scene.getURL());

        return returnArray;

    }

    @Override
    public void collectionReady() {
        /**
         * Start searching in finder mode. The searchResults() method of the
         * CraftARSearchResponseHandler previously set to the SDK will be triggered when some results
         * are found.
         */
        mCraftARSDK.startFinder();
    }

    @Override
    public void setCollectionFailed(CraftARError craftARError) {
        /**
         * This method is called when the setCollection method failed. This happens usually
         * when the token is wrong or there is no internet connection.
         */
        Log.d(TAG, "search failed! " + craftARError.getErrorMessage());
    }

    @Override
    public void searchResults(ArrayList<CraftARResult> results, long l, int i) {

          if(results.size() != 0){
              /**
               * Each result contains information about the match:
               *  - score
               *  - matched image
               *  - match bounding box
               *  - item
               */
              CraftARResult result = results.get(0);


              /**
               * Get the item for this result and check if it is an AR item
               */
              CraftARItem item = result.getItem();
              System.out.println(item.getItemName());
              if (item.isAR() && item.getItemName().equals(MINUTA)) {
                  menuAugmented((CraftARItemAR) item);
              } else if (item.isAR() && item.getItemName().equals(BIENVENIDA)) {
                  welcomeAugmented((CraftARItemAR) item);
              }

          }
    }

    private void welcomeAugmented(CraftARItemAR item) {
    mCraftARSDK.stopFinder();

    // Cast the found item to an AR item
    this.myARItem = item;

    String videoURL = Environment.getExternalStorageDirectory() + "/" + AugmentedActivity.arDirectory + "/" + videos.get(0);

    mCraftARContentVideo = new CraftARContentVideo(videoURL, true, false, false, true);
    mCraftARContentVideo.setWrapMode(CraftARContent.ContentWrapMode.WRAP_MODE_ASPECT_FIT);
    mCraftARContentVideo.setScale(this.scale);

    this.myARItem.addContent(mCraftARContentVideo);

    CraftARError error = mTracking.addItem(this.myARItem);
    if (error == null) {
      mTracking.startTracking();
      mScanningLayout.setVisibility(View.GONE);
    } else {
      Log.e(TAG, error.getErrorMessage());
    }
  }

    private void menuAugmented(CraftARItemAR item) {
        // Stop Finding
        mCraftARSDK.stopFinder();

        // Cast the found item to an AR item
        this.myARItem = item;

        String imageURL = Environment.getExternalStorageDirectory() + "/" + AugmentedActivity.arDirectory + "/" + this.platosURL.get(0);

        System.out.println("Agregando primer plato " + imageURL);        

        this.platosScenes.add(Scenes.createScene(new CraftARContentImage(imageURL), imageURL));

        this.platosScenes.get(0).getARContent().setWrapMode(CraftARContent.ContentWrapMode.WRAP_MODE_ASPECT_FIT);
        this.platosScenes.get(0).getARContent().setScale(this.scale);

        System.out.println("Agregando botón ");

        String buttonURL = getApplicationContext().getExternalFilesDir(null) + "/next.png";

        this.changeButton = Scenes.createScene(new CraftARContentImage(buttonURL),buttonURL);

        float[] translationButton = new float[]{240f,-261.33f,82.68f};

        float[] scaleButton = new float[]{0.6f,0.6f,0.6f};

        this.changeButton.getARContent().setWrapMode(CraftARContent.ContentWrapMode.WRAP_MODE_ASPECT_FIT);

        this.changeButton.getARContent().setTranslation(translationButton);

        this.changeButton.getARContent().setScale(scaleButton);

        // Añadiendo los elementos al contexto AR
        this.myARItem.addContent(this.changeButton.getARContent());
        this.myARItem.addContent(this.platosScenes.get(0).getARContent());
        this.addPrevButton();


        CraftARError error = mTracking.addItem(this.myARItem);
        if (error == null) {
            mTracking.startTracking();
            mScanningLayout.setVisibility(View.GONE);
        } else {
            Log.e(TAG, error.getErrorMessage());
        }
    }


    @Override
    public void searchFailed(CraftARError craftARError, int i) {
        /**
         * Called when a search fails. This happens usually when pointing the
         * device to a textureless surface or when there is connectivity issues.
         */
        Log.d(TAG, "Search failed :"+craftARError.getErrorMessage());
    }

    @Override
    public void finish() {
        /**
         * Stop Searching, Tracking and clean the AR scene
         */
        mCraftARSDK.stopFinder();
        super.finish();
    }

    @Override
    public void onCameraOpenFailed() {
        Toast.makeText(getApplicationContext(), "Camera error", Toast.LENGTH_SHORT).show();
    }

    public void hideHelp(View v){
        v.setVisibility(View.INVISIBLE);
    }

    @Override
    public void onPause() {
    super.onPause();
        mCraftARSDK.stopFinder();
        mTracking.stopTracking();
        mTracking.removeAllItems();
        super.finish();
    }

    @Override
    public void onResume()
    {
    super.onResume();
        this.onPostCreate();
    }
}
