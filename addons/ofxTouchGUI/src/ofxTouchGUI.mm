#include "ofxTouchGUI.h"


ofxTouchGUI::ofxTouchGUI(){
	
    // init props
    numGuiItems = 0;
    hasFont = false;
    hasBackgroundImage = false;
    hasBackgroundColor = false;
    useMouse = false;
    settingsLoaded = false;
    isAutoDrawing = false; //isAutoUpdating
    hidden = false;
    oscSendEnabled = oscReceiveEnabled = false;
    oscSendHostAddress = "";
    oscSendPort = -1;
    scrollEnabled = isScrolling = false;
    bgWidth = bgHeight = scrollWidth = scrollHeight = 0;
    isFirstUpdate = true;
    startScrollY = 0;
    constantCount= 0;
    variableCount= 0;
    defaultItemPosX = 20;
    defaultItemPosY = 20;
    defaultColumn = 1;
    defaultColumnSpacer = 25;
    defaultItemWidth = 200;
    defaultItemHeight = 25;
    lastItemPosX = defaultItemPosX;
    lastItemPosY = defaultItemPosY;
    lastItemWidth = defaultItemWidth;
    lastItemHeight = defaultItemHeight;
    defaultSpacer = 5;
    maxColumnY = 768; // need to set the default to ofGetHeight() after setup;
	ignoreXMLValues = false;
    
    TGPanel* panel = new TGPanel();
    panels.push_back(panel);
    activePanel = panels.size()-1;
    
    moveTo(defaultItemPosX, defaultItemPosY);
    setItemSize(defaultItemWidth, defaultItemHeight);
}

ofxTouchGUI::~ofxTouchGUI(){
    
    dropDownGuiItems.clear();
    for(int i = 0; i < numGuiItems; i++) {
        delete guiItems[i];
        guiItems[i] = NULL;
    }
    guiItems.clear();
    
    for(int i = 0; i < variableCount; i++) {
        delete varItems[i];
        varItems[i] = NULL;
    }
    varItems.clear();
    
    for(int i = 0; i < panels.size(); i++) {
        delete panels[i];
        panels[i] = NULL;
    }
    panels.clear();
}



void ofxTouchGUI::resetDefaultValues(){
    
    for(int i = 0; i < numGuiItems; i++) {
        guiItems[i]->resetDefaultValue();
    }
    
    ofLogVerbose() << "Resetting defaults";
}

void ofxTouchGUI::loadSettings(string saveToFile, bool loadDefaultFont, bool useMouse) {
    
    this->saveToFile = saveToFile;
    
    
    #ifdef TARGET_OF_IPHONE        
        this->saveToFile = ofxiPhoneGetDocumentsDirectory() + saveToFile;
        ofLog() << "IOS detected- save to path: " << this->saveToFile;
    #endif
    // load xml from public itunes directory
    if( XML.loadFile(this->saveToFile) ){
        settingsLoaded = true;
    } else {
        ofLog() << "TouchGUI: NO XML file to load. Creating new " << saveToFile;
        saveSettings();
        settingsLoaded = true;
    }
    
    // load the default font
    if(loadDefaultFont) loadFont("stan0755.ttf", 6, 6, false);
    
    // touch controlled or mouse controlled?
    //this->useMouse = useMouse;
    (useMouse) ? enableMouse() : enableTouch();
    
    // adding this here, otherwise crashes on ios in landscape
    maxColumnY = ofGetHeight();
}

void ofxTouchGUI::setIgnoreXMLValues(bool ignoreXML) {
    ignoreXMLValues = ignoreXML;
}

// STYLING
//--------------------------------------------------------------
void ofxTouchGUI::loadBackgroundImage(string imgPath){	
    
    hasBackgroundImage = true;
    backgroundImage.loadImage(imgPath);

}

void ofxTouchGUI::setBackgroundColor(ofColor bg, int bgX, int bgY, int bgWidth, int bgHeight) {
    
    hasBackgroundColor = true;
    this->bg = bg;
    this->bgX = (bgX == -1) ? 0 : bgX;
    this->bgY = (bgY == -1) ? 0 : bgY;
    this->bgWidth = bgWidth;//(bgWidth == -1) ? 0 : bgWidth;
    this->bgHeight = bgHeight;//(bgHeight == -1) ? 0 : bgHeight;
    
}


void ofxTouchGUI::loadFont(string fontPath, int fontSize, int fontSizeLarge, bool antialiased){	
    
    loadFonts(fontPath, fontPath, fontSize, fontSizeLarge, antialiased);
}

void ofxTouchGUI::loadFonts(string fontPathSmall, string fontPathLarge, int fontSizeSmall, int fontSizeLarge, bool antialiasedSmall, bool antialisedLarge){
    
    hasFont = true;
    if(guiFont.loadFont(fontPathSmall,fontSizeSmall,antialiasedSmall,true)) {
        guiFont.setLineHeight(int(fontSizeSmall * 2)); // not sure about this?
    } else {
        hasFont = false;
    }
    
    if(guiFontLarge.loadFont(fontPathLarge,fontSizeLarge,antialisedLarge,true)) {
        guiFontLarge.setLineHeight(int(fontSizeLarge * 2 * .8)); // weird.
    } else {
        hasFont = false;
    }    
    
    this->fontSize = fontSizeSmall; // used to determine text offsetX for gui elements
    this->fontSizeLarge = fontSizeLarge; // used to determine text offsetX
}

