#pragma once

#include "ofMain.h"
#include "ofxTouchGUITimeGraph.h"



class EegFrequencyGraph : public ofxTouchGUITimeGraph {
	
public:
    
    EegFrequencyGraph();
	~EegFrequencyGraph();
    
    
    // display
    virtual void draw();

};

