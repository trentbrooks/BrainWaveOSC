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
    void drawOverlay();
    void setArrowClr(ofColor clr);    
    
    // touch events
    virtual bool onUp(float x, float y);
    virtual bool onDown(float x, float y);
    void doSelectAction(int select, bool doOSC = true);
    
    // list + selection
    int* selectId;
    void setValues(int numValues, string* listValues, int *selectedId);
    void setValues(int numValues, string* listValues);
    void setValues(int numValues, vector<string> listValues, int *selectedId);
    void setValues(int numValues, vector<string> listValues);
        
    int getValue();
    
protected:
    
    // toggle display
    bool toggleShowList; // on or off for list disply
    
    string* listValues;
    //string listValues[];
    int numListItems;
    int listHeight;
    
    int initialSelectId;
    int defaultSelectId;
    
    ofColor arrowClr;
    int arrowOffset;
    
};