void ofxTouchGUI::setLineHeights(float smallLineHeight, float largeLineHeight) {
    
    if(hasFont) {
        guiFont.setLineHeight(smallLineHeight);
        guiFontLarge.setLineHeight(largeLineHeight);
    }
}


// window position
void ofxTouchGUI::setWindowPosition(int posX, int posY) {
    windowPosition.x = posX;
    windowPosition.y = posY;
}

ofVec2f& ofxTouchGUI::getWindowPosition() {
    return windowPosition;
}

// scrolling options
void ofxTouchGUI::setScrollable(bool scrollable, int scrollWidth, int scrollHeight) {
    scrollEnabled = scrollable;
    this->scrollWidth = scrollWidth;
    this->scrollHeight = scrollHeight;
}

// DEFAULT SIZE/POSITIONING
void ofxTouchGUI::checkItemPosSize(int& posX, int& posY, int& width, int& height) {
    if(posX == -1) {
        // move to same position as last item
        posX = (numGuiItems == 0) ? defaultItemPosX : lastItemPosX;
    }
    if(posY == -1) {
        // move to last items position + last items height
        posY = (numGuiItems == 0) ? defaultItemPosY : lastItemPosY + lastItemHeight + defaultSpacer;  
        if(!scrollEnabled && posY > maxColumnY - defaultItemHeight - defaultSpacer) {
            
            // if no more room- move to next column
            posY = defaultItemPosY; // align with top item
            posX = (numGuiItems == 0) ? defaultItemPosX : lastItemPosX + lastItemWidth + defaultItemPosX;
        }
    }
    if(width == -1) {
        width = defaultItemWidth; 
    }
    if(height == -1) {
        height = defaultItemHeight;
    }
    
    // always store last item's pos/size
    lastItemPosX = posX;
    lastItemPosY = posY;
    lastItemWidth = width;
    lastItemHeight = height;
}

// all subsequently added items will be added from this position
void ofxTouchGUI::moveTo(int posX, int posY) {
    lastItemPosX = posX;
    int offsetY = -lastItemHeight - defaultSpacer;
    lastItemPosY = posY + offsetY;
    if(numGuiItems == 0) {
        
        // if no items have been added and we moveTo, defaultItemPosX and defaultItemPosY need to be changed
        defaultItemPosX = lastItemPosX;
        defaultItemPosY = lastItemPosY-offsetY;
        lastItemPosY = defaultItemPosY;
    }
}

ofVec2f ofxTouchGUI::getItemPosition() {
    return ofVec2f(lastItemPosX, lastItemPosY);
}


// auto gap between items
void ofxTouchGUI::setItemSpacer(int space) {
    defaultSpacer = space;
}

// auto gap between columns
void ofxTouchGUI::setColumnSpacer(int space) {
    defaultColumnSpacer = space;
}

// all subsequently added items will have this width/height
void ofxTouchGUI::setItemSize(int width, int height) {
    //lastItemWidth = defaultItemWidth = width;
    //lastItemHeight = defaultItemHeight = height;
    defaultItemWidth = width;
    defaultItemHeight = height;
}

// all subsequently added items will have this width
void ofxTouchGUI::setItemWidth(int width) {
    //lastItemWidth = defaultItemWidth = width;
    defaultItemWidth = width;
}

int ofxTouchGUI::getItemWidth() {
    return defaultItemWidth;
}

// all subsequently added items will have this /height
void ofxTouchGUI::setItemHeight(int height) {
    //lastItemHeight = defaultItemHeight = height;
    defaultItemHeight = height;
}

int ofxTouchGUI::getItemHeight() {
    return defaultItemHeight;
}

// shifts the cursor (moveto) position over
// use the defaultItemWidth + defaultItemHeight instead of lastItemWidth + lastItemHeight
void ofxTouchGUI::nextColumn() {
    
    lastItemPosX = lastItemPosX + defaultItemWidth + defaultColumnSpacer;
    lastItemPosY = defaultItemPosY - defaultItemHeight - defaultSpacer;//guiItems[0]->posY;
}

// hides all previous panels items and makes a new panel for subsequent gui items to be added.
// only 1 panel should be visible at any time.
// panel items are positioned at the defaultItem positions and sizes (same as first panel).
// TODO: positional panels 
int ofxTouchGUI::newPanel() {
    
    hideAllPanels();
    moveTo(defaultItemPosX, defaultItemPosY);
    setItemSize(defaultItemWidth, defaultItemHeight);
    TGPanel* panel = new TGPanel();
    panels.push_back(panel);
    
    activePanel = panels.size()-1;
    return panels.size()-1;
}

void ofxTouchGUI::hideAllPanels() {    
    for(int i = 0; i < panels.size(); i++) {
        for(int j = 0; j < panels[i]->panelGuiItems.size(); j++) {
            panels[i]->panelGuiItems[j]->hide();
        }
    }
}

void ofxTouchGUI::showPanel(int panelIndex) {
    if(panelIndex >= 0 && panelIndex <= panels.size()-1) {
        hideAllPanels();
        activePanel = panelIndex;
        for(int j = 0; j < panels[panelIndex]->panelGuiItems.size(); j++) {
            panels[panelIndex]->panelGuiItems[j]->show();
        }
    }
}

void ofxTouchGUI::showNextPanel() {
    activePanel++;
    if(activePanel >= panels.size()) activePanel = 0;
    showPanel(activePanel);
}

void ofxTouchGUI::showPreviousPanel() {
    activePanel--;
    if(activePanel < 0) activePanel = panels.size()-1;
    showPanel(activePanel);
}

