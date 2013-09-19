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
    eegMaxAverage = 0;
    eegAveragingEnabled = false;
    currentValue = 0;
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
    
    // local (spikes mess this up)
    if(currentValue > eegMax)
        eegMax = currentValue;
    //else if(currentValue < dynamicEegMin)
      //  dynamicEegMin = currentValue;
    
    // local average max (avoids problems with single spikes)
    if(!eegAveragingEnabled) return;
    if(eegSamples.size() < eegSampleCount) {
        eegSamples.push_back(currentValue);
    } else {
        
        // get average maximum
        float sum = 0;
        for(int i = 0; i < eegSamples.size(); i++) {
            sum += eegSamples[i];
        }
        eegMaxAverage = sum / eegSamples.size();
        
        // add to end of list if higher than average
        // add to list if close to average?
        float p = 1;
        if(eegMaxAverage > 0) p = currentValue / eegMaxAverage;
        if(p > 0.75) {
            eegSamples.push_back(currentValue);
            while(eegSamples.size() > eegSampleCount) eegSamples.pop_front();
        }
    }
}


void EegTimeGraph::enableMaxAveraging(int samples) {
    eegSampleCount = samples;
    eegAveragingEnabled = true;
}

//--------------------------------------------------------------
void EegTimeGraph::draw(){
    
    if(!isHidden()) {
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
                
                if(eegAveragingEnabled)
                    shapeVertices[++glCursorIndex] = ofMap(savedValues[i], 0, eegMaxAverage, height, 0);
                else
                    shapeVertices[++glCursorIndex] = ofMap(savedValues[i], 0, eegMax, height, 0);
            }
            shapeVertices[++glCursorIndex] = destX;
            shapeVertices[++glCursorIndex] = height;
        }
        
        float mainMax = eegMax;
        if(useGlobalRanges)
            mainMax = dynamicEegMaxValues[maxValuesToSave-1];
        else if(eegAveragingEnabled)
            mainMax = eegMaxAverage;
        
        float perc = 0;
        if(mainMax > 0) perc = currentValue / mainMax;
        /*if(perc > 0.9)
            ofSetColor(ofColor(0,255,0));
        else*/
        
        ofSetColor(graphFillClr);
        glVertexPointer(2, GL_FLOAT, 0, &shapeVertices[0]); //GLint size, GLenum type, GLsizei stride, const GLvoid *pointer
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, maxValuesToSave * 2); // number of vertexs/colours
        glDisableClientState(GL_VERTEX_ARRAY);
        
        // draw text
        ofSetColor(textColourDark);
        
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
        drawLargeText(ofToString( int( perc * 100) ) + "%", width - 60, height/2-textOffsetY + 5);
        ofPopStyle();
          
        ofPopMatrix();   
    }
}





