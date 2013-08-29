#pragma once

#include "ofMain.h"
#include "ThinkGearStreamParser.h"

/*
 ofxThinkgear
 - Original addon by Laurent Bedubourg <laurent@labe.me> https://github.com/labe-me/ofxThinkgear
 - Modified by Trent Brooks: deleted a bunch of stuff and added some reconnection fixes. 
 */

// comments: sample value / maximum
class ofxThinkgearEventArgs : public ofEventArgs {
public:
    short raw;
    unsigned char battery;
    unsigned char poorSignal;
    unsigned char blinkStrength;
    unsigned char attention; // 50
    unsigned char meditation; // 30
    
    // "ASIC_EEG_POWER" units - dumb
    unsigned int eegDelta; // 100000 / 1500000 . 0.5-2.75hz
    unsigned int eegTheta; // 300000 / 600000 . 3.5-6.75hz
    unsigned int eegLowAlpha; // 2500 / 75000 . 7.5-9.25hz
    unsigned int eegHighAlpha; // 2500 / 150000 . 10-11.75hz
    unsigned int eegLowBeta; // 1500 / 60000 . 13-16.75hz
    unsigned int eegHighBeta; // 2500 / 60000 . 18-29.75hz
    unsigned int eegLowGamma; // 5000 / 300000 . 31-39.75hz
    unsigned int eegMidGamma; // 5000 / 300000 . 41-49.75hz
    
    // added
    unsigned int deviceId; // each device needs it's own id
};


class ofxThinkgear {
public:
    
    string deviceName;
    int deviceId;
    int baudRate;
    void setup(string deviceName, int baudRate, int deviceId);
    
    bool allowRawDataEvents;
    int attempts;
    int noConnectionRestartCount;
    bool parserSetup;
    int unavailableCount;
    int noDataRestartCount;
    
    //bool notifyOnRaw;
    ofSerial* device;
    ofxThinkgearEventArgs values;
    bool isReady;
    ofEvent<ofxThinkgearEventArgs> onRaw;
    ofEvent<ofxThinkgearEventArgs> onBattery;
    ofEvent<ofxThinkgearEventArgs> onPoorSignal;
    ofEvent<ofxThinkgearEventArgs> onBlinkStrength;
    ofEvent<ofxThinkgearEventArgs> onAttention;
    ofEvent<ofxThinkgearEventArgs> onMeditation;
    ofEvent<ofxThinkgearEventArgs> onEeg;
    ofEvent<ofxThinkgearEventArgs> onConnecting;
    ofEvent<ofxThinkgearEventArgs> onReady;
    ofEvent<ofMessage> onError;

    ofxThinkgear();
    ~ofxThinkgear();

    void flush();
    void update();
    void idle();
    bool open();
    void close();

    template <class ListenerClass>
	void addEventListener(ListenerClass * listener){
		ofAddListener(onRaw,listener,&ListenerClass::onThinkgearRaw);
		ofAddListener(onBattery,listener,&ListenerClass::onThinkgearBattery);
		ofAddListener(onPoorSignal,listener,&ListenerClass::onThinkgearPoorSignal);
		ofAddListener(onBlinkStrength,listener,&ListenerClass::onThinkgearBlinkStrength);
		ofAddListener(onAttention,listener,&ListenerClass::onThinkgearAttention);
		ofAddListener(onMeditation,listener,&ListenerClass::onThinkgearMeditation);
		ofAddListener(onEeg,listener,&ListenerClass::onThinkgearEeg);
		ofAddListener(onConnecting,listener,&ListenerClass::onThinkgearConnecting);
		ofAddListener(onReady,listener,&ListenerClass::onThinkgearReady);
		ofAddListener(onError,listener,&ListenerClass::onThinkgearError);
	}

    template <class ListenerClass>
	void removeEventListener(ListenerClass * listener){
		ofRemoveListener(onRaw,listener,&ListenerClass::onThinkgearRaw);
		ofRemoveListener(onBattery,listener,&ListenerClass::onThinkgearBattery);
		ofRemoveListener(onPoorSignal,listener,&ListenerClass::onThinkgearPoorSignal);
		ofRemoveListener(onBlinkStrength,listener,&ListenerClass::onThinkgearBlinkStrength);
		ofRemoveListener(onAttention,listener,&ListenerClass::onThinkgearAttention);
		ofRemoveListener(onMeditation,listener,&ListenerClass::onThinkgearMeditation);
		ofRemoveListener(onEeg,listener,&ListenerClass::onThinkgearEeg);
		ofRemoveListener(onConnecting,listener,&ListenerClass::onThinkgearConnecting);
		ofRemoveListener(onReady,listener,&ListenerClass::onThinkgearReady);
		ofRemoveListener(onError,listener,&ListenerClass::onThinkgearError);
	}

private:
    ThinkGearStreamParser parser;
    unsigned char buffer[512];
};

