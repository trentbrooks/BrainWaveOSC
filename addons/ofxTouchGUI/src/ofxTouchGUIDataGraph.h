#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"


class ofxTouchGUIDataGraph : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUIDataGraph();
	~ofxTouchGUIDataGraph();
    
    void reset();
    
    // for charting the values over time    
    void setCustomRange(float min, float max); 
    void setMaximumValues(int count); // size of chart entries    
    deque<float> savedValues;
    void insertValue(float val);
    float currentValue;
    
    // gl    
    void setFilled(bool fill);
    void setGraphFillClr(ofColor clr);
    
    // display
    virtual void draw();
    
protected:
    
    float min;
    float max;
    bool isCustomRangeSet; // off by default, graph is scaled dynamically
    int maxValuesToSave;
    
    //gl
    vector<float> shapeVertices;
    ofColor graphFillClr;
    bool isFilled; // line based or triangle based
};

