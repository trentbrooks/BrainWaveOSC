#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"
//#include "ofxXmlSettings.h"

class ofxTouchGUISlider : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUISlider();
	~ofxTouchGUISlider();
    virtual void resetDefaultValue();
    
    // slider values    
    void setRange(float min, float max);    
	void setValues(float *val, float min, float max);
    void setValues(int *val, int min, int max);
    bool useInteger;
    float *val;
    int *intVal;
    
    // display
    virtual void draw();

    // touch events
    //virtual void touchMoved(float x, float y);
    virtual bool onDown(float x, float y);
    virtual bool onMoved(float x, float y);
    virtual bool onUp(float x, float y);
    //virtual bool overRect(float x, float y);
    void doSliderFloatAction(float sliderVal, bool doOSC = true);
    void doSliderIntAction(int sliderVal, bool doOSC = true);
    void clampInputToSliderVal(float x);
    
    float getValue();
    
    void loadImageStates(string bgImagePath, string fgImagePath, bool useWidthHeightFromImage = true);
    void setImageStates(ofTexture& bgImage, ofTexture& fgImage, bool useWidthHeightFromImage = true);
    
protected:
    
    float min;
    float max;    
    int defaultIntVal;
    float defaultVal;
    
    ofTexture bgImage;
    ofTexture fgImage;
    bool hasImages;
};

