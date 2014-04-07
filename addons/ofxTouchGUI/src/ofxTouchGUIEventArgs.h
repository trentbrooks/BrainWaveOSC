
#pragma once

#include "ofMain.h"

class ofxTouchGUIBase;

// adding custom event
class ofxTouchGUIEventArgs : public ofEventArgs {
public:
    
    ofxTouchGUIEventArgs() {};
    ofxTouchGUIEventArgs(ofxTouchGUIBase *tgb) {
        target = tgb;
    };
    
    ofxTouchGUIBase* target;
};