// doesn't work
/*void ofxTouchGUI::previousColumn() {
    
    lastItemPosX = lastItemPosX + lastItemWidth + defaultColumnSpacer;
    lastItemPosY = defaultItemPosY - lastItemHeight - defaultSpacer;//guiItems[0]->posY;
}*/

void ofxTouchGUI::setAutoColumnMaxY(int maxY) {
    maxColumnY = maxY;
}

ofVec2f ofxTouchGUI::getFurthestItemPosition() {

    ofVec2f furthestItem;
    for(int i = 0; i < numGuiItems; i++) {
        float itemY = guiItems[i]->getItemPosY() + guiItems[i]->getItemHeight();
        float itemX = guiItems[i]->getItemPosX() + guiItems[i]->getItemWidth();
        if(itemY > furthestItem.y) furthestItem.y = itemY + defaultColumnSpacer;
        if(itemX > furthestItem.x) furthestItem.x = itemX + defaultColumnSpacer;
    }
    
    return furthestItem;
}


// UPDATE
//--------------------------------------------------------------
/*void ofxTouchGUI::update(){
    
    if(isFirstUpdate) {
        furthestItem = getFurthestItemPosition(); // used for scroller or background color
        // if we have a scroller with auto width/height (-1,-1) resize to width + height of window
        if(scrollEnabled) {
            if(scrollWidth == -1 && scrollHeight == -1) {
                scrollWidth = furthestItem.x;
                scrollHeight = furthestItem.y;
            }
        }
        // if we have a background colour with auto width/height (-1,-1) resize to width + height of window
        if(hasBackgroundColor) {
            if(bgWidth == -1 && bgHeight == -1) {
                bgWidth = furthestItem.x;
                bgHeight = furthestItem.y;
            }
        }
        isFirstUpdate = false;
    }
    
    // osc receiver
    if(oscReceiveEnabled) checkOSCReceiver();
}*/

// DRAW
//--------------------------------------------------------------
void ofxTouchGUI::draw(){

    // initial setup/update stuff
    if(isFirstUpdate) {
        furthestItem = getFurthestItemPosition(); // used for scroller or background color
        // if we have a scroller with auto width/height (-1,-1) resize to width + height of window
        if(scrollEnabled) {
            if(scrollWidth == -1 && scrollHeight == -1) {
                scrollWidth = furthestItem.x;
                scrollHeight = furthestItem.y;
            }
        }
        // if we have a background colour with auto width/height (-1,-1) resize to width + height of window
        if(hasBackgroundColor) {
            if(bgWidth == -1 && bgHeight == -1) {
                bgWidth = furthestItem.x;
                bgHeight = furthestItem.y;
            }
        }
        isFirstUpdate = false;
    }
    
    // osc receiver
    if(oscReceiveEnabled) checkOSCReceiver();
    
    // normal drawing
    if(!hidden) {
        
        ofPushMatrix();
        ofPushStyle();
        ofTranslate(windowPosition);
        ofSetColor(255);
        
        if(hasBackgroundColor) {
            ofSetColor(bg);
            ofRect(bgX, bgY, bgWidth, bgHeight);
        }
        
        ofSetColor(255);
        if(hasBackgroundImage) backgroundImage.draw(0, 0);
        
        // loop over list and draw 
        for(int i = 0; i < numGuiItems; i++) {            
            guiItems[i]->draw();
        }
        
        // drawing dropdown overlays in descending order
        for(int i = dropDownGuiItems.size()-1; i >= 0; i--) {
            dropDownGuiItems[i]->drawOverlay();
        }
        
        ofPopStyle();
        ofPopMatrix();         
    }
    
}

void ofxTouchGUI::drawText(string text, int posX, int posY) {
    
    guiFont.drawString(text, posX, posY);
}

void ofxTouchGUI::drawTitleText(string text, int posX, int posY) {
    
    guiFontLarge.drawString(text, posX, posY);
}

void ofxTouchGUI::setAutoDraw(bool allowAutoDraw){
    
    if(!isAutoDrawing && allowAutoDraw) {
        ofAddListener(ofEvents().draw, this, &ofxTouchGUI::aDraw);
        isAutoDrawing = true;
    } else if(isAutoDrawing) {
        ofRemoveListener(ofEvents().draw, this, &ofxTouchGUI::aDraw);
    }
}

// auto draw requires events args
void ofxTouchGUI::aDraw(ofEventArgs &e){
    draw();
}



// shows only the last activated panel
void ofxTouchGUI::show(){
    hidden = false;
    
    /*for(int i = 0; i < numGuiItems; i++) {
        guiItems[i]->show();
    }*/
    showPanel(activePanel);
}

// hides everything (including all panels)
void ofxTouchGUI::hide(){
    hidden = true;
    
    /*for(int i = 0; i < numGuiItems; i++) {
        guiItems[i]->hide();
    }*/
    hideAllPanels();
}

void ofxTouchGUI::toggleDisplay(){
    
    (hidden) ? show() : hide();
}

bool ofxTouchGUI::isHidden() {
    return hidden;
}




