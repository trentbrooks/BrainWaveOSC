#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"

#ifdef TARGET_OF_IPHONE
    #include "ofxiPhoneKeyboard.h"
#endif


class ofxTouchGUITextInput : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUITextInput();
	~ofxTouchGUITextInput();
    virtual void resetDefaultValue();
    
    // display
    //void updateKeyboard(ofEventArgs &e);
    virtual void draw();
    
    // touch events
    //virtual void onUp(float x, float y);
    
    virtual void hide();
    virtual void show(bool activateSingleItem);
    //ofEvent<string> onButtonPressedEvent;
    
    //void aUpdate(ofEventArgs &e);
    //ofColor fontColor;
    int fontSize;
    
    void setInput(string *placeHolderText);
    string getInput();
    bool keyboardSet;
    bool wasKeyboardOpen;
    void updateKeyboard();
    void onKeyboardInput();
    
    #ifdef TARGET_OF_IPHONE
        ofxiPhoneKeyboard* keyboard;
    #endif
    string *input;
    string defaultInput;
    //string placeHolderInput;
};

