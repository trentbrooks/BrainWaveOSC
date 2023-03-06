#pragma once

#include "ofMain.h"
#include "ofxTouchGUIBase.h"
#include "ofxTouchGUISlider.h"
#include "ofxTouchGUIText.h"
#include "ofxTouchGUIButton.h"
#include "ofxTouchGUIToggleButton.h"
#include "ofxTouchGUIDropDown.h"
#include "ofxTouchGUITextInput.h"
#include "ofxTouchGUIDataGraph.h"
#include "ofxXmlSettings.h"
#include "ofxOsc.h"
#include "ofxTouchGUIEventArgs.h"

    
/*
 Usage:
 // .h
 ofxTouchGUI settings;
 void onGuiChanged(const void* sender, string &buttonLabel);
 
 //.cpp
 settings.loadSettings("settings.xml", true, true); // savefile, default font, use mouse (true for mouse, false for multitouch/ios).
 settings.addTitleText("ofxTouchGUI");
 settings.addSlider("SLIDER X", &sliderValX, 0.0f, 1.0f);
 settings.addDropDown("DROPDOWN LIST B", 4, &selectListIndex, ddOptions);
 settings.addToggleButton("TOGGLE A", &toggleValA);
 settings.addText(description);
 settings.addButton("SAVE");
 settings.addEventListenerAllItems(this);
 
 // Optional settings: different fonts, background image/colour, auto draw, osc sending.
 settings.setIgnoreXMLValues(true); // ignore previously saved xml values.
 settings.loadFonts("stan0755.ttf", "VAGRoundedStd-Light.otf", 6, 14);
 settings.setLineHeights(12,24); // font line heights
 settings.loadBackgroundImage("guiBg.png");
 settings.setBackgroundColor(ofColor(255,0,255));
 settings.setAutoDraw();
 settings.setupSendOSC("127.0.0.1", 5555);
 settings.setupReceiveOSC(5556);
 settings.setWindowPosition(ofGetWidth()- 250, 0);
 settings.setScrollable(true); // good for ios, new columns will not be auto created, all items add to single column.
 settings.nextColumn(); // subsequent items added to next column
 settings.newPanel(); // makes a new panel for all subsequent items
 settings.showPanel(0); // display the first panel only
 
 // individual item options
 settings.setVariable("host", &hostVar);
 settings.setConstant("port", &portConst); // once set, can only be changed via xml.
 ofxTouchGUIButton* resetBtn = settings.addButton("RESET");
 resetBtn->setTextClr(ofColor(255,255,0));
 resetBtn->setBackgroundClrs(ofColor tl, ofColor tr, ofColor bl, ofColor br);
 resetBtn->setActiveClrs(ofColor tl, ofColor tr, ofColor bl, ofColor br);
 resetBtn->loadImageStates("up.png", "down.png");
 ofAddListener(resetBtn->onChangedEvent, this, &ofApp::onGuiChanged); // not required if settings.addEventListenerAllItems(this) called.
 ofxTouchGUIDataGraph *graph= settings.addTimeGraph("Graph", 500);
 graph->setCustomRange(0, ofGetWidth());
 graph->insertValue(mouseX); // add values manually eg. onMouseMoved()
 */


// ofxTouchGUI versioning
#define OFXTOUCHGUI_VERSION 0.242

// gui item types
#define SLIDER_TYPE "slider"
#define BUTTON_TYPE "button"
#define TOGGLE_TYPE "toggle"
#define TEXT_TYPE "text"
#define DROPDOWN_TYPE "dropdown"
#define TEXTINPUT_TYPE "input"
#define DATAGRAPH_TYPE "datagraph"
#define CONST_TYPE "constant"
#define VAR_TYPE "variable"




// gui item value types
enum { _INT, _FLOAT, _BOOL, _STRING };

// for adding variables
struct TGNameValuePair {
    string name;
    void* value;
    int type;
    
