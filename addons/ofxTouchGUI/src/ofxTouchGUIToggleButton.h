#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"


class ofxTouchGUIToggleButton : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUIToggleButton();
	~ofxTouchGUIToggleButton();
    virtual void resetDefaultValue();
    
    // display
    virtual void draw();
    ofColor crossX;
    int crossOffset;
    
    // touch events
    virtual void onUp(float x, float y);
    
    // toggle values
    bool *toggleVal; 
    bool defaultToggleVal; 
    void setValues(bool *toggleVal);
    
    bool getValue();
};

