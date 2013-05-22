#include "ofxTouchGUI.h"


ofxTouchGUI::ofxTouchGUI(){
	
    // init props
    numGuiItems = 0;
    hasFont = false;
    hasBackground = false;
    useMouse = false;
    settingsLoaded = false;
    isAutoDrawing = false;
    isHidden = false;
    oscEnabled = false;
    constantCount= 0;
    variableCount= 0;
    defaultPosX = 20;
    defaultPosY = 20;
    defaultColumn = 1;
    defaultItemWidth = 200;
    defaultItemHeight = 25;
    lastItemPosX = defaultPosX;
    lastItemPosY = defaultPosY;
    lastItemWidth = defaultItemWidth;
    lastItemHeight = defaultItemHeight;
    defaultSpacer = 5;
    defaultSaveToFile = "tg_settings.xml";
}

ofxTouchGUI::~ofxTouchGUI(){
    
}



void ofxTouchGUI::resetDefaultValues(){
    
    for(int i = 0; i < numGuiItems; i++) {
        guiItems[i]->resetDefaultValue();
    }
    
    cout << "Resetting defaults" << endl;
}

void ofxTouchGUI::loadSettings(string saveToFile, bool loadDefaultFont, bool useMouse) {
    
    this->saveToFile = saveToFile;
    
    #ifdef TARGET_OF_IPHONE
        this->saveToFile = ofxiPhoneGetDocumentsDirectory() + saveToFile;
    #endif
    
    // load xml from public itunes directory
    if( XML.loadFile(this->saveToFile) ){
        settingsLoaded = true;
    } else if(XML.loadFile(defaultSaveToFile)) {
        settingsLoaded = true;
        //this->saveToFile = defaultSaveToFile;
    } else {
        printf("\nNO XML file to load");
        //this->saveToFile = defaultSaveToFile;
        saveSettings();
    }
    
    // load the default font
    if(loadDefaultFont) loadFont("stan0755.ttf", 6, 6, false);
    
    // touch controlled or mouse controlled?
    this->useMouse = useMouse;
}


// STYLING
//--------------------------------------------------------------
void ofxTouchGUI::loadBackground(string imgPath){	
    
    hasBackground = true;
    background.loadImage(imgPath); 

}

void ofxTouchGUI::setBackgroundColor(ofColor bg, int bgX, int bgY, int bgWidth, int bgHeight) {
    
    hasBackgroundColor = true;
    this->bg = bg;
    this->bgX = bgX;
    this->bgY = bgY;
    this->bgWidth = bgWidth;
    this->bgHeight = bgHeight;
    
}


void ofxTouchGUI::loadFont(string fontPath, int fontSize, int fontSizeLarge, bool antialiased){	
    
    hasFont = true;
    guiFont.loadFont(fontPath,fontSize,antialiased,true);
    guiFont.setLineHeight(int(fontSize * 2)); // not sure about this?
    guiFontLarge.loadFont(fontPath,fontSizeLarge,antialiased,true);
    guiFontLarge.setLineHeight(int(fontSizeLarge * 2 * .8));
    
    this->fontSize = fontSize; // used to determine text offsetX for gui elements
    this->fontSizeLarge = fontSizeLarge; // used to determine text offsetX
}

void ofxTouchGUI::loadFonts(string fontPathSmall, string fontPathLarge, int fontSizeSmall, int fontSizeLarge, bool antialiasedSmall, bool antialisedLarge){	
    
    hasFont = true;
    guiFont.loadFont(fontPathSmall,fontSizeSmall,antialiasedSmall,true);
    guiFont.setLineHeight(int(fontSizeSmall * 2)); // not sure about this?
    guiFontLarge.loadFont(fontPathLarge,fontSizeLarge,antialisedLarge,true);
    guiFontLarge.setLineHeight(int(fontSizeLarge * 2 * .8));
    
    this->fontSize = fontSizeSmall; // used to determine text offsetX for gui elements
    this->fontSizeLarge = fontSizeLarge; // used to determine text offsetX
}

