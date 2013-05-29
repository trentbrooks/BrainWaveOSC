#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"


class ofxTouchGUITimeGraph : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUITimeGraph();
	~ofxTouchGUITimeGraph();
    
    void reset();
    
    // for charting the values over time
    float min;
    float max;
    bool isCustomRangeSet; // off by default, graph is scaled dynamically
    void setCustomRange(float min, float max); 
    void setMaximumValues(int count); // size of chart entries
    int maxValuesToSave;
    deque<float> savedValues;
    void insertValue(float val);
    float currentValue;
    
    
    // gl
    //float *shapeVertexArr; // vertex positions array main
    vector<float> shapeVertices;
    ofColor graphFillClr;
    
    
    
    // display
    virtual void draw();
};

