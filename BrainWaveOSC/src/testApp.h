#pragma once

#include "ofMain.h"
#include "ofxThinkgear.h"
#include "BrainWaveGUI.h"


struct EegData {
    float signal; // 0 = good
    float attention, meditation; //80-100 = high, 40-60 = baseline
    float eegDelta, eegTheta, eegLowAlpha, eegHighAlpha, eegLowBeta, eegHighBeta, eegLowGamma, eegMidGamma; // random, only useful when comparing against each other

    vector<float> rawDataBufferValues; // -2048 - 2048
    float elapsed; // seconds
};

class testApp : public ofBaseApp {
    
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
    void onGuiChanged(const void* sender, string &buttonLabel);
    
    // gui items
    ofxTouchGUITimeGraph *poorSignalGraph, *attentionGraph, *meditationGraph;
    ofxTouchGUIText* rawDataText;
    EegTimeGraph* eegDeltaGraph;
    EegTimeGraph* eegThetaGraph;
    EegTimeGraph* eegLowAlphaGraph;
    EegTimeGraph* eegHighAlphaGraph;
    EegTimeGraph* eegLowBetaGraph;
    EegTimeGraph* eegHighBetaGraph;
    EegTimeGraph* eegLowGammaGraph;
    EegTimeGraph* eegMidGammaGraph;
    vector<EegTimeGraph*> eegSet; 

    float startTime;
    float timeElapsed;
    
    // file saving
    ofFile output;
    bool isRecording;    
    bool captureRawData;
    float rawDataValue;
    string rawDataBuffer; // multiple raw data values seperated by '|'
    
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

    bool drawCharts;
    
    // playback
    void loadPlaybackFile(string path);
    bool loadFromFile;
    bool playbackMode;
    int playhead;
    vector<EegData> dataEntries;
};
