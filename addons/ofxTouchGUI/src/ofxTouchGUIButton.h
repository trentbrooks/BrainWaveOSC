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
    virtual bool onUp(float x, float y);
    void doButtonAction(bool doOSC = true);
    
    void loadImageStates(string upImagePath, string downImagePath, bool useWidthHeightFromImage = true);
    void setImageStates(ofImage& upImage, ofImage& downImage, bool useWidthHeightFromImage = true);
    
    bool getValue();
    
protected:
    
    ofImage upImage;
    ofImage downImage;
    bool hasImages;
    
};