    template <typename T>
    void setValue(T *valuePtr) {
        type = (typeid(T) == typeid(int&)) ? _INT : (typeid(T) == typeid(string&)) ? _STRING : (typeid(T) == typeid(float&)) ? _FLOAT : (typeid(T) == typeid(bool&)) ? _BOOL : -1;
        value = valuePtr;
    };
};

// panel/column with gui items
struct TGPanel {
    vector <ofxTouchGUIBase*> panelGuiItems;
};



class ofxTouchGUI {
    
public:
    
    ofxTouchGUI();
	~ofxTouchGUI();
    
    // setup
    void loadSettings(string saveToFile = "settings.xml", bool loadDefaultFont = true, bool useMouse = true);
    void setIgnoreXMLValues(bool ignoreXML); // ignore previously saved values in xml. all initial values set by app.
    
    // background
	void loadBackgroundImage(string imgPath);
    void setBackgroundColor(ofColor bg,int bgX=-1, int bgY=-1, int bgWidth=-1, int bgHeight=-1);
    
    // fonts
    void loadFont(string fontPath, int fontSize, int fontSizeLarge, bool antialiased = true);
    void loadFonts(string fontPathSmall, string fontPathLarge, int fontSizeSmall, int fontSizeLarge, bool antialisedSmall = true, bool antialisedLarge = true);
    void setLineHeights(float smallLineHeight, float largeLineHeight);
    ofTrueTypeFont& getFont() { return guiFont; }
    ofTrueTypeFont& getLargeFont() { return guiFontLarge; }
    
    // window positioning (affects touch/mouse positions of all gui items)
    void setWindowPosition(int posX, int posY);
    ofVec2f& getWindowPosition();
    
    // default positioning/sizing for individual items
    void moveTo(int posX, int posY); // all subsequently added items will be added from this position
    void setItemSize(int width, int height); // all subsequently added items will have this width/height
    void setItemWidth(int width);
    void setItemHeight(int height);
    void setItemSpacer(int space);
    void setColumnSpacer(int space);
    ofVec2f getItemPosition(); // gets last items position
    int getItemWidth();
    int getItemHeight();
    
    
    // when auto positioning you can call this to change columns before adding another item
    void nextColumn();
    void setAutoColumnMaxY(int maxY); // when to wrap to next column (default ofGetHeight())
    //void previousColumn(); // not implemented
    
    // panels (by default there is only 1 panel)
    int newPanel(); // creates a new panel, all subsequent items added to new panel
    int activePanel;
    void hideAllPanels();
    void showPanel(int panelIndex);
    void showNextPanel();
    void showPreviousPanel();
    vector<TGPanel*> panels;
    
    // Y scrolling only - no limits
    // when scrolling is enabled, adding items with auto positioning will not create new columns
    // ignore scrollwidth and scrollheight for auto width + height
    void setScrollable(bool scrollable, int scrollWidth=-1, int scrollHeight=-1);
    
    
    // drawing/update
    void draw();
    void drawText(string text, int posX, int posY); // draw any generic string
    void drawTitleText(string text, int posX, int posY) ;
    void show();
    void hide();
    void toggleDisplay();
    bool isHidden();
    void setAutoDraw(bool allowAutoDraw = true); // automatically calls draw()
    
    
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
    
