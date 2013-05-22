#include "EegTimeGraph.h"

float EegTimeGraph::dynamicEegMax = 1.0f;
//float EegTimeGraph::dynamicEegMin = 0.0f;

EegTimeGraph::EegTimeGraph(){
    
    
}

EegTimeGraph::~EegTimeGraph(){

}

void EegTimeGraph::insertValue(float val) {
    
    currentValue = val;
    while(savedValues.size() > maxValuesToSave) savedValues.pop_front();
    savedValues.push_back(currentValue);

    // dynamic min/max
    if(isCustomRangeSet) return;
    
    if(currentValue > dynamicEegMax)
        dynamicEegMax = currentValue;
    //else if(currentValue < dynamicEegMin)
      //  dynamicEegMin = currentValue;
}

//--------------------------------------------------------------
void EegTimeGraph::draw(){
    
    if(!isHidden) {
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
            int glCursorIndex = i * 4;
            shapeVertices[glCursorIndex] = destX;
            shapeVertices[++glCursorIndex] = ofMap(savedValues[i], 0, dynamicEegMax, height, 0);
            shapeVertices[++glCursorIndex] = destX;
            shapeVertices[++glCursorIndex] = height;
        }

        ofSetColor(graphFillClr);
        glVertexPointer(2, GL_FLOAT, 0, &shapeVertices[0]); //GLint size, GLenum type, GLsizei stride, const GLvoid *pointer
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, maxValuesToSave * 2); // number of vertexs/colours
        glDisableClientState(GL_VERTEX_ARRAY);
        
        // draw text
        drawText(label + " : " + ofToString(currentValue), textOffsetX, textOffsetY);
        ofPopStyle();
          
        ofPopMatrix();   
    }
}





