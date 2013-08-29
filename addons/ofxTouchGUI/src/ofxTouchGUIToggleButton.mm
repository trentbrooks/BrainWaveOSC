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
    
    crossX = ofColor(255,255,255,150); //rgba
    crossOffset = 5;
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
    
    if(!isHidden) {
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



void ofxTouchGUIToggleButton::onUp(float x, float y){
        
    // when this or another item itemActive (eg. dropdown), ignore all touch/mouse events
    //if(ignoreExternalEvents && !itemActive) return;
    
    if(isPressed) {
        
        if(hitTest(x,y)) {
            // switch the toggle value
            *toggleVal = !*toggleVal;
            sendOSC(*toggleVal);
            ofNotifyEvent(onChangedEvent,label,this);
        }
        
        // reset press same as normal button
        isPressed = false;
    }
 
}


bool ofxTouchGUIToggleButton::getValue() {
    
    return *toggleVal;
}




