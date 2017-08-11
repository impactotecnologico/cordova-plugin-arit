package net.it.arit.plugin;

import com.craftar.CraftARContentImage;

/**
 * Created by rafael on 19/07/17.
 */
public class Scenes {

    private String URL;

    private CraftARContentImage ARContent;

    private String classID;

    private Scenes(CraftARContentImage ARContent, String URL) {
        this.setARContent(ARContent);
        this.setURL(URL);
        this.setClassID(ARContent.toString());
    }

    public static Scenes createScene(CraftARContentImage ARContent, String URL) {
        return new Scenes(ARContent,URL);
    }

    public String getURL() {
        return URL;
    }

    public void setURL(String URL) {
        this.URL = URL;
    }

    public CraftARContentImage getARContent() {
        return ARContent;
    }

    public void setARContent(CraftARContentImage ARContent) {
        this.ARContent = ARContent;
    }

    public String getClassID() {
        return classID;
    }

    public void setClassID(String classID) {
        this.classID = classID;
    }
}
