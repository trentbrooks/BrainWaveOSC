#pragma once


#include "ofMain.h"
#include "ofxTouchGUIBase.h"


class ofxTouchGUIDropDown : public ofxTouchGUIBase {
	
public:
    
    ofxTouchGUIDropDown();
	~ofxTouchGUIDropDown();
    virtual void resetDefaultValue();
    
    // display
    virtual void draw();
    ofColor arrowClr;
    int arrowOffset;
    
    // touch events
    virtual void onUp(float x, float y);
    virtual void onDown(float x, float y);
    
    // toggle display
    bool toggleShowList; // on or off for list disply
    
    // list + selection
    int* selectId;
    int initialSelectId;
    int defaultSelectId;
    void setValues(int numValues, string* listValues, int *selectedId);
    void setValues(int numValues, string* listValues);
    void setValues(int numValues, vector<string> listValues, int *selectedId);
    void setValues(int numValues, vector<string> listValues);
    string* listValues;
    //string listValues[];
    int numListItems;
    int listHeight;
    
    
    int getValue();
};

