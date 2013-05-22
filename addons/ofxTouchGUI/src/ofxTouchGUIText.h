#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"

// text will autowrap unless value passed in is a pointer
// todo: add pointer, check if strngs == then format/wrap?
// vars will not autowrap

enum { TEXT_INT, TEXT_FLOAT, TEXT_BOOL, TEXT_STRING, TEXT_STRING_VAL };


class ofxTouchGUIText : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUIText();
	~ofxTouchGUIText();
    
    // display
    virtual void draw();
    bool isTextTitle;
    
    void formatText(bool isTextTitle);
    string wrapString(string text, int maxWidth);
     
    
    
    // for var text only!!!
    // int, float, bool, string text, string title
    int textType;
    
    void resetDefaultValue();
    void setValue(float *val);
    void setValue(int *val);
    void setValue(bool *val);
    void setValue(string *val);
    
    float *floatVal;
    int *intVal;
    bool *boolVal;
    string *stringVal;
    int defaultIntVal; 
    float defaultFloatVal;
    bool defaultBoolVal;
    string defaultStringVal;
};