// CREATE UI ITEMS
//--------------------------------------------------------------
ofxTouchGUISlider* ofxTouchGUI::addSlider(string sliderLabel, float *val, float min, float max, int posX, int posY, int width, int height){

    ofxTouchGUISlider* tgs = new ofxTouchGUISlider();
    tgs->type = SLIDER_TYPE;
    //tgs->itemId = SLIDER_TYPE + ofToString(numGuiItems);
    tgs->setValues(val, min, max);
    checkItemPosSize(posX, posY, width, height);
    tgs->setDisplay(sliderLabel, posX, posY, width, height);
    //tgs->enable(useMouse);
    if(hasFont) tgs->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    
    guiItems.push_back(tgs);
    panels.back()->panelGuiItems.push_back(tgs);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgs->enableSendOSC(oscSender);
    
    saveControl(SLIDER_TYPE, sliderLabel, val);
 
    return tgs; // return object to add listeners, etc.
    
}

ofxTouchGUISlider* ofxTouchGUI::addSlider(string sliderLabel, int *val, int min, int max, int posX, int posY, int width, int height){
    
    ofxTouchGUISlider* tgs = new ofxTouchGUISlider();
    tgs->type = SLIDER_TYPE;
    //tgs->itemId = SLIDER_TYPE + ofToString(numGuiItems);
    tgs->setValues(val, min, max);
    checkItemPosSize(posX, posY, width, height);
    tgs->setDisplay(sliderLabel, posX, posY, width, height);
    //tgs->enable(useMouse);
    if(hasFont) tgs->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    
    guiItems.push_back(tgs);
    panels.back()->panelGuiItems.push_back(tgs);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgs->enableSendOSC(oscSender);
    
    saveControl(SLIDER_TYPE, sliderLabel, val);

    return tgs; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addTitleText(string textLabel, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    //tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    tgt->formatText(true); // true = use title text
    
    // text height is different from passed in height- may be larger, so need to update lastItemHeight
    if(tgt->getItemHeight() > height) lastItemHeight = tgt->getItemHeight();

    guiItems.push_back(tgt);
    panels.back()->panelGuiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    //if(oscSendEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addText(string textLabel, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    //tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    tgt->formatText(false); // true = use title text
    
    
    // text height is different from passed in height- may be larger, so need to update lastItemHeight
    if(tgt->getItemHeight() > height) lastItemHeight = tgt->getItemHeight();

    guiItems.push_back(tgt);
    panels.back()->panelGuiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    //if(oscSendEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, string *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    
    //tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    tgt->setValue(val); // add value after fonts are set to avoid text offsets
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    panels.back()->panelGuiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // this does not connect to OSC.
    //if(oscSendEnabled) tgt->enableSendOSC(oscSender);
    
    // save controller if doesn't already exist, if it does overwrite the passed in value with the saved xml value
    //saveControl(TOGGLE_TYPE, toggleLabel, toggleVal);
    setVariable(textLabel, val); // using the 'setVariable' function to save value
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, float *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->setValue(val);
    //tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    panels.back()->panelGuiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // this does not connect to OSC.
    //if(oscSendEnabled) tgt->enableSendOSC(oscSender);
    
    // save controller if doesn't already exist, if it does overwrite the passed in value with the saved xml value
    //saveControl(TOGGLE_TYPE, toggleLabel, toggleVal);
    setVariable(textLabel, val); // using the 'setVariable' function to save value
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, int *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->setValue(val);
    //tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    panels.back()->panelGuiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // this does not connect to OSC.
    //if(oscSendEnabled) tgt->enableSendOSC(oscSender);
    
    // save controller if doesn't already exist, if it does overwrite the passed in value with the saved xml value
    //saveControl(TOGGLE_TYPE, toggleLabel, toggleVal);
    setVariable(textLabel, val); // using the 'setVariable' function to save value
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, bool *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->setValue(val);
    //tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    panels.back()->panelGuiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // this does not connect to OSC.
    //if(oscSendEnabled) tgt->enableSendOSC(oscSender);
    
    // save controller if doesn't already exist, if it does overwrite the passed in value with the saved xml value
    //saveControl(TOGGLE_TYPE, toggleLabel, toggleVal);
    setVariable(textLabel, val); // using the 'setVariable' function to save value
    
    return tgt; // return object to add listeners, etc.
}


ofxTouchGUIButton* ofxTouchGUI::addButton(string btnLabel, int posX, int posY, int width, int height){
    
    ofxTouchGUIButton* tgb = new ofxTouchGUIButton();
    tgb->type = BUTTON_TYPE;
    //tgb->itemId = BUTTON_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgb->setDisplay(btnLabel, posX, posY, width, height);
    //tgb->enable(useMouse);
    if(hasFont) tgb->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgb);
    panels.back()->panelGuiItems.push_back(tgb);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgb->enableSendOSC(oscSender);
    
    // buttons do not save to xml
    
    return tgb; // return object to add listeners, etc.
}

ofxTouchGUIToggleButton* ofxTouchGUI::addToggleButton(string toggleLabel, bool *toggleVal, int posX, int posY, int width, int height){
    
    ofxTouchGUIToggleButton* tgtb = new ofxTouchGUIToggleButton();
    tgtb->type = TOGGLE_TYPE;
    //tgtb->itemId = TOGGLE_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgtb->setDisplay(toggleLabel, posX, posY, width, height);
    tgtb->setValues(toggleVal);
    //tgtb->enable(useMouse);
    if(hasFont) tgtb->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgtb);
    panels.back()->panelGuiItems.push_back(tgtb);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgtb->enableSendOSC(oscSender);
    
    // save controller if doesn't already exist, if it does overwrite the passed in value with the saved xml value
    saveControl(TOGGLE_TYPE, toggleLabel, toggleVal);
        
    return tgtb; // return object to add listeners, etc.
}

