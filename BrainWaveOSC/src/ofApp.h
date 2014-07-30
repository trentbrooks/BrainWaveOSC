#pragma once

#include "ofMain.h"
#include "ofxThinkgear.h"
#include "BrainWaveGUI/BrainWaveGUI.h"

// osascript -e 'tell application "System Events"' -e 'shut down' -e 'end tell'
// sudo halt
// osascript -e 'tell application "System Events" to restart'
// osascript -e 'tell application "System Events" to shut down'
// osascript -e 'tell application "System Events" to sleep'

#define _VER 0.93

struct EegData {
    float signal; // 0 = good
    float attention, meditation; //80-100 = high, 40-60 = baseline
    float blinkStrength; // only works with comms driver
    
    float eegDelta, eegTheta, eegLowAlpha, eegHighAlpha, eegLowBeta, eegHighBeta, eegLowGamma, eegHighGamma; // random, only useful when comparing against each other

    vector<float> rawDataBufferValues; // -2048 - 2048
    float elapsed; // seconds
    
    float getTotalActivity() {
        return eegDelta + eegTheta + eegLowAlpha + eegHighAlpha + eegLowBeta + eegHighBeta + eegLowGamma + eegHighGamma;
    }
};

class ofApp : public ofBaseApp {
    
public:
    
    void setup();
    void update();
    void draw();
    
    void keyPressed  (int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    
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
    
    // gui
    void setupGui();
    BrainWaveGUI settings;
    void onGUIChanged(ofxTouchGUIEventArgs& args);
    bool smallWindow;
    
    
    // gui items
    ofxTouchGUIDataGraph *attentionGraph, *meditationGraph; //*poorSignalGraph, 
    ofxTouchGUIText* poorSignalText;
    ofxTouchGUIText* rawDataText;
    EegTimeGraph* eegDeltaGraph;
    EegTimeGraph* eegThetaGraph;
    EegTimeGraph* eegLowAlphaGraph;
    EegTimeGraph* eegHighAlphaGraph;
    EegTimeGraph* eegLowBetaGraph;
    EegTimeGraph* eegHighBetaGraph;
    EegTimeGraph* eegLowGammaGraph;
    EegTimeGraph* eegHighGammaGraph;
    ofxTouchGUIDataGraph* rawDataGraph;
    EegFrequencyGraph* frequencyGraph;
    ofxTouchGUISlider* timeline;
    vector<EegTimeGraph*> eegSet;
    
    bool normaliseMaxToCurrentSet;

    float startTime;
    float timeElapsed;

    
    // file saving
    ofFile output;
    bool isRecording;    
    bool captureRawData;
    float rawDataValue;
    string rawDataBuffer; // multiple raw data values seperated by '|'
    float blinkStrength;
    
    // osc
    string host;
    int port;
    bool sendOscEveryFrame;
    
    // mindplay brainband bluetooth device
    ofxThinkgear tg;
    ofxThinkgearEventArgs data;
    string deviceName;
    int deviceBaudRate;
    
    // custom eeg data struct to capture all the data from thinkgear events
    EegData allData;
    
    // playback
    void loadPlaybackFile(string path);
    bool loadFromFile;
    bool playbackMode;
    bool isPaused;
    int playhead;
    vector<EegData> dataEntries;
    
    
};
