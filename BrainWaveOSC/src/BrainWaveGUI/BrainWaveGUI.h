#pragma once

#include "ofMain.h"
#include "ofxTouchGUI.h"
#include "EegTimeGraph.h"
#include "EegFrequencyGraph.h"

// extending ofxTouchGUI just to add the custom eeg timegraph

class BrainWaveGUI : public ofxTouchGUI  {

public:
    
    BrainWaveGUI();
	~BrainWaveGUI();
        
    // time series graph: not interactive, but good for viewing data over time
    EegTimeGraph* addCustomTimeGraph(string graphLabel, int maxValues, int posX=-1, int posY=-1, int width=-1, int height=-1);
    
    EegFrequencyGraph* addCustomTimeFrequencyGraph(string graphLabel, int maxValues, int posX=-1, int posY=-1, int width=-1, int height=-1);

};