ofxTouchGUIDropDown* ofxTouchGUI::addDropDown(string listLabel, int numValues, string* listValues, int posX, int posY, int width, int height){
    
    ofxTouchGUIDropDown* tgdd = addDropDown(listLabel, numValues, NULL, listValues, posX, posY, width, height);
    
    return tgdd; // return object to add listeners, etc.
}

ofxTouchGUIDropDown* ofxTouchGUI::addDropDown(string listLabel, int numValues, int* selectedId, string* listValues, int posX, int posY, int width, int height){
    
    ofxTouchGUIDropDown* tgdd = new ofxTouchGUIDropDown();
    tgdd->type = DROPDOWN_TYPE;
    //tgdd->itemId = DROPDOWN_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgdd->setDisplay(listLabel, posX, posY, width, height);
    (selectedId != NULL) ? tgdd->setValues(numValues, listValues, selectedId) : tgdd->setValues(numValues, listValues);
    //tgdd->enable(useMouse);
    if(hasFont) tgdd->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgdd);
    panels.back()->panelGuiItems.push_back(tgdd);
    dropDownGuiItems.push_back(tgdd);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgdd->enableSendOSC(oscSender);
    
    saveControl(DROPDOWN_TYPE, listLabel, tgdd->selectId); // problem???
    
    
    return tgdd; // return object to add listeners, etc.
}

// copied methods to allow vectors instead of arrays, need to make a template for these later instead
ofxTouchGUIDropDown* ofxTouchGUI::addDropDown(string listLabel, int numValues, vector<string> listValues, int posX, int posY, int width, int height){
    
    ofxTouchGUIDropDown* tgdd = addDropDown(listLabel, numValues, NULL, listValues, posX, posY, width, height);
    
    return tgdd; // return object to add listeners, etc.
}

ofxTouchGUIDropDown* ofxTouchGUI::addDropDown(string listLabel, int numValues, int* selectedId, vector<string> listValues, int posX, int posY, int width, int height){
    
    ofxTouchGUIDropDown* tgdd = new ofxTouchGUIDropDown();
    tgdd->type = DROPDOWN_TYPE;
    //tgdd->itemId = DROPDOWN_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgdd->setDisplay(listLabel, posX, posY, width, height);
    (selectedId != NULL) ? tgdd->setValues(numValues, listValues, selectedId) : tgdd->setValues(numValues, listValues);
    //tgdd->enable(useMouse);
    if(hasFont) tgdd->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgdd);
    panels.back()->panelGuiItems.push_back(tgdd);
    dropDownGuiItems.push_back(tgdd);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgdd->enableSendOSC(oscSender);
    
    saveControl(DROPDOWN_TYPE, listLabel, tgdd->selectId); // problem???
    
    
    return tgdd; // return object to add listeners, etc.
}

ofxTouchGUITextInput* ofxTouchGUI::addTextInput(string *placeHolderText, int posX, int posY, int width, int height) {
    
    ofxTouchGUITextInput* tgti = new ofxTouchGUITextInput();
    tgti->type = TEXTINPUT_TYPE;
    //tgti->itemId = TEXTINPUT_TYPE + ofToString(numGuiItems);
    checkItemPosSize(posX, posY, width, height);
    tgti->setDisplay(TEXTINPUT_TYPE + ofToString(numGuiItems), posX, posY, width, height); // inputs don't have display text
    tgti->defaultInput = *placeHolderText;
    //tgti->enable(useMouse);
    if(hasFont) tgti->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgti);
    panels.back()->panelGuiItems.push_back(tgti);
    numGuiItems = guiItems.size();
    
    // save controller if doesn't already exist, if it does overwrite the passed in value with the saved xml value
    saveControl(TEXTINPUT_TYPE, tgti->getLabel(), placeHolderText);
    
    // set the input after it's saved in case it's been saved over
    tgti->setInput(placeHolderText);
    
    return tgti; // return object to add listeners, etc.
}


ofxTouchGUIDataGraph* ofxTouchGUI::addDataGraph(string graphLabel, int maxValues, int posX, int posY, int width, int height) {
    
    ofxTouchGUIDataGraph* tgtg = new ofxTouchGUIDataGraph();
    tgtg->type = DATAGRAPH_TYPE;
    checkItemPosSize(posX, posY, width, height);
    tgtg->setDisplay(graphLabel, posX, posY, width, height);    
    //tgtg->disable(); // disable mouse, touch
    if(hasFont) tgtg->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    tgtg->setMaximumValues(maxValues);

    guiItems.push_back(tgtg);
    panels.back()->panelGuiItems.push_back(tgtg);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgtg->enableSendOSC(oscSender);
   
    return tgtg; 
}

// CONSTS 
// read only (can only be changed in xml) - good for config options. No osc.
template <typename T>
void ofxTouchGUI::setConstant(string constName, T *fixedConst){
    
    saveControl(CONST_TYPE, constName, fixedConst); // problem???
    constantCount++;
}

template <typename T>
void ofxTouchGUI::setConstant(string constName, T fixedConst){
    
    saveControl(CONST_TYPE, constName, &fixedConst); // problem???
    constantCount++;
}


// VARS 
// regular vars. No osc.
template <typename T>
void ofxTouchGUI::setVariable(string varName, T *regVar){
    
    saveControl(VAR_TYPE, varName, regVar); // problem???
    TGNameValuePair *nvp = new TGNameValuePair();
    nvp->name = varName;
    nvp->setValue(regVar);
    varItems.push_back(nvp);
    variableCount++;
}

