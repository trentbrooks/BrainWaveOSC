#include "ofxTouchGUIDataGraph.h"



ofxTouchGUIDataGraph::ofxTouchGUIDataGraph(){
    
    // DEFAULT TOGGLE BUTTON BACKGROUND CLRS: GRADIENT GRAY 75%
    // creates a fade from right to left instead of left to right
    /*bgClrTL = ofColor(255,90); //rgba
    bgClrTR = ofColor(255,90);//180,180,180,255); //rgba
    bgClrBL = ofColor(255,90); //rgba
    bgClrBR = ofColor(255,90);//(180,180,180,255); //rgba*/
    bgClrTL = ofColor(120,120,120,255); //rgba
    bgClrTR = ofColor(180,180,180,255); //rgba
    bgClrBL = ofColor(120,120,120,255); //rgba
    bgClrBR = ofColor(180,180,180,255); //rgba

    currentValue = 0;
    isCustomRangeSet = false;
    //shapeVertexArr = new float[1];
    //shapeVertexArr[0] = 0;
    
    graphFillClr = activeClrTL;
    isFilled = true;
    min = 0.0f;
    max = 0.01f;
    setMaximumValues(50);
    
}

ofxTouchGUIDataGraph::~ofxTouchGUIDataGraph(){
    //if(shapeVertexArr != NULL){ delete[] shapeVertexArr; shapeVertexArr = NULL; }
    shapeVertices.clear();
}

void ofxTouchGUIDataGraph::reset() {
    currentValue = 0;
    for(int i = 0; i < savedValues.size(); i++) {
        savedValues[i] = 0.0f;
    }
    int glArraySize = maxValuesToSave * 4;
    for(int j = 0; j < glArraySize; j++) {
        shapeVertices[j] = 0.0f;
    }
}

void ofxTouchGUIDataGraph::setFilled(bool fill) {
    isFilled = fill;
}

void ofxTouchGUIDataGraph::setGraphFillClr(ofColor clr) {
    graphFillClr = activeClrTL = clr;
}

void ofxTouchGUIDataGraph::setCustomRange(float min, float max) {
    isCustomRangeSet = true;
    this->min = min;
    this->max = max;
    for(int i= 0;i < savedValues.size(); i++) {
        savedValues[i] = min; // reset all to base
    }
}
void ofxTouchGUIDataGraph::setMaximumValues(int count) {
    
    maxValuesToSave = count;
    savedValues.clear();
    savedValues.resize(maxValuesToSave);
    for(int i= 0;i < savedValues.size(); i++) {
        savedValues[i] = min;
    }
    
    int glArraySize = maxValuesToSave * 4;
    shapeVertices.clear();
    shapeVertices.resize(glArraySize);
    for(int j = 0; j < glArraySize; j++) {
        shapeVertices[j] = 0.0f;
    }    
    
    textOffsetY = 15; // have to put this here because of the way the settings work
    
}

void ofxTouchGUIDataGraph::insertValue(float val) {
    
    currentValue = val;
    while(savedValues.size() >= maxValuesToSave) savedValues.pop_front();
    savedValues.push_back(currentValue);

    // dynamic min/max
    if(isCustomRangeSet) return;
    
    if(currentValue > max)
        max = currentValue;
    else if(currentValue < min)
        min = currentValue;
}

//--------------------------------------------------------------
void ofxTouchGUIDataGraph::draw(){
    
    if(!hidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        
        // bg
        drawGLRect(vertexArrActive, colorsArr);

        // custom triangle strip for data
        ofPushStyle();
        
        // set all gl values
        // gl- values need to be scaled to width + height
        for(int i = 0; i < maxValuesToSave; i++) {
            
            float destX = ofMap(i, 0, maxValuesToSave-1, 0, width);
            
            // triangle strip or line strip
            if(isFilled) {
                int glCursorIndex = i * 4;
                shapeVertices[glCursorIndex] = destX;
                shapeVertices[++glCursorIndex] = ofMap(savedValues[i], min, max, height, 0);
                shapeVertices[++glCursorIndex] = destX;
                shapeVertices[++glCursorIndex] = height;
            } else {
                int glCursorIndex = i * 2;
                shapeVertices[glCursorIndex] = destX;
                shapeVertices[++glCursorIndex] = ofMap(savedValues[i], min, max, height, 0);
            }
            
        }

        ofSetColor(activeClrTL);
        glVertexPointer(2, GL_FLOAT, 0, &shapeVertices[0]); //GLint size, GLenum type, GLsizei stride, const GLvoid *pointer
        glEnableClientState(GL_VERTEX_ARRAY);
        if(isFilled)
            glDrawArrays(GL_TRIANGLE_STRIP, 0, maxValuesToSave * 2); // number of vertexs/colours
        else
            glDrawArrays(GL_LINE_STRIP, 0, maxValuesToSave);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        // draw text
        ofSetColor(textColour);
        drawText(label + " : " + ofToString(currentValue) + " / " + ofToString(max), textOffsetX, textOffsetY);
        ofPopStyle();
          
        ofPopMatrix();   
    }
}





