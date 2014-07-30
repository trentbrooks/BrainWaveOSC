#include "ofxTouchGUIText.h"



ofxTouchGUIText::ofxTouchGUIText(){
    
    isTextTitle = false;
    drawTextBg = false;
    floatVal = 0;
    intVal = 0;
    stringVal = 0;
    boolVal = 0;
    textType = TEXT_STRING_VAL;//-1;//TEXT_STRING;
    baseLineOffset = 0;
    
    // bg background is dark by default (same as foreground colours)
    //bgClrTL = ofColor(40,40,40,255); //rgba
    //bgClrTR = ofColor(40,40,40,255); //rgba
    //bgClrBL = ofColor(40,40,40,255); //rgba
    //bgClrBR = ofColor(40,40,40,255); //rgba
    
    // bg background is PINK! by default, but it's also off by default
    bgClrTL = ofColor(215,40,127); //pink
    bgClrTR = ofColor(215,40,127); //pink
    bgClrBL = ofColor(215,40,127); //pink
    bgClrBR = ofColor(215,40,127); //pink
}

ofxTouchGUIText::~ofxTouchGUIText(){
	
}

// for var text
void ofxTouchGUIText::resetDefaultValue(){
    
    // reset the toggle value to the original value passed in by setValues
    if(textType == TEXT_STRING)
        *stringVal = defaultStringVal;
    else if(textType == TEXT_FLOAT)
        *floatVal = defaultFloatVal;
    else if(textType == TEXT_INT)
        *intVal = defaultIntVal;
    else if(textType == TEXT_BOOL)
        *boolVal = defaultBoolVal;
}


//--------------------------------------------------------------
void ofxTouchGUIText::setValue(float *val) {	
    
	this->floatVal = val;
    defaultFloatVal = *val; // default value copied for resetting
    textType = TEXT_FLOAT;
}

//--------------------------------------------------------------
void ofxTouchGUIText::setValue(int *val) {	
    
	this->intVal = val;
    defaultIntVal = *val; // default value copied for resetting
    textType = TEXT_INT;
}

//--------------------------------------------------------------
void ofxTouchGUIText::setValue(bool *val) {	
    
	this->boolVal = val;
    defaultBoolVal = *val; // default value copied for resetting
    textType = TEXT_BOOL;
}

//--------------------------------------------------------------
void ofxTouchGUIText::setValue(string *val) {	
    
	this->stringVal = val;
    defaultStringVal = *val; // default value copied for resetting
    textType = TEXT_STRING;
    //textOffsetX = 0;
}

//--------------------------------------------------------------
void ofxTouchGUIText::setBackgroundVisible(bool vis) {
    drawTextBg = vis;
}

// overriden
void ofxTouchGUIText::copyStyle(ofxTouchGUIText* source) {
    
    ofxTouchGUIBase::copyStyle(source);
    drawTextBg = source->drawTextBg;
}
//--------------------------------------------------------------
void ofxTouchGUIText::draw(){
    
    if(!hidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        if(drawTextBg) drawGLRect(vertexArr,colorsArr);//vertexArrActive, colorsArrActive);
        
        // draw text
        ofPushStyle();
        //ofSetColor(textColourDark);
        //ofSetColor(textColourLight);
        ofSetColor(textColour);
        
        //ofNoFill();
        //drawGLRect(vertexArr, colorsArr);
        /*if(isTextTitle) {
            drawLargeText(label, 0, textOffsetY);//textOffsetY * 2);//textOffsetY); 
            //drawLargeText(label);
        } else {
            drawText(label, 0, textOffsetY);//textOffsetY * 2);//textOffsetY);
            //drawText(label);
        }*/
        
        // draw text
        //drawText(label, 0);
        int yOffset = baseLineOffset + ceil(height * 0.5) + textOffsetY;
        if(textType == TEXT_STRING)
            drawText(label + " : " + ofToString(*stringVal), textOffsetX, yOffset);
        else if(textType == TEXT_FLOAT)
            drawText(label + " : " + ofToString(*floatVal), textOffsetX, yOffset);
        else if(textType == TEXT_INT)
            drawText(label + " : " + ofToString(*intVal), textOffsetX, yOffset);
        else if(textType == TEXT_BOOL)
            drawText(label + " : " + ofToString(*boolVal), textOffsetX, yOffset);
        else if(textType == TEXT_STRING_VAL) {
            if(isTextTitle)
                drawLargeText(label, textOffsetX, baseLineOffset + textOffsetY);//textOffsetY * 2);//textOffsetY);
            else
                drawText(label, textOffsetX, baseLineOffset + textOffsetY);//textOffsetY * 2);//textOffsetY);
        }
        ofPopStyle();
        
        
        ofPopMatrix();
    }
    
    
}

/*
 int fontWidth = guiFont.stringWidth(label);
 guiFont.drawString(label, int(width - fontWidth - textOffsetX), int(textOffsetY + height * 0.5) );    
 guiFont.drawString(ofToString(formattedValue), textOffsetX, int(textOffsetY + height * 0.5) );
 }
 else
 {
 int fontWidth2 = (int)label.length() * 8; // trying to figure out how wide the default text is, magic number= 8px?
 */

void ofxTouchGUIText::formatText(bool isTextTitle) {
    
    this->isTextTitle = isTextTitle;
    
    label = wrapString(label, width - textOffsetX);
    
    if(hasFont) {
    
        if(isTextTitle) {
            // automatically offset the text based on the font size
            //textOffsetX = fontSizeLarge;
            baseLineOffset = guiFontLarge->getSize()+1 + ceil(guiFontLarge->getLineHeight()/2); ///2;//guiFontLarge->getSize() + (guiFontLarge->getSize()/2);
            int textHeight = ceil(guiFontLarge->stringHeight(label)) + baseLineOffset + textOffsetY;
            if(textHeight > height) height = textHeight;
            
            
        } else {
            baseLineOffset = guiFont->getSize()+1 + ceil(guiFont->getLineHeight()/2); ///2;//guiFont->getSize() + (guiFont->getSize()/2);
            int textHeight = ceil(guiFont->stringHeight(label)) + baseLineOffset + textOffsetY;
            if(textHeight > height) height = textHeight;
        }
    }
    
    
    updateGLArrays();
}

string ofxTouchGUIText::wrapString(string text, int maxWidth) {
	
	string typeWrapped = "";
	string tempString = "";
	vector <string> words = ofSplitString(text, " ");
	int stringwidth = 0;
    
	for(int i=0; i<words.size(); i++) {
		
		string wrd = words[i];
		
		// if we aren't on the first word, add a space
		if (i > 0) {
			tempString += " ";
		}
		tempString += wrd;
		
        if(hasFont) {
            
            if(isTextTitle) {
                stringwidth = guiFontLarge->stringWidth(tempString);
            } else {
                stringwidth = guiFont->stringWidth(tempString); 
            }
             
        } else {
            // magic number here used as well as slider!
            stringwidth = (int)tempString.length() * 8; // trying to figure out how wide the default text is, magic number= 8px?
        }
        
		if(stringwidth >= maxWidth) {
			typeWrapped += "\n";
			tempString = wrd;		// make sure we're including the extra word on the next line
		} else if (i > 0) {
			// if we aren't on the first word, add a space
			typeWrapped += " ";
		}
		
		typeWrapped += wrd;
	}
    
    return typeWrapped;
}