// SORTING
//--------------------------------------------------------------
TGNameValuePair* ofxTouchGUI::getVarByLabel(string textLabel) {
    for(int i = 0; i < variableCount; i++) {
        if(textLabel == varItems[i]->name) {
            return varItems[i];
        }
    } 
    
    return NULL;
}

ofxTouchGUIBase* ofxTouchGUI::getItemByLabelAndType(string textLabel, string itemType) {
    
    for(int i = 0; i < numGuiItems; i++) {
        if(textLabel == guiItems[i]->getLabel() && itemType == guiItems[i]->type) {
            return guiItems[i];
        }
    } 

    return NULL;
}

ofxTouchGUIBase* ofxTouchGUI::getItemById(string itemId) {
    
    for(int i = 0; i < numGuiItems; i++) {
        if(itemId == guiItems[i]->itemId) {
            return guiItems[i];
        }
    } 
    
    return NULL;
}

ofxTouchGUIBase* ofxTouchGUI::getItemByOSCAddress(string oscAddress) {
    
    for(int i = 0; i < numGuiItems; i++) {
        if(oscAddress == guiItems[i]->fullOscAddress) {
            return guiItems[i];
        }
    }
    
    return NULL;
}


// XML SETTINGS
//--------------------------------------------------------------

// SAVE ALL SETTINGS
void ofxTouchGUI::saveSettings() {
    
    // loop through the xml and udpate the values from the gui
    int numSavedControllers = XML.getNumTags("control");
    
    for(int i = 0; i < numSavedControllers; i++){
        
        XML.pushTag("control", i);
        string controlLabel = XML.getValue("label", "", 0);
        string controlType = XML.getValue("type", "", 0); // get the type value or ""
        //string controlItemId = XML.getValue("itemid", "", 0);
        if(controlType == TOGGLE_TYPE) {
            
            //ofxTouchGUIBase* controller = getItemByLabel(controlLabel);
            //const ofxTouchGUIToggleButton* controller = (const ofxTouchGUIToggleButton*)getItemById(controlItemId);
            const ofxTouchGUIToggleButton* controller = (const ofxTouchGUIToggleButton*)getItemByLabelAndType(controlLabel,controlType);
            if(controller) {
                XML.setValue("value", *controller->toggleVal, 0);
            }
        }        
        else if(controlType == SLIDER_TYPE) {
            
            //const ofxTouchGUISlider* controller = (const ofxTouchGUISlider*)getItemById(controlItemId);
            const ofxTouchGUISlider* controller = (const ofxTouchGUISlider*)getItemByLabelAndType(controlLabel,controlType);
            if(controller) {
                if(controller->useInteger == true) {
                    XML.setValue("value", *controller->intVal, 0);
                }
                else {
                    XML.setValue("value", *controller->val, 0);
                }   
            }
            
        }
        else if(controlType == DROPDOWN_TYPE) {
            
            //const ofxTouchGUIDropDown* controller = (const ofxTouchGUIDropDown*)getItemById(controlItemId);
            const ofxTouchGUIDropDown* controller = (const ofxTouchGUIDropDown*)getItemByLabelAndType(controlLabel,controlType);
            if(controller) {
                XML.setValue("value", *controller->selectId, 0);
            }            
        }
        else if(controlType == TEXTINPUT_TYPE) {
            
            const ofxTouchGUITextInput* controller = (const ofxTouchGUITextInput*)getItemByLabelAndType(controlLabel,controlType);
            if(controller) {
                XML.setValue("value", *controller->input, 0);
            }            
        }
        else if(controlType == VAR_TYPE) {
            //NameValuePair nvp;
            //= {varName, (void*)regVar};
            //varItems.push_back(nvp);
            const TGNameValuePair* var = (const TGNameValuePair*)getVarByLabel(controlLabel);
            if(var) {
                
                if(var->type == _STRING) {
                    XML.setValue("value", *(string*)var->value, 0);
                } else if(var->type == _INT) {
                    XML.setValue("value", *(int*)var->value, 0);
                } else if(var->type == _FLOAT) {
                    XML.setValue("value", *(float*)var->value, 0);
                } else if(var->type == _BOOL) {
                    XML.setValue("value", *(bool*)var->value, 0);
                }
            }  
        }
        
        // note fixed vars/constants aren't saved, they are set once on creation
        // need to add more generic 'vars/addVar' property for a changing var - done!
        
        XML.popTag();
    }

    ofLog() << "TouchGUI: file saved " << saveToFile;
    XML.saveFile( saveToFile );
     
}


