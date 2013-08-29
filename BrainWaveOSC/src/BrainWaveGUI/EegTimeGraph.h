#pragma once

#include "ofMain.h"
#include "ofxTouchGUITimeGraph.h"


// had to make this class to add the static vars- so all 8 bands worked off the same range
// hit the 'RESET EEG GRAPH'S TO MAX VALUE' button to normalise the display of the 8 eeg graphs

class EegTimeGraph : public ofxTouchGUITimeGraph {
	
public:
    
    EegTimeGraph();
	~EegTimeGraph();
    
    //static float dynamicEegMin;
    static bool useGlobalRanges;
    static float dynamicEegMax;
    static deque<float> dynamicEegMaxValues;
    static void updateDynamicEegMaxValues(float val);
    static int maxDynamicEegValues;
    float eegMax;
   
    void insertValue(float val);
    int currentValue;
    
    // display
    virtual void draw();

};

