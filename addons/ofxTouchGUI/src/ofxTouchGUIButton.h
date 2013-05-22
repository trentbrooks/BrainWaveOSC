#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"


class ofxTouchGUIButton : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUIButton();
	~ofxTouchGUIButton();
    
    // display
    virtual void draw();
    
    // touch events
    virtual void onUp(float x, float y);
    
    void loadImageStates(string upImagePath, string downImagePath, bool useWidthHeightFromImage = true);
    ofImage upImage;
    ofImage downImage;
    bool hasImages;
    
    //ofEvent<string> onChangedEvent;
    bool getValue();
};

