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
    float crossLineWidth;
    
    // touch events
    virtual bool onUp(float x, float y);
    
    void doToggleAction(bool toggleSelect, bool doOSC = true);
    
    // toggle values
    bool *toggleVal; 
    bool defaultToggleVal; 
    void setValues(bool *toggleVal);
    
    bool getValue();
    
    void loadImageStates(string onImagePath, string offImagePath, bool useWidthHeightFromImage = true);
    void setImageStates(ofImage& onImage, ofImage& offImage, bool useWidthHeightFromImage = true);
    
    // overriden to copy cross properties
    void copyStyle(ofxTouchGUIToggleButton* source);
    
protected:
    
    ofImage onImage;
    ofImage offImage;
    bool hasImages;
};

