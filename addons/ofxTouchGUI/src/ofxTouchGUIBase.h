#pragma once


#include "ofMain.h"
#include "ofEvents.h"
#include "ofxOsc.h"
//static bool ignoreExternalEvents = false;


class ofxTouchGUIBase {
	
public:
    
    ofxTouchGUIBase();
	~ofxTouchGUIBase();
    string type;
    string itemId;
    virtual void resetDefaultValue(); // some values can be reset to their original setting (sliders, toggle, etc)

    
    // GLOBAL STATIC PROPERTY!
    static bool ignoreExternalEvents; // only 1 touch at a time to avoid overlapping button presses.
    static string oscAddress;
    
    // DISPLAY
    virtual void draw();
    virtual void drawText(const string &text, int alignment=-1); //0=left align, 1=center align,2=right align
    virtual void drawText(const string &text, int destX, int destY);
    virtual void drawLargeText(const string &text, int alignment=-1); //0=left align, 1=center align,2=right align
    virtual void drawLargeText(const string &text, int destX, int destY);
    virtual void drawGLRect(float *&vtxArray, float *&clrArray); // take a reference to the pointers
    string label;
    int posX;
    int posY;
    int width;
    int height;
    void setDisplay(string label, int posX, int posY, int width);
    void setDisplay(string label, int posX, int posY, int width, int height);
    bool hasFont;
    void assignFonts(ofTrueTypeFont *guiFont, int fontSize, ofTrueTypeFont *guiFontLarge, int fontSizeLarge);
    ofTrueTypeFont *guiFont;
    ofTrueTypeFont *guiFontLarge;
    int fontSize;
    int fontSizeLarge;
    int textOffsetX;
    int textOffsetY;
    void setTextOffsets(int textOffsetX, int textOffsetY);
    
    
    // touch events
    void enable(bool useMouse=false); // defaults to false = touch events instead of mouse events
    void disable();
    bool isTouchEnabled;
    void enableTouch();
    void disableTouch();
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);
    
    // mouse events
    bool isMouseEnabled;
    void enableMouse();
    void disableMouse();
    void mouseMoved(ofMouseEventArgs& args );
    void mouseDragged(ofMouseEventArgs& args);
    void mousePressed(ofMouseEventArgs& args);
    void mouseReleased(ofMouseEventArgs& args);
    
    // touch/mouse binded
    virtual void onMoved(float x, float y);
    virtual void onDown(float x, float y);
    virtual void onUp(float x, float y);
    bool isPressed;
    
    // dispatched events
    ofEvent<string> onChangedEvent;
    
    // interaction
    bool itemActive;  
    virtual void show(bool activateSingleItem = false);
    virtual void hide();
    bool isHidden;
    virtual bool hitTest(float x, float y);
    virtual bool hitTest(float x, float y, float w, float h);
    
    
    // OPENGL COLOURS/VERTEX
    virtual void initGLArrays();
    float *colorsArr; // background colors array
    float *colorsArrActive; // foreground colours array
    float *vertexArr; // vertex positions array main    
    float *vertexArrActive; // vertex positions 2nd active rectangle
    
    // BACKGROUND CLRS: GRADIENT GRAY 75%
    ofColor bgClrTL;// = 183
    ofColor bgClrTR;// = 137 
    ofColor bgClrBL;// = 183
    ofColor bgClrBR;// = 137
    
    // SLIDER FOREGROUND CLRS: SOLID BLACK 75%
    ofColor activeClrTL;// = 0
    ofColor activeClrTR;// = 0
    ofColor activeClrBL;// = 0
    ofColor activeClrBR;// = 0
    
    ofColor textColourDark; // 0
    ofColor textColourLight; // 255
    
    //customise colors
    void setBackgroundClrs(ofColor singleClr);
    void setBackgroundClrs(ofColor tl, ofColor tr, ofColor bl, ofColor br);
    void setActiveClrs(ofColor singleClr);
    void setActiveClrs(ofColor tl, ofColor tr, ofColor bl, ofColor br);
    
    //virtual int getValue();
    
    
    // OSC
    void enableSendOSC(ofxOscSender * oscSender);
    void disableSendOSC();
    ofxOscSender * oscSenderRef;
    ofxOscMessage msg;
    bool oscEnabled;
    void sendOSC(int val);
    void sendOSC(float val);
    void sendOSC(string val);
    
    // osc address validation
    void setOscAddress(string address);
    string fullOscAddress;
    bool isCharacter(const char Character);
    bool isNumber(const char Character);
    
};

