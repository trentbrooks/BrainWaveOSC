#pragma once

#include "ofMain.h"
#include "ThinkGearStreamParser.h"

/*
 ofxThinkgear
 - Original addon by Laurent Bedubourg <laurent@labe.me> https://github.com/labe-me/ofxThinkgear
 - Modified by Trent Brooks: deleted a bunch of stuff and added some reconnection fixes. 
 */

class ofxThinkgearEventArgs : public ofEventArgs {
public:
    short raw;
    unsigned char battery;
    unsigned char poorSignal;
    unsigned char blinkStrength;
    unsigned char attention; //50
    unsigned char meditation; // 30
    unsigned int eegDelta; //100000
    unsigned int eegTheta; //300000
    unsigned int eegLowAlpha; //2500
    unsigned int eegHighAlpha; //2500
    unsigned int eegLowBeta; //1500
    unsigned int eegHighBeta; //2500
    unsigned int eegLowGamma; //5000
    unsigned int eegMidGamma; //5000
};


class ofxThinkgear {
public:
    
    string deviceName;
    int baudRate;
    void setup(string deviceName, int baudRate);
    
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