// SAVE INDIVIDUAL SETTINGS - saves the controller: T param must be int,float or bool
template <typename T>
bool ofxTouchGUI::saveControl(string currentType, string currentLabel, T* currentValue, bool overwriteXMLValue)
{
    
    bool isControlSaved = false;
    int numSavedControllers = XML.getNumTags("control");
    for(int i = 0; i < numSavedControllers; i++){
        
        // check by label & type instead of id, as the id changes when new controls are added. need to change/ remove id's all together maybe?
        // or create non incremental id's so they don't get recreated?
        XML.pushTag("control", i); 
        string controlLabel = XML.getValue("label", "", 0);
        //string controlItemId = XML.getValue("itemid", "", 0);
        string controlItemType = XML.getValue("type", "", 0);
        //if(currentItemId == controlItemId) {
        if(currentLabel == controlLabel && currentType == controlItemType) {
            isControlSaved = true;
            
            if(overwriteXMLValue) {
                // save over the xml values (this is false by default)
                XML.setValue("type", currentType, 0);
                XML.setValue("label", currentLabel, 0);
                XML.setValue("value", *currentValue, 0);
                cout << "overwriting value... " << *currentValue << " " << currentLabel << endl;
            } else {
                // overwrite the value with the saved xml value if not ignoring
               if(!ignoreXMLValues) *currentValue = XML.getValue("value", *currentValue, 0);
            }
            
            //cout << "val: " << *currentValue << endl;
            XML.popTag();
            break;
        } else {
            XML.popTag();
        }
    }
    
    //if control doesn't already exist in the settings file, create it
    if(!isControlSaved) {
        
        // create xml 'control' node
        XML.addTag("control");
        int numControlTags = (numSavedControllers > 0) ? numSavedControllers : 0; 
        XML.pushTag("control", numControlTags);    
        // required values
        XML.setValue("type", currentType, 0);
        //XML.setValue("itemid", currentItemId, 0);
        XML.setValue("label", currentLabel, 0);
        XML.setValue("value", *currentValue, 0);
        //XML.setAttribute("value", "type", "int", 0);    
        XML.popTag();
        
        // save to xml every new control
        XML.saveFile( saveToFile );
        return true;
    } 
    
    return false;    
}


// OSC
void ofxTouchGUI::setupSendOSC(string host, int port) {
    
    // setup osc host + port after settings have loaded
    if(!oscSendEnabled) {
        oscSender = new ofxOscSender();
        oscSender->setup( host, port );
        for(int i = 0; i < numGuiItems; i++) {
            if(guiItems[i]->type == SLIDER_TYPE || guiItems[i]->type == BUTTON_TYPE || guiItems[i]->type == TOGGLE_TYPE || guiItems[i]->type == DROPDOWN_TYPE) guiItems[i]->enableSendOSC(oscSender);
        } 
        oscSendEnabled = true;
    } else {
        oscSender->setup( host, port );
    }
    
    oscSendHostAddress = host;
    oscSendPort = port;
}

void ofxTouchGUI::disableSendOSC() {
    if(oscSendEnabled) {
        oscSendEnabled = false;
        delete oscSender;
    }
    
}


// generic osc message sending
void ofxTouchGUI::sendOSC(string address, float val) {
    
    if(oscSendEnabled) {
        msg.clear();
        msg.setAddress(address);//oscAddress + "/" + type + "/" + label); // eg. "/tg/slider/mythingy"
        msg.addFloatArg(val);
        oscSender->sendMessage( msg );
    }    
}

void ofxTouchGUI::sendOSC(string address, int val) {
    
    if(oscSendEnabled) {
        msg.clear();
        msg.setAddress(address);//oscAddress + "/" + type + "/" + label); // eg. "/tg/slider/mythingy"
        msg.addIntArg(val);
        oscSender->sendMessage( msg );
    }
}

void ofxTouchGUI::setupReceiveOSC(int port) {    
    
    // setup osc host + port after settings have loaded
    if(!oscReceiveEnabled) {
        
        oscReceiver = new ofxOscReceiver();
        oscReceiver->setup( port );
        /*for(int i = 0; i < numGuiItems; i++) {
         guiItems[i]->enableSendOSC(oscSender);
         }*/
        oscReceiveEnabled = true;
        
    } else {
        oscReceiver->setup( port );
    }
}

/*
 When receiving OSC messages, the values + actions will be fired for the matching gui item. Except... it will not resend back the OSC message by default, otherwise will get stuck in an inifinite OSC send/receive loop.
 */
void ofxTouchGUI::checkOSCReceiver() {
    
	while(oscReceiver->hasWaitingMessages()){
		ofxOscMessage m;
		oscReceiver->getNextMessage(&m);
        
        ofxTouchGUIBase* item = getItemByOSCAddress(m.getAddress());
        if(item != NULL) {
            
            float sendBackOSC = false; // change this if want to send back osc message to sender.
            for(int i = 0; i < m.getNumArgs(); i++){
                ofxOscArgType type = m.getArgType(0);
                if(item->type == SLIDER_TYPE) {
                    ofxTouchGUISlider* itemSlider = (ofxTouchGUISlider*) item;
                    if(type == OFXOSC_TYPE_INT32) {                        
                        itemSlider->doSliderIntAction(m.getArgAsInt32(i), sendBackOSC);
                    } else if(type == OFXOSC_TYPE_FLOAT) {
                        itemSlider->doSliderFloatAction(m.getArgAsFloat(i), sendBackOSC);
                    }
                } else if(item->type == BUTTON_TYPE) {
                    ofxTouchGUIButton* itemButton = (ofxTouchGUIButton*) item;
                    itemButton->doButtonAction(sendBackOSC);
                } else if(item->type == TOGGLE_TYPE) {
                    ofxTouchGUIToggleButton* itemToggle = (ofxTouchGUIToggleButton*) item;
                    //*itemToggle->toggleVal = m.getArgAsInt32(i);
                    itemToggle->doToggleAction(m.getArgAsInt32(i), sendBackOSC);
                } else if(item->type == DROPDOWN_TYPE) {
                    ofxTouchGUIDropDown* itemDropdown = (ofxTouchGUIDropDown*) item;
                    itemDropdown->doSelectAction(m.getArgAsInt32(i),sendBackOSC);
                }
            }
        } else {
            ofLogVerbose() << "No matching GUI item for " << m.getAddress();
        }
    }
}


