#include "ofxTouchGUIToggleButton.h"



ofxTouchGUIToggleButton::ofxTouchGUIToggleButton(){
    
    toggleVal = NULL;  
    defaultToggleVal = false;
    
    // DEFAULT TOGGLE BUTTON BACKGROUND CLRS: GRADIENT GRAY 75%
    // creates a fade from right to left instead of left to right       
    bgClrTL = ofColor(120,120,120,255); //rgba
    bgClrTR = ofColor(180,180,180,255); //rgba
    bgClrBL = ofColor(120,120,120,255); //rgba
    bgClrBR = ofColor(180,180,180,255); //rgba   
    
    crossX = ofColor(255,255,255,180); //rgba
    crossOffset = 5;
    
    isInteractive = true;
}

ofxTouchGUIToggleButton::~ofxTouchGUIToggleButton(){
	
}

void ofxTouchGUIToggleButton::resetDefaultValue(){
    
    // reset the toggle value to the original value passed in by setValues
    *toggleVal = defaultToggleVal;
}

//--------------------------------------------------------------
void ofxTouchGUIToggleButton::setValues(bool *toggleVal) {    

    this->toggleVal = toggleVal;
    defaultToggleVal = *toggleVal; // default value copied for resetting
}
    
//--------------------------------------------------------------
void ofxTouchGUIToggleButton::draw(){
    
    if(!hidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        
        float destValX = width - height;
        
        // draw the background rectangle- move the right side of the percentage bar. modify vertex values directly
        vertexArr[2] = destValX; // TL2 x
        vertexArr[6] = destValX; // BL2 x
        drawGLRect(vertexArr, colorsArr);
        
        // draw the foreground/active rectangle- move the left side of the percentage bar. modify vertex values directly    
        // little bg square for the X
        vertexArrActive[0] = destValX; // TL x
        vertexArrActive[4] = destValX; // BL x
        drawGLRect(vertexArrActive, colorsArrActive);
        
        // draw the 'X' if on    
         if(*toggleVal) {
             ofSetColor(crossX);
             ofLine(destValX + crossOffset, crossOffset, width - crossOffset, height - crossOffset);
             ofLine(width - crossOffset, crossOffset, destValX + crossOffset, height - crossOffset);
         }
         
        
        // draw text
        ofPushStyle();
        ofSetColor(textColour);
        drawText(label, 0);
        ofPopStyle();
          
        ofPopMatrix();   
    }
}



bool ofxTouchGUIToggleButton::onUp(float x, float y){
    
    if(ofxTouchGUIBase::onUp(x, y)) {
        if(hitTest(x,y)) {            
            doToggleAction(!*toggleVal);
            return true;
        }
    }
    
    return false;
 
}

// doOSC must = false when called from the osc receiver, otherwise it gets stuck in an infinite loop
void ofxTouchGUIToggleButton::doToggleAction(bool toggleSelect, bool doOSC) {
    
    // switch the toggle value
    *toggleVal = toggleSelect;
    ofNotifyEvent(onChangedEvent,label,this);
    if(doOSC) sendOSC(*toggleVal);    
}


bool ofxTouchGUIToggleButton::getValue() {
    
    return *toggleVal;
}




