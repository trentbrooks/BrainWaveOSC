#include "EegFrequencyGraph.h"



EegFrequencyGraph::EegFrequencyGraph(){
    
    bgClrTL = ofColor(255,90); //rgba
    bgClrTR = ofColor(255,90);//180,180,180,255); //rgba
    bgClrBL = ofColor(255,90); //rgba
    bgClrBR = ofColor(255,90);//(180,180,180,255); //rgba*/
}

EegFrequencyGraph::~EegFrequencyGraph(){

}
//--------------------------------------------------------------
void EegFrequencyGraph::draw(){
    
    if(!isHidden()) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        
        // bg
        drawGLRect(vertexArrActive, colorsArr);
        
        // custom triangle strip for data
        ofPushStyle();
        
        // set all gl values
        // gl- values need to be scaled to width + height
        
        int sectionWidth = width / (maxValuesToSave-1);
        for(int i = 0; i < maxValuesToSave; i++) {
            
            if(i < maxValuesToSave-1) {
                ofSetColor(255,127);
                if(i > 0) ofLine(i * sectionWidth, 0, i * sectionWidth, height);
                ofSetColor(graphFillClr);
                drawText(ofToString(savedValues[i]),  i * sectionWidth+textOffsetX+5, 12);
            }                
            
            float destX = ofMap(i, 0, maxValuesToSave-1, 0, width);
            int glCursorIndex = i * 4;
            shapeVertices[glCursorIndex] = destX;
            shapeVertices[++glCursorIndex] = ofMap(savedValues[i], min, max, height, 0);
            shapeVertices[++glCursorIndex] = destX;
            shapeVertices[++glCursorIndex] = height;
            
            
        }
        
        ofSetColor(graphFillClr);
        glVertexPointer(2, GL_FLOAT, 0, &shapeVertices[0]); //GLint size, GLenum type, GLsizei stride, const GLvoid *pointer
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, maxValuesToSave * 2); // number of vertexs/colours
        glDisableClientState(GL_VERTEX_ARRAY);
        
        // draw text
        //ofSetColor(textColour);
        drawText(label + " : " + ofToString(max), textOffsetX, textOffsetY);
        ofPopStyle();
        
        ofPopMatrix();
    }
}






