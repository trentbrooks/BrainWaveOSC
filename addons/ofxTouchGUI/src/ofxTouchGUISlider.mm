#include "ofxTouchGUISlider.h"



ofxTouchGUISlider::ofxTouchGUISlider(){

    // INIT SLIDER PROPS
    val = 0;
    intVal = 0;
    min = 0;
    max = 1;
    useInteger = false;
    isInteractive = true;
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
    
    if(!hidden) {
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
bool ofxTouchGUISlider::onUp(float x, float y){
    
    if(ofxTouchGUIBase::onUp(x, y)) {
        // want to trigger value changes on touch up as well as move.
        onMoved(x,y);
        return true;
    }
    
    return false;
}

bool ofxTouchGUISlider::onMoved(float x, float y) {
 
    if(!isInteractive || hidden) return false;
     
     if(isPressed) {
         
         // must be touching inside the slider to move.
         if(hitTest(x,y)) {
            float clampedX = ofClamp(x, posX, posX + width);
             float perc = ( clampedX - posX ) / width;
             if(useInteger) {
                 int sliderIntVal = (perc * (max - min) ) + min;
                 doSliderIntAction(sliderIntVal);
                 return true;
             }
             else { 
                 float sliderFloatVal = (perc * (max - min) ) + min;
                 doSliderFloatAction(sliderFloatVal);
                 return true;
             }
         }
     }
    
    return false;
}

void ofxTouchGUISlider::doSliderFloatAction(float sliderVal, bool doOSC) {
    
    *val = sliderVal;
    ofNotifyEvent(onChangedEvent,label,this);
    if(doOSC) sendOSC(*val);
}


void ofxTouchGUISlider::doSliderIntAction(int sliderVal, bool doOSC) {
    
    *intVal = sliderVal;
    ofNotifyEvent(onChangedEvent,label,this);
    if(doOSC) sendOSC(*intVal);
}


float ofxTouchGUISlider::getValue() {
    
    if(useInteger) {
        return *intVal;
    }
    else { 
        return *val;
    }
}

