#include "ofxTouchGUIText.h"



ofxTouchGUIText::ofxTouchGUIText(){
    
    isTextTitle = false;
    floatVal = 0;
    intVal = 0;
    stringVal = 0;
    boolVal = 0;
    textType = TEXT_STRING_VAL;//-1;//TEXT_STRING;
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
    textOffsetX = 0;
}
    
//--------------------------------------------------------------
void ofxTouchGUIText::draw(){
    
    if(!isHidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        //drawGLRect(vertexArrActive, colorsArrActive);
        
        // draw text
        ofPushStyle();
        //ofSetColor(textColourDark); 
        ofSetColor(textColourLight); 
        
        /*if(isTextTitle) {
            drawLargeText(label, 0, textOffsetY);//textOffsetY * 2);//textOffsetY); 
            //drawLargeText(label);
        } else {
            drawText(label, 0, textOffsetY);//textOffsetY * 2);//textOffsetY);
            //drawText(label);
        }*/
        
        // draw text
        //drawText(label, 0);
        if(textType == TEXT_STRING)
            drawText(label + " : " + ofToString(*stringVal), 0);
        else if(textType == TEXT_FLOAT)
            drawText(label + " : " + ofToString(*floatVal), 0);
        else if(textType == TEXT_INT)
            drawText(label + " : " + ofToString(*intVal), 0);
        else if(textType == TEXT_BOOL)
            drawText(label + " : " + ofToString(*boolVal), 0);
        else if(textType == TEXT_STRING_VAL) {
            if(isTextTitle)
                drawLargeText(label, 0, textOffsetY);//textOffsetY * 2);//textOffsetY); 
            else
                drawText(label, 0, textOffsetY);//textOffsetY * 2);//textOffsetY);
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
    
    label = wrapString(label, width);
   
    
    if(isTextTitle) {
        // automatically offset the text based on the font size
        textOffsetX = fontSizeLarge;
        textOffsetY = int(textOffsetX / 2);
        //textOffsetY = guiFont->getLineHeight();
        // reset height
        height = guiFontLarge->stringHeight(label) + textOffsetY;
    } else {
        
        textOffsetY = guiFont->getLineHeight();
        //textOffsetY = -guiFont->stringHeight(label) * .5 + 10;
        height = guiFont->stringHeight(label) + textOffsetY; 
        //cout << ">>>>>" << height << endl;
    }
    
    //initGLArrays();
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







