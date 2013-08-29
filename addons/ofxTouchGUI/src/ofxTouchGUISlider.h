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
    float min;
    float max;
    void setRange(float min, float max);
    float *val;
    int *intVal;
    int defaultIntVal; 
    float defaultVal; 
    bool useInteger;
	void setValues(float *val, float min, float max);
    void setValues(int *val, int min, int max);
    
    // for saved settings
    //ofxXmlSettings *XML;
    
    // display
    virtual void draw();

    // touch events
    //virtual void touchMoved(float x, float y);
    //virtual void onDown(float x, float y);
    virtual void onMoved(float x, float y);
    virtual void onUp(float x, float y);
    //virtual bool overRect(float x, float y);

    
    float getValue();
};

