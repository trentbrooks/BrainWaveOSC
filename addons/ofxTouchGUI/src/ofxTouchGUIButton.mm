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
        this->width = upImage.width;
        this->height = upImage.height;
    }
}


//--------------------------------------------------------------
void ofxTouchGUIButton::draw(){
    
    if(!hidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        
        if(hasImages) {
            
            if(isPressed) {
                downImage.draw(0,0);
            }
            else {                
                upImage.draw(0,0);
            }
            
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
    
    if(!isInteractive || hidden) return false;
    
    // when this or another item itemActive (eg. dropdown), ignore all touch/mouse events
    //if(ignoreExternalEvents && !itemActive) return;
    
    if(isPressed) {
        
        // reset press same as normal button
        isPressed = false;
        
        if(hitTest(x,y)) {
            doButtonAction();
            //ofNotifyEvent(onChangedEvent,label,this);
            //sendOSC(1);
            return true;
        }
    }
    
    return false;
    
}

// doOSC must = false when called from the osc receiver, otherwise it gets stuck in an infinite loop
void ofxTouchGUIButton::doButtonAction(bool doOSC) {
    
    ofNotifyEvent(onChangedEvent,label,this);
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


