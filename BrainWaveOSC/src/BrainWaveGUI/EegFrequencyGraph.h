#pragma once

#include "ofMain.h"
#include "ofxTouchGUIDataGraph.h"



class EegFrequencyGraph : public ofxTouchGUIDataGraph {
	
public:
    
    EegFrequencyGraph();
	~EegFrequencyGraph();
    
    
    // display
    virtual void draw();

};