// MOUSE/TOUCH
//--------------------------------------------------------------
void ofxTouchGUI::enableTouch(){
    disableMouse();
    useMouse = false;
    
    // register touch events
    ofRegisterTouchEvents(this);
}

//--------------------------------------------------------------
void ofxTouchGUI::disableTouch(){    
    ofUnregisterTouchEvents(this);
}

//--------------------------------------------------------------
void ofxTouchGUI::enableMouse(){
    disableTouch();
    useMouse = true;
    
    // register mouse events
    ofRegisterMouseEvents(this);
}

//--------------------------------------------------------------
void ofxTouchGUI::disableMouse(){    
    ofUnregisterMouseEvents(this);
}


// MOUSE EVENTS
//--------------------------------------------------------------
void ofxTouchGUI::mouseMoved(ofMouseEventArgs& args){    
}

//--------------------------------------------------------------
void ofxTouchGUI::mouseDragged(ofMouseEventArgs& args){
    // offset all through touches by windowPosition
    onMoved(args.x , args.y );
}

//--------------------------------------------------------------
void ofxTouchGUI::mousePressed(ofMouseEventArgs& args){
    // offset all through touches by windowPosition
    onDown(args.x , args.y );
}

//--------------------------------------------------------------
void ofxTouchGUI::mouseReleased(ofMouseEventArgs& args){
    // offset all through touches by windowPosition
    onUp(args.x , args.y );
}

// TOUCH
//--------------------------------------------------------------
void ofxTouchGUI::touchDown(ofTouchEventArgs &touch){
    // offset all through touches by windowPosition
    onDown(touch.x , touch.y );
}

//--------------------------------------------------------------
void ofxTouchGUI::touchMoved(ofTouchEventArgs &touch){
    // offset all through touches by windowPosition
    onMoved(touch.x, touch.y );
}

//--------------------------------------------------------------
void ofxTouchGUI::touchUp(ofTouchEventArgs &touch){
    // offset all through touches by windowPosition
    onUp(touch.x , touch.y );
}

//--------------------------------------------------------------
void ofxTouchGUI::touchDoubleTap(ofTouchEventArgs &touch){    
}

//--------------------------------------------------------------
void ofxTouchGUI::touchCancelled(ofTouchEventArgs& args){    
}

// TOUCH/MOUSE BINDED
//--------------------------------------------------------------
void ofxTouchGUI::onMoved(float x, float y){
    
    if(scrollEnabled) {
        if(isScrolling) {
            float maxScrollY = maxColumnY-scrollHeight;
            if(maxScrollY < 0) windowPosition.y = ofClamp(windowPosition.y + (y - startScrollY), maxScrollY, 0);
            startScrollY = y;
        }
    }
    
    float dx = x - windowPosition.x;
    float dy = y - windowPosition.y;
    for(int i = 0; i < numGuiItems; i++) {
        if(guiItems[i]->onMoved(dx, dy));// return; // nah
    }    
}

void ofxTouchGUI::onDown(float x, float y){
    
    float dx = x - windowPosition.x;
    float dy = y - windowPosition.y;
    for(int i = 0; i < numGuiItems; i++) {
        if(guiItems[i]->onDown(dx, dy)) return;
    }
    
    // cannot start scrolling when touching another interactive gui item
    if(scrollEnabled) {
        if(hitTest(x,y)) {
            isScrolling = true;
            startScrollY = y;
        }
    }
}

void ofxTouchGUI::onUp(float x, float y){
    
    if(scrollEnabled) {
        if(isScrolling) isScrolling = false;
    }
    
    float dx = x - windowPosition.x;
    float dy = y - windowPosition.y;
    for(int i = 0; i < numGuiItems; i++) {
        if(guiItems[i]->onUp(dx, dy)) return;
    }
}

bool ofxTouchGUI::hitTest(float x, float y) {
    
    return x >= windowPosition.x && x <= windowPosition.x + scrollWidth && y >= windowPosition.y && y <= windowPosition.y + scrollHeight;
}



// TEMPLATES
// saving controls
template bool ofxTouchGUI::saveControl<bool>(string currentType, string currentLabel, bool*, bool overwriteXMLValue);
template bool ofxTouchGUI::saveControl<int>(string currentType, string currentLabel, int*, bool overwriteXMLValue);
template bool ofxTouchGUI::saveControl<float>(string currentType, string currentLabel, float*, bool overwriteXMLValue);
template bool ofxTouchGUI::saveControl<string>(string currentType, string currentLabel, string*, bool overwriteXMLValue);

// setting const 
template void ofxTouchGUI::setConstant<bool>(string constName, bool*);
template void ofxTouchGUI::setConstant<int>(string constName, int*);
template void ofxTouchGUI::setConstant<float>(string constName, float*);
template void ofxTouchGUI::setConstant<string>(string constName, string*);
template void ofxTouchGUI::setConstant<bool>(string constName, bool);
template void ofxTouchGUI::setConstant<int>(string constName, int);
template void ofxTouchGUI::setConstant<float>(string constName, float);
template void ofxTouchGUI::setConstant<string>(string constName, string);

// setting var 
template void ofxTouchGUI::setVariable<bool>(string varName, bool*);
template void ofxTouchGUI::setVariable<int>(string varName, int*);
template void ofxTouchGUI::setVariable<float>(string varName, float*);
template void ofxTouchGUI::setVariable<string>(string varName, string*);

// displaying var


