#pragma once

#include "ofMain.h"
#include "ofxThinkgear.h"

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
    // mindplay brainband bluetooth device
    ofxThinkgear tg;
    ofxThinkgearEventArgs data;
    string deviceName;
    int deviceBaudRate;
    
    void onThinkgearError(ofMessage& err);
    void onThinkgearReady(ofxThinkgearEventArgs& args);
    void onThinkgearRaw(ofxThinkgearEventArgs& args);
    void onThinkgearBattery(ofxThinkgearEventArgs& args);
    void onThinkgearPoorSignal(ofxThinkgearEventArgs& args);
    void onThinkgearBlinkStrength(ofxThinkgearEventArgs& args);
    void onThinkgearAttention(ofxThinkgearEventArgs& args);
    void onThinkgearMeditation(ofxThinkgearEventArgs& args);
    void onThinkgearEeg(ofxThinkgearEventArgs& args);
    void onThinkgearConnecting(ofxThinkgearEventArgs& args);
		
};
