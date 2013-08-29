#pragma once

#include "ofMain.h"
#include "ofxTouchGUIBase.h"
#include "ofxTouchGUISlider.h"
#include "ofxTouchGUIText.h"
#include "ofxTouchGUIButton.h"
#include "ofxTouchGUIToggleButton.h"
#include "ofxTouchGUIDropDown.h"
#include "ofxTouchGUITextInput.h"
#include "ofxTouchGUITimeGraph.h"
#include "ofxXmlSettings.h"
#include "ofxOsc.h"


// ofxTouchGUI versioning
#define OFXTOUCHGUI_VERSION 0.2

// gui item types
#define SLIDER_TYPE "slider"
#define BUTTON_TYPE "button"
#define TOGGLE_TYPE "toggle"
#define TEXT_TYPE "text"
#define DROPDOWN_TYPE "dropdown"
#define TEXTINPUT_TYPE "input"
#define TIMEGRAPH_TYPE "timegraph"
#define CONST_TYPE "constant"
#define VAR_TYPE "variable"

// gui item value types
enum { _INT, _FLOAT, _BOOL, _STRING };

// for adding variables
struct NameValuePair {
    string name;
    void* value;
    int type;
    
    template <typename T>
    void setValue(T *valuePtr) {

        if(typeid(T) == typeid(int&))
            type = _INT;
        else if(typeid(T) == typeid(string&))
            type = _STRING;
        else if(typeid(T) == typeid(float&))
            type = _FLOAT;
        else if(typeid(T) == typeid(bool&))
            type = _BOOL;
        else
            cout << "* NameValuePair error: template type is unknown *" << endl;
        
        value = valuePtr;
    };
 
};



class ofxTouchGUI {

public:
    
    ofxTouchGUI();
	~ofxTouchGUI();
    void resetDefaultValues();
    void loadSettings(string saveToFile = "settings.xml", bool loadDefaultFont = false, bool useMouse = false);
    bool useMouse; // by default this is false for touch controls
    
    // style
    bool hasBackground;
	void loadBackground(string imgPath);
    ofImage background;
    // color background
    bool hasBackgroundColor;
    void setBackgroundColor(ofColor bg,int bgX=-1, int bgY=-1, int bgWidth=-1, int bgHeight=-1);
    ofColor bg;
    int bgX,bgY,bgWidth,bgHeight;
    bool hasFont;
    void loadFont(string fontPath, int fontSize, int fontSizeLarge, bool antialiased = true);
    void loadFonts(string fontPathSmall, string fontPathLarge, int fontSizeSmall, int fontSizeLarge, bool antialisedSmall = true, bool antialisedLarge = true);
    ofTrueTypeFont guiFont;
    ofTrueTypeFont guiFontLarge;
    int fontSize;
    int fontSizeLarge;

    // default positioning/sizing
    int defaultPosX;
    int defaultPosY;
    int defaultColumn;
    int defaultColumnSpacer;
    int defaultItemWidth;
    int defaultItemHeight;
    int defaultSpacer;
    void checkPosSize(int& posX, int& posY, int& width, int& height);
    int lastItemPosX;
    int lastItemPosY;
    int lastItemWidth;
    int lastItemHeight;
    void moveTo(int posX, int posY); // all subsequently added items will be added from this position
    void setSize(int width, int height); // all subsequently added items will have this width/height
    void setWidth(int width);
    void setHeight(int height);
    void setItemSpacer(int space);
    void setColumnSpacer(int space);
    
    // when auto positioning you can call this to change columns before adding another item
    void nextColumn();
    //void previousColumn();
    
    // drawing
    void draw();
    bool isHidden;
    void show();
    void hide();
    void toggleDisplay();
    bool isAutoDrawing;
    void autoDraw(bool allowAutoDraw = true);
    void aDraw(ofEventArgs &e);
        
    // slider
    ofxTouchGUISlider* addSlider(string sliderLabel, float *val, float min, float max, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUISlider* addSlider(string sliderLabel, int *val, int min, int max, int posX=-1, int posY=-1, int width=-1, int height=-1);

    // variable display
    ofxTouchGUIText* addVarText(string textLabel, string *val, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUIText* addVarText(string textLabel, int *val, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUIText* addVarText(string textLabel, bool *val, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUIText* addVarText(string textLabel, float *val, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    // text
    ofxTouchGUIText* addTitleText(string textLabel, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUIText* addText(string textLabel, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    // button
    ofxTouchGUIButton* addButton(string btnLabel, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    // toggle/checkbox
    ofxTouchGUIToggleButton* addToggleButton(string toggleLabel, bool *toggleVal, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    // dropbox
    ofxTouchGUIDropDown* addDropDown(string listLabel, int numValues, string* listValues, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUIDropDown* addDropDown(string listLabel, int numValues, int* selectedId, string* listValues, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUIDropDown* addDropDown(string listLabel, int numValues, vector<string> listValues, int posX=-1, int posY=-1, int width=-1, int height=-1);
    ofxTouchGUIDropDown* addDropDown(string listLabel, int numValues, int* selectedId, vector<string> listValues, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    // text input (ios only)
    ofxTouchGUITextInput* addTextInput(string *placeHolderText, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    // time series graph: not interactive, but good for viewing data over time
    ofxTouchGUITimeGraph* addTimeGraph(string graphLabel, int maxValues, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    
    // add a constant for read only (set once from app, can only be changed in xml) - good for config options
    template <typename T>
    void setConstant(string constName,T *fixedConst); //pointer
    template <typename T>
    void setConstant(string constName,T fixedConst); // non-pointer
    int constantCount;
    
    // variable (not for display)
    template <typename T>
    void setVariable(string varName, T *regVar);
    vector <NameValuePair*>varItems;
    int variableCount;
    
    // save settings xml
    string saveToFile;
    string defaultSaveToFile;
    void saveSettings();
    ofxXmlSettings XML;
    bool settingsLoaded;
    
    // using a template to pass in parameter of any type
    template <typename T>
    bool saveControl(string currentType, string currentLabel, T* currentValue, bool overwriteXMLValue = false);    
    
    // all controls
    NameValuePair* getVarByLabel(string textLabel);
    ofxTouchGUIBase* getItemByLabelAndType(string textLabel, string itemType);
    ofxTouchGUIBase* getItemById(string itemId);
    vector <ofxTouchGUIBase*> guiItems;
    int numGuiItems;
    
    // osc settings
    void setupSendOSC(string host, int port);
    void disableSendOSC();
    ofxOscSender* oscSender;
    bool oscEnabled;
    
    ofxOscMessage msg;
    void sendOSC(string address, float val); // send any generic message- must pass address + value
    void sendOSC(string address, int val);
};




