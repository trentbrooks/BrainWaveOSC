#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    // setup thinkgear hardware using serial streamer or comms driver (osx only tested).
    // TG_STREAM_PARSER is default
    // blinks only work in TG_COMMS_DRIVER mode
    tg.setup("/dev/tty.BrainBand-Dev", 57600, TG_STREAM_PARSER); //TG_STREAM_PARSER or TG_COMMS_DRIVER
    tg.addEventListener(this);
}

//--------------------------------------------------------------
void ofApp::update(){

}

//--------------------------------------------------------------
void ofApp::draw(){

}

//--------------------------------------------------------------
// thinkgear events
void ofApp::onThinkgearReady(ofxThinkgearEventArgs& args){
    ofLog() << "*** THINKGEAR Ready...";
}

void ofApp::onThinkgearConnecting(ofxThinkgearEventArgs& args){
    ofLog() << "*** THINKGEAR connecting...";
}

void ofApp::onThinkgearError(ofMessage& err){
    ofLog() << "*** THINKGEAR onError..." << err.message;
}

// raw data does not send at frame rate - it sends faster! 512 samples a second
void ofApp::onThinkgearRaw(ofxThinkgearEventArgs& args){
    ofLog() << "raw: " << args.raw;
}

// no visual indicator for blinks
void ofApp::onThinkgearBlinkStrength(ofxThinkgearEventArgs& args){
    // only works when using the comms driver (TG_COMMS_DRIVER)
    ofLog() << "blink: " << args.blinkStrength;
}


// battery never fires?
void ofApp::onThinkgearBattery(ofxThinkgearEventArgs& args){
    ofLog() << "*** THINKGEAR battery: " << args.battery;
}

void ofApp::onThinkgearPoorSignal(ofxThinkgearEventArgs& args){
    ofLog() << "poor signal: " << args.poorSignal;
}

void ofApp::onThinkgearAttention(ofxThinkgearEventArgs& args){
    ofLog() << "attention: " << args.attention;
}

void ofApp::onThinkgearMeditation(ofxThinkgearEventArgs& args){
    ofLog() << "meditation: " << args.meditation;
}

void ofApp::onThinkgearEeg(ofxThinkgearEventArgs& args){
    // about the 8 eeg bands (Comparison table of EEG rhythmic activity frequency bands): http://en.wikipedia.org/wiki/Electroencephalography
    // about neurusky's interpretation: http://support.neurosky.com/kb/development-2/eeg-band-power-values-units-amplitudes-and-meaning
    
    stringstream eegBands;
    eegBands << "delta: " << args.eegDelta;
    eegBands << "theta: " << args.eegTheta;
    eegBands << "alpha low: " << args.eegLowAlpha;
    eegBands << "alpha high: " << args.eegHighAlpha;
    eegBands << "beta low: " << args.eegLowBeta;
    eegBands << "beta high: " << args.eegHighBeta;
    eegBands << "gamma low: " << args.eegLowGamma;
    eegBands << "gamma high: " << args.eegHighGamma;
    ofLog() << eegBands.str();
}


//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
