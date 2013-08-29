#include "ofxTouchGUISlider.h"



ofxTouchGUISlider::ofxTouchGUISlider(){

    // INIT SLIDER PROPS
    val = 0;
    intVal = 0;
    min = 0;
    max = 1;
    useInteger = false;
 
}

ofxTouchGUISlider::~ofxTouchGUISlider(){
	
    
}

void ofxTouchGUISlider::resetDefaultValue(){
    
    // reset the toggle value to the original value passed in by setValues
    if(useInteger) { *intVal = defaultIntVal; }
    else { *val = defaultVal; }
}


//--------------------------------------------------------------
void ofxTouchGUISlider::setRange(float min, float max) {
    this->min = min;
    this->max = max;
}

//--------------------------------------------------------------
void ofxTouchGUISlider::setValues(float *val, float min, float max) {	

	this->val = val;
    this->min = min;
    this->max = max;
    defaultVal = *val; // default value copied for resetting
}

void ofxTouchGUISlider::setValues(int *val, int min, int max) {	
    
	this->intVal = val;
    this->min = min;
    this->max = max;
    defaultIntVal = *val; // default value copied for resetting
    useInteger = true;
}


    
//--------------------------------------------------------------
void ofxTouchGUISlider::draw(){
    
    if(!isHidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        
        // get value + percentage    
        float formattedValue = (useInteger) ? *intVal : *val;
        float valPerc = (formattedValue - min) / (max-min);    
        float destValX = width * valPerc;
        
        // draw the background rectangle- move the left side of the percentage bar. modify vertex values directly
        vertexArr[0] = destValX; // TL x
        vertexArr[4] = destValX; // BL x
        drawGLRect(vertexArr, colorsArr);
        
        // draw the foreground/active rectangle- move the right side of the percentage bar. modify vertex values directly
        vertexArrActive[2] = destValX; // TL2 x
        vertexArrActive[6] = destValX; // BL2 x
        drawGLRect(vertexArrActive, colorsArrActive);
        
        // draw text
        ofPushStyle();
        ofSetColor(textColour);
        drawText(label, 2);
        drawText(ofToString(formattedValue), 0);
        ofPopStyle();
        
        ofPopMatrix();
    }
}



// TOUCH
//--------------------------------------------------------------
void ofxTouchGUISlider::onUp(float x, float y){
    
    // want to trigger value changes on touch up as well as move
    onMoved(x,y);
    
    ofxTouchGUIBase::onUp(x, y);
}

void ofxTouchGUISlider::onMoved(float x, float y) {
 
     // when this or another item itemActive (eg. dropdown), ignore all touch/mouse events
     //if(ignoreExternalEvents && !itemActive) return;
     
     if(isPressed) {
         
         //if(hitTest(x,y)) {
            float clampedX = ofClamp(x, posX, posX + width);
             float perc = ( clampedX - posX ) / width;
             if(useInteger) {
                 *intVal = (perc * (max - min) ) + min; 
                 sendOSC(*intVal);
                 ofNotifyEvent(onChangedEvent,label,this);
             }
             else { 
                 *val = (perc * (max - min) ) + min; 
                 sendOSC(*val);
                 ofNotifyEvent(onChangedEvent,label,this);
             }
         //}
     }
}


float ofxTouchGUISlider::getValue() {
    
    if(useInteger) {
        return *intVal;
    }
    else { 
        return *val;
    }
}