// DEFAULT SIZE/POSITIONING
void ofxTouchGUI::checkPosSize(int& posX, int& posY, int& width, int& height) {
    if(posX == -1) {
        ///posX = defaultColumn * defaultPosX; 
        posX = (numGuiItems == 0) ? defaultPosX : lastItemPosX;
    }
    if(posY == -1) {
        //posY = (numGuiItems == 0) ? defaultPosY : (defaultPosY + defaultSpacer) * numGuiItems;
        posY = (numGuiItems == 0) ? defaultPosY : lastItemPosY + lastItemHeight + defaultSpacer;  
        if(posY > ofGetHeight() - defaultItemHeight - defaultSpacer) {
            posY = defaultPosY;//(numGuiItems == 0) ? defaultPosY : guiItems[0]->posY; // align with top item
            posX = (numGuiItems == 0) ? defaultPosX : lastItemPosX + lastItemWidth + defaultPosX;
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

void ofxTouchGUI::nextColumn() {
    
    lastItemPosX = lastItemPosX + lastItemWidth + defaultPosX;
    lastItemPosY = defaultPosY - lastItemHeight - defaultSpacer;//guiItems[0]->posY;
}

// DRAW
//--------------------------------------------------------------
void ofxTouchGUI::draw(){
    
    
    
    if(!isHidden) {
        
        if(hasBackgroundColor) {
            ofSetColor(bg);
            ofRect(bgX, bgY, bgWidth, bgHeight);
        }
        ofSetColor(255, 255, 255);
        if(hasBackground) background.draw(0, 0);
        
        // loop over list and draw (unless it's a dropdown)
        ofxTouchGUIBase* topItem = 0; // one item can be on top (for dropdown menu)
        for(int i = 0; i < numGuiItems; i++) {

            if(guiItems[i]->itemActive) {
                topItem = guiItems[i];
            } else {
                guiItems[i]->draw();
            }
        }
        
        // draw the active/top item - only 1 (last one in the 
        if(topItem) topItem->draw();  
    }
    
}

void ofxTouchGUI::show(){
    //ofxTouchGUIBase::ignoreExternalEvents = false;
    isHidden = false;
    
    // not necessary - but adding for consistency
    for(int i = 0; i < numGuiItems; i++) {
        guiItems[i]->show();
    }
}

void ofxTouchGUI::hide(){
    //ofxTouchGUIBase::ignoreExternalEvents = true;
    isHidden = true;
    
    // not necessary - but adding for consistency
    for(int i = 0; i < numGuiItems; i++) {
        guiItems[i]->hide();
    }
}

void ofxTouchGUI::toggleDisplay(){
    
    (isHidden) ? show() : hide();
}

void ofxTouchGUI::autoDraw(bool allowAutoDraw){

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


// CREATE UI ITEMS
//--------------------------------------------------------------
ofxTouchGUISlider* ofxTouchGUI::addSlider(string sliderLabel, float *val, float min, float max, int posX, int posY, int width, int height){

    ofxTouchGUISlider* tgs = new ofxTouchGUISlider();
    tgs->type = SLIDER_TYPE;
    //tgs->itemId = SLIDER_TYPE + ofToString(numGuiItems);
    tgs->setValues(val, min, max);
    checkPosSize(posX, posY, width, height);
    tgs->setDisplay(sliderLabel, posX, posY, width, height);
    tgs->enable(useMouse);
    if(hasFont) tgs->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    
    guiItems.push_back(tgs);
    numGuiItems = guiItems.size();
    
    if(oscEnabled) tgs->enableSendOSC(oscSender);
    
    saveControl(SLIDER_TYPE, sliderLabel, val);
 
    return tgs; // return object to add listeners, etc.
    
}

ofxTouchGUISlider* ofxTouchGUI::addSlider(string sliderLabel, int *val, int min, int max, int posX, int posY, int width, int height){
    
    ofxTouchGUISlider* tgs = new ofxTouchGUISlider();
    tgs->type = SLIDER_TYPE;
    //tgs->itemId = SLIDER_TYPE + ofToString(numGuiItems);
    tgs->setValues(val, min, max);
    checkPosSize(posX, posY, width, height);
    tgs->setDisplay(sliderLabel, posX, posY, width, height);
    tgs->enable(useMouse);
    if(hasFont) tgs->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    
    guiItems.push_back(tgs);
    numGuiItems = guiItems.size();
    
    if(oscEnabled) tgs->enableSendOSC(oscSender);
    
    saveControl(SLIDER_TYPE, sliderLabel, val);

    return tgs; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addTitleText(string textLabel, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width);
    tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    tgt->formatText(true); // true = use title text
    
    guiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    if(oscEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addText(string textLabel, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    tgt->formatText(false); // true = use title text
    //checkPosSize(posX, posY, width, height);
    lastItemHeight = tgt->height;
    
    guiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    if(oscEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, string *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->setValue(val);
    tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    if(oscEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, float *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->setValue(val);
    tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    if(oscEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, int *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->setValue(val);
    tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    if(oscEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}

ofxTouchGUIText* ofxTouchGUI::addVarText(string textLabel, bool *val, int posX, int posY, int width, int height){
    
    ofxTouchGUIText* tgt = new ofxTouchGUIText();
    tgt->type = TEXT_TYPE;
    //tgt->itemId = TEXT_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgt->setDisplay(textLabel, posX, posY, width, height);
    tgt->setValue(val);
    tgt->enable(useMouse);
    if(hasFont) tgt->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    //tgt->formatText(false); // true = use title text
    
    guiItems.push_back(tgt);
    numGuiItems = guiItems.size();
    
    // currently this does not save to xml because it's not interactive, just displayed. may update in the future, but will cause problems with text formatting/auto wrapping so leaving out for now.
    // also this does not connect to OSC - same as above.
    if(oscEnabled) tgt->enableSendOSC(oscSender);
    
    return tgt; // return object to add listeners, etc.
}


ofxTouchGUIButton* ofxTouchGUI::addButton(string btnLabel, int posX, int posY, int width, int height){
    
    ofxTouchGUIButton* tgb = new ofxTouchGUIButton();
    tgb->type = BUTTON_TYPE;
    //tgb->itemId = BUTTON_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgb->setDisplay(btnLabel, posX, posY, width, height);
    tgb->enable(useMouse);
    if(hasFont) tgb->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgb);
    numGuiItems = guiItems.size();
    
    if(oscEnabled) tgb->enableSendOSC(oscSender);
    
    // buttons do not save to xml
    
    return tgb; // return object to add listeners, etc.
}

ofxTouchGUIToggleButton* ofxTouchGUI::addToggleButton(string toggleLabel, bool *toggleVal, int posX, int posY, int width, int height){
    
    ofxTouchGUIToggleButton* tgtb = new ofxTouchGUIToggleButton();
    tgtb->type = TOGGLE_TYPE;
    //tgtb->itemId = TOGGLE_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgtb->setDisplay(toggleLabel, posX, posY, width, height);
    tgtb->setValues(toggleVal);
    tgtb->enable(useMouse);
    if(hasFont) tgtb->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgtb);
    numGuiItems = guiItems.size();
    
    if(oscEnabled) tgtb->enableSendOSC(oscSender);
    
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
    checkPosSize(posX, posY, width, height);
    tgdd->setDisplay(listLabel, posX, posY, width, height);
    (selectedId != NULL) ? tgdd->setValues(numValues, listValues, selectedId) : tgdd->setValues(numValues, listValues);
    tgdd->enable(useMouse);
    if(hasFont) tgdd->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgdd);
    numGuiItems = guiItems.size();
    
    if(oscEnabled) tgdd->enableSendOSC(oscSender);
    
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
    checkPosSize(posX, posY, width, height);
    tgdd->setDisplay(listLabel, posX, posY, width, height);
    (selectedId != NULL) ? tgdd->setValues(numValues, listValues, selectedId) : tgdd->setValues(numValues, listValues);
    tgdd->enable(useMouse);
    if(hasFont) tgdd->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgdd);
    numGuiItems = guiItems.size();
    
    if(oscEnabled) tgdd->enableSendOSC(oscSender);
    
    saveControl(DROPDOWN_TYPE, listLabel, tgdd->selectId); // problem???
    
    
    return tgdd; // return object to add listeners, etc.
}

ofxTouchGUITextInput* ofxTouchGUI::addTextInput(string *placeHolderText, int posX, int posY, int width, int height) {
    
    ofxTouchGUITextInput* tgti = new ofxTouchGUITextInput();
    tgti->type = TEXTINPUT_TYPE;
    //tgti->itemId = TEXTINPUT_TYPE + ofToString(numGuiItems);
    checkPosSize(posX, posY, width, height);
    tgti->setDisplay(TEXTINPUT_TYPE + ofToString(numGuiItems), posX, posY, width, height); // inputs don't have display text
    tgti->defaultInput = *placeHolderText;
    tgti->enable(useMouse);
    if(hasFont) tgti->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);    
    
    guiItems.push_back(tgti);
    numGuiItems = guiItems.size();
    
    // save controller if doesn't already exist, if it does overwrite the passed in value with the saved xml value
    saveControl(TEXTINPUT_TYPE, tgti->label, placeHolderText);
    
    // set the input after it's saved in case it's been saved over
    tgti->setInput(placeHolderText);
    
    return tgti; // return object to add listeners, etc.
}


ofxTouchGUITimeGraph* ofxTouchGUI::addTimeGraph(string graphLabel, int maxValues, int posX, int posY, int width, int height) {
    
    ofxTouchGUITimeGraph* tgtg = new ofxTouchGUITimeGraph();
    tgtg->type = TIMEGRAPH_TYPE;
    checkPosSize(posX, posY, width, height);
    tgtg->setDisplay(graphLabel, posX, posY, width, height);    
    tgtg->disable(); // disable mouse, touch
    if(hasFont) tgtg->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    tgtg->setMaximumValues(maxValues);

    guiItems.push_back(tgtg);
    numGuiItems = guiItems.size();
    
    if(oscEnabled) tgtg->enableSendOSC(oscSender);
   
    return tgtg; 
}

// CONSTS 
// read only (can only be changed in xml) - good for config options
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
// regular vars
template <typename T>
void ofxTouchGUI::setVariable(string varName, T *regVar){
    
    saveControl(VAR_TYPE, varName, regVar); // problem???
    NameValuePair *nvp = new NameValuePair();
    nvp->name = varName;
    nvp->setValue(regVar);
    varItems.push_back(nvp);
    variableCount++;
}

// SORTING
//--------------------------------------------------------------
NameValuePair* ofxTouchGUI::getVarByLabel(string textLabel) {
    for(int i = 0; i < variableCount; i++) {
        if(textLabel == varItems[i]->name) {
            return varItems[i];
        }
    } 
    
    return NULL;
}

ofxTouchGUIBase* ofxTouchGUI::getItemByLabelAndType(string textLabel, string itemType) {
    
    for(int i = 0; i < numGuiItems; i++) {
        if(textLabel == guiItems[i]->label && itemType == guiItems[i]->type) {
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
            const NameValuePair* var = (const NameValuePair*)getVarByLabel(controlLabel);
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

    cout << "Saving file: " << saveToFile << endl;
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
                // overwrite the value with the saved xml value
               *currentValue = XML.getValue("value", *currentValue, 0); 
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
        
        return true;
    } 
    
    return false;    
}


// OSC
void ofxTouchGUI::setupSendOSC(string host, int port) {
    
    // setup osc host + port after settings have loaded
    if(!oscEnabled) {
        oscSender = new ofxOscSender();
        oscSender->setup( host, port );
        for(int i = 0; i < numGuiItems; i++) {
            guiItems[i]->enableSendOSC(oscSender);
        } 
        oscEnabled = true;
    } else {
        oscSender->setup( host, port );
    }
    
}

void ofxTouchGUI::disableSendOSC() {
    if(oscEnabled) {
        oscEnabled = false;
        delete oscSender;
    }
    
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

