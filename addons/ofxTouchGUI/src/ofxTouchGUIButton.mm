#include "ofxTouchGUIButton.h"



ofxTouchGUIButton::ofxTouchGUIButton(){
    
    // DEFAULT BUTTON BACKGROUND CLRS: GRADIENT DARKER GRAY 75%
    // creates a darker fade from top to bottom instead of left to right
    bgClrTL = ofColor(140,140,140,255); //rgba
    bgClrTR = ofColor(140,140,140,255); //rgba
    bgClrBL = ofColor(80,80,80,255); //rgba
    bgClrBR = ofColor(80,80,80,255); //rgba
    hasImages = false;
    isInteractive = true;
}

ofxTouchGUIButton::~ofxTouchGUIButton(){
	
}


void ofxTouchGUIButton::loadImageStates(string upImagePath, string downImagePath, bool useWidthHeightFromImage) {
    
    hasImages = true;
    upImage.loadImage(upImagePath); 
    downImage.loadImage(downImagePath); 
    if(useWidthHeightFromImage) {
        this->width = upImage.getWidth();
        this->height = upImage.getHeight();
    }
}

void ofxTouchGUIButton::setImageStates(ofImage& upImage, ofImage& downImage, bool useWidthHeightFromImage) {
    
    hasImages = true;
    this->upImage = upImage;
    this->downImage = downImage;
    if(useWidthHeightFromImage) {
        this->width = upImage.getWidth();
        this->height = upImage.getHeight();
    }
}

//--------------------------------------------------------------
void ofxTouchGUIButton::draw(){
    
    if(!hidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        
        if(hasImages) {
            
            ofPushStyle();
            ofSetColor(255);
            if(isPressed) {
                downImage.draw(0,0);
            }
            else {                
                upImage.draw(0,0);
            }
            ofPopStyle();
            
        } else {
            // draw the background rectangle
            if(isPressed) {
                drawGLRect(vertexArrActive, colorsArrActive);
            }
            else {
                drawGLRect(vertexArr, colorsArr);
            }
            
            // draw text
            ofPushStyle();
            ofSetColor(textColour);
            drawText(label, 1);
            ofPopStyle();
        }
        
        
        ofPopMatrix();
    }
}




bool ofxTouchGUIButton::onUp(float x, float y){
    
    if(ofxTouchGUIBase::onUp(x,y)) {
        doButtonAction();
        return true;
    }
    
    return false;    
}

// doOSC must = false when called from the osc receiver, otherwise it gets stuck in an infinite loop
void ofxTouchGUIButton::doButtonAction(bool doOSC) {
    
    //ofNotifyEvent(onChangedEvent,label,this);
    ofxTouchGUIEventArgs args(this);
    ofNotifyEvent(onChangedEvent, args);
    if(doOSC) sendOSC(1);
}

bool ofxTouchGUIButton::getValue() {
    
    return isPressed;
}



/*
 template <class EventType,typename ArgumentsType, class ListenerClass>
 static void ofAddListener(EventType & event, ListenerClass  * listener, void (ListenerClass::*listenerMethod)(const void*, ArgumentsType&)){
 event += Poco::delegate(listener, listenerMethod);
 }
 
 */