    // time/data series graph: not interactive, but good for viewing data over time
    ofxTouchGUIDataGraph* addDataGraph(string graphLabel, int maxValues, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    
    // vars & consts
    // add a constant for read only (set once from app, can only be changed in xml) - good for config options
    template <typename T>
    void setConstant(string constName,T *fixedConst); //pointer
    template <typename T>
    void setConstant(string constName,T fixedConst); // non-pointer
    
    // variable (not for display)
    template <typename T>
    void setVariable(string varName, T *regVar);
    vector <TGNameValuePair*>varItems;
    
    
    // add/remove listeners to all gui items - using addEventListener requires onGuiChanged(const void* sender, string &buttonLabel) method in testApp
    // call after all gui items have been added
    template <class ListenerClass>
	void addEventListenerAllItems(ListenerClass * listener){
        for(int i = 0; i < guiItems.size(); i++) guiItems[i]->addEventListener(listener);
    };
    template <class ListenerClass>
	void removeEventListenerAllItems(ListenerClass * listener){
        for(int i = 0; i < guiItems.size(); i++) guiItems[i]->removeEventListener(listener);
    };
    
    
    // save settings xml
    void saveSettings();
    void resetDefaultValues();
    
    
    // using a template to pass in parameter of any type
    template <typename T>
    bool saveControl(string currentType, string currentLabel, T* currentValue, bool overwriteXMLValue = false);
    
    // all controls
    TGNameValuePair* getVarByLabel(string textLabel);
    ofxTouchGUIBase* getItemByLabelAndType(string textLabel, string itemType);
    ofxTouchGUIBase* getItemById(string itemId);
    ofxTouchGUIBase* getItemByOSCAddress(string oscAddress);
    vector <ofxTouchGUIBase*> guiItems;
    vector <ofxTouchGUIDropDown*> dropDownGuiItems;
    
    
    // osc settings - send
    void setupSendOSC(string host, int port);
    void disableSendOSC();
    void sendOSC(string address, float val); // send any generic message- must pass address + value
    void sendOSC(string address, int val);
    string getHostOSC() {
        return oscSendHostAddress;
    };
    int getPortOSC() {
        return oscSendPort;
    };
    // osc receive
    void setupReceiveOSC(int port);
    void disableReceiveOSC();
    
    
    // mouse/touch events
    void enableTouch();
    void disableTouch();
    void enableMouse();
    void disableMouse();
    void mouseMoved(ofMouseEventArgs& args );
    void mouseDragged(ofMouseEventArgs& args);
    void mouseEntered(ofMouseEventArgs& args);
    void mouseExited(ofMouseEventArgs& args);
    void mousePressed(ofMouseEventArgs& args);
    void mouseReleased(ofMouseEventArgs& args);
    void mouseScrolled(ofMouseEventArgs& args);
    void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);
    
    // touch/mouse binded
    virtual void onMoved(float x, float y);
    virtual void onDown(float x, float y);
    virtual void onUp(float x, float y);
    
protected:
    
    bool useMouse; // by default this is false for touch controls
    
    // style
    bool hasBackgroundImage;
    ofImage backgroundImage;
    bool hasBackgroundColor;
    ofColor bg;
    int bgX,bgY,bgWidth,bgHeight;
    
    // fonts
    ofTrueTypeFont guiFont;
    ofTrueTypeFont guiFontLarge;
    int fontSize;
    int fontSizeLarge;
    bool hasFont;
    
    // window positioning
    ofVec2f windowPosition;
    
    // scrolling
    bool scrollEnabled;
    bool isScrolling;
    float startScrollY;
    int scrollWidth, scrollHeight;
    ofVec2f getFurthestItemPosition();
    bool isFirstUpdate;
    ofVec2f furthestItem;
    bool hitTest(float x, float y);
    
    // default positioning/sizing for individual items
    int defaultItemPosX;
    int defaultItemPosY;
    int defaultColumn;
    int defaultColumnSpacer;
    int defaultItemWidth;
    int defaultItemHeight;
    int defaultSpacer;
    void checkItemPosSize(int& posX, int& posY, int& width, int& height);
    int lastItemPosX;
    int lastItemPosY;
    int lastItemWidth;
    int lastItemHeight;
    int maxColumnY;
    
    // drawing
    bool hidden;
    void aDraw(ofEventArgs &e);
    bool isAutoDrawing;
    
    // vars/consts
    int constantCount;
    int variableCount;
    
    // save settings
    string saveToFile;
    string defaultSaveToFile;
    ofxXmlSettings XML;
    bool ignoreXMLValues;
    bool settingsLoaded;
    
    // controls
    int numGuiItems;
    
    // osc
    ofxOscSender* oscSender;
    string oscSendHostAddress;
    int oscSendPort;
    ofxOscReceiver* oscReceiver;
    ofxOscMessage msg;
    bool oscSendEnabled;
    bool oscReceiveEnabled;
    void checkOSCReceiver();
    
};








