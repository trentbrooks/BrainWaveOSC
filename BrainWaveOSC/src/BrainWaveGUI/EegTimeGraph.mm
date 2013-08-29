#include "EegTimeGraph.h"

// statics
float EegTimeGraph::dynamicEegMax = 1.0f;
bool EegTimeGraph::useGlobalRanges = true;
deque<float> EegTimeGraph::dynamicEegMaxValues;
int EegTimeGraph::maxDynamicEegValues = 1;
//float EegTimeGraph::dynamicEegMin = 0.0f;

void EegTimeGraph::updateDynamicEegMaxValues(float val) {
    
    while(dynamicEegMaxValues.size() > maxDynamicEegValues) dynamicEegMaxValues.pop_front();
    dynamicEegMaxValues.push_back(val);
}




EegTimeGraph::EegTimeGraph(){
    
    bgClrTL = ofColor(255,90); //rgba
    bgClrTR = ofColor(255,90);//180,180,180,255); //rgba
    bgClrBL = ofColor(255,90); //rgba
    bgClrBR = ofColor(255,90);//(180,180,180,255); //rgba*/
    eegMax = 1;
}

EegTimeGraph::~EegTimeGraph(){

}

void EegTimeGraph::insertValue(float val) {
    
    currentValue = val;
    while(savedValues.size() > maxValuesToSave) savedValues.pop_front();
    savedValues.push_back(currentValue);

    // dynamic min/max
    if(isCustomRangeSet) return;
    
    // global
    //if(currentValue > dynamicEegMax)
        //dynamicEegMax = currentValue;
    
    // local
    if(currentValue > eegMax)
        eegMax = currentValue;
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
            if(useGlobalRanges) {
                
                // divide by 0 sucks
                if(dynamicEegMaxValues[i] > 0)
                    shapeVertices[++glCursorIndex] = ofMap(savedValues[i], 0, dynamicEegMaxValues[i], height, 0);
                else
                    shapeVertices[++glCursorIndex] = 0;
            } else {
                shapeVertices[++glCursorIndex] = ofMap(savedValues[i], 0, eegMax, height, 0);
            }
            shapeVertices[++glCursorIndex] = destX;
            shapeVertices[++glCursorIndex] = height;
        }

        ofSetColor(graphFillClr);
        glVertexPointer(2, GL_FLOAT, 0, &shapeVertices[0]); //GLint size, GLenum type, GLsizei stride, const GLvoid *pointer
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, maxValuesToSave * 2); // number of vertexs/colours
        glDisableClientState(GL_VERTEX_ARRAY);
        
        // draw text
        ofSetColor(textColourDark);
        float mainMax = (useGlobalRanges) ? dynamicEegMaxValues[maxValuesToSave-1] : eegMax;//eegMax;
        drawText(label + " : " + ofToString(currentValue) + " / " + ofToString(mainMax), textOffsetX, textOffsetY);
        //drawText(label + " : " + ofToString(currentValue) + " / " + ofToString(max), textOffsetX, textOffsetY);
        
        ofSetColor(textColourLight);
        /*if(useGlobalRanges) {
            // float
            drawLargeText(ofToString((currentValue / mainMax) * 100,2) + "%", width - 70, height/2-textOffsetY + 5);
        } else {
            // int
           drawLargeText(ofToString( int( (currentValue / mainMax) * 100) ) + "%", width - 70, height/2-textOffsetY + 5);
        }*/
        // int
        drawLargeText(ofToString( int( (currentValue / mainMax) * 100) ) + "%", width - 60, height/2-textOffsetY + 5);
        ofPopStyle();
          
        ofPopMatrix();   
    }
}





