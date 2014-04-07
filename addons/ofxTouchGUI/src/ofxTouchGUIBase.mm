#include "ofxTouchGUIBase.h"
#include "ofMain.h"


//string ofxTouchGUIBase::oscAddress = "/tg"; // all osc messages will start with "/tg" by default.

ofxTouchGUIBase::ofxTouchGUIBase(){

    // INIT PROPS
    label = "";
    posX = 0;
    posY = 0;
    width = 100;
    height = 20;    
    textOffsetX = 10;
    textOffsetY = int(textOffsetX / 2);
    hasFont = false;
    guiFont = NULL;
    guiFontLarge = NULL;
    type = "";
    itemId = "";
    itemActive = false; 
    isPressed = false;
    //ofxTouchGUIBase::ignoreExternalEvents = false; // static now
    hidden = false;
    isInteractive = false;
    
    //setup opengl
    colorsArr = new float[16]; // rgba * 4 corners : background rect
    colorsArrActive = new float[16]; // active or hover state
    vertexArr = new float[8];  // 4 corners bg
    vertexArrActive = new float[8]; //4 corners 2nd box (active)
    
    
    // DEFAULT BACKGROUND CLRS: GRADIENT GRAY 75%
    bgClrTL = ofColor(180,180,180,255); //rgba
    bgClrTR = ofColor(120,120,120,255); //rgba
    bgClrBL = ofColor(180,180,180,255); //rgba
    bgClrBR = ofColor(120,120,120,255); //rgba    
    
    // DEFAULT FOREGROUND CLRS: SOLID BLACK 75%
    activeClrTL = ofColor(40,40,40,255); //rgba
    activeClrTR = ofColor(40,40,40,255); //rgba
    activeClrBL = ofColor(40,40,40,255); //rgba
    activeClrBR = ofColor(40,40,40,255); //rgba    
    
    // DEFAULT FONT COLORS: BLACK/WHITE
    textColourDark = ofColor(0,0,0,255);
    textColourLight = ofColor(255,255,255,255);
    textColour = textColourLight;
    
    //enableTouch();
    
    oscEnabled = false;
    fullOscAddress = "";
}

ofxTouchGUIBase::~ofxTouchGUIBase(){
    if(vertexArr != NULL){ delete []vertexArr; vertexArr = NULL; }
    if(colorsArr != NULL){ delete []colorsArr; colorsArr = NULL; }
    if(colorsArrActive != NULL){ delete []colorsArrActive; colorsArrActive = NULL; }
    if(vertexArrActive != NULL){ delete []vertexArrActive; vertexArrActive = NULL; }
}

void ofxTouchGUIBase::resetDefaultValue() {
    
}



// ENABLE/DISABLE FOR TOUCH OR MOUSE
//--------------------------------------------------------------
/*void ofxTouchGUIBase::enable(bool useMouse) {
    
    (useMouse) ? enableMouse() : enableTouch();
}

void ofxTouchGUIBase::disable() {
    
    if(isMouseEnabled) disableMouse();
    if(isTouchEnabled) disableTouch();
}*/

// showing allows drawing + events
void ofxTouchGUIBase::show(bool activateSingleItem){
    if(activateSingleItem) itemActive = true;
    hidden = false;
}

// hiding disables drawing + events
void ofxTouchGUIBase::hide(){
    hidden = true;
}

bool ofxTouchGUIBase::isHidden() {
    return hidden;
}

// fix this: disableMouse
//--------------------------------------------------------------
/*void ofxTouchGUIBase::enableTouch(){
    
    if(isMouseEnabled) disableMouse();
    isTouchEnabled = true;
    
    // register touch events
    ofRegisterTouchEvents(this);
    
    // register other app events - eg. setup, update, draw
    //ofAddListener(ofEvents.update, this, &ofxTouchGUI::update);
    //ofAddListener(ofEvents.draw, this, &ofxTouchGUI::draw);
}

//--------------------------------------------------------------
void ofxTouchGUIBase::disableTouch(){
    
    isTouchEnabled = false;
    ofUnregisterTouchEvents(this);

    //ofRemoveListener(ofEvents.update, this, &ofxTouchGUI::update);
    //ofRemoveListener(ofEvents.draw, this, &ofxTouchGUI::draw);
}

//--------------------------------------------------------------
void ofxTouchGUIBase::enableMouse(){
    
    if(isTouchEnabled) disableTouch();
    isMouseEnabled = true;
    
    // register mouse events
    ofRegisterMouseEvents(this); 
}

//--------------------------------------------------------------
void ofxTouchGUIBase::disableMouse(){
    
    isMouseEnabled = false;
    ofUnregisterMouseEvents(this);
}*/



//--------------------------------------------------------------
int ofxTouchGUIBase::getItemPosX() {
    return posX;
}
int ofxTouchGUIBase::getItemPosY() {
    return posY;
}
int ofxTouchGUIBase::getItemWidth() {
    return width;
}
int ofxTouchGUIBase::getItemHeight() {
    return height;
}

string ofxTouchGUIBase::getLabel() {
    return label;
}

void ofxTouchGUIBase::setDisplay(string label, int posX, int posY, int width) {

    setDisplay(label, posX, posY, width, 35); // default height is 35?
}

void ofxTouchGUIBase::setDisplay(string label, int posX, int posY, int width, int height) {
    
	this->label = label;
    this->posX = posX;
    this->posY = posY;
    this->width = width;
    this->height = height;
    
    updateGLArrays();

}

//--------------------------------------------------------------
void ofxTouchGUIBase::assignFonts(ofTrueTypeFont *guiFont, int fontSize, ofTrueTypeFont *guiFontLarge, int fontSizeLarge) {
    
	hasFont = true;    
    this->guiFont = guiFont; //ptr   
    this->guiFontLarge = guiFontLarge; //ptr
    this->fontSize = fontSize;
    this->fontSizeLarge = fontSizeLarge;
    
    // automatically offset the text based on the font size
    textOffsetX = fontSize;
    textOffsetY = int(textOffsetX / 2);
}

    
//--------------------------------------------------------------
void ofxTouchGUIBase::draw(){    

}

/*
 void ofxTouchGUIBase::autoDraw(bool enableAutoDraw){    
 this->enableAutoDraw = enableAutoDraw;
 ofAddListener(ofEvents.draw, this, &ofxTouchGUIBase::draw); // add ofEventArgs &e to params for draw
 }
 */

void ofxTouchGUIBase::drawText(const string &text, int alignment){    
    
    //cout << text << endl;
    int fontWidth = (hasFont) ? guiFont->stringWidth(text) : (int)label.length() * 8; // trying to figure out how wide the default text is, magic number= 8px?
    int destY = int(textOffsetY + height * 0.5);
    int destX = (alignment == -1) ? 0 : (alignment == 0) ? textOffsetX : (alignment == 1) ? int(width * .5 - fontWidth * .5) : int(width - fontWidth - textOffsetX); //left,center,right (aligned)
    
    drawText(text, destX, destY);
}

void ofxTouchGUIBase::drawText(const string &text, int destX, int destY){ 
    
    if(hasFont) {
        guiFont->drawString(text, destX, destY );
    }
    else {
        ofDrawBitmapString(text, destX, destY );
    }
}

void ofxTouchGUIBase::drawLargeText(const string &text, int alignment){    
    
    int fontWidth = (hasFont) ? guiFontLarge->stringWidth(text) : (int)label.length() * 8; // trying to figure out how wide the default text is, magic number= 8px?
    int destY = int(textOffsetY + height * 0.5);
    int destX = (alignment == -1) ? 0 : (alignment == 0) ? textOffsetX : (alignment == 1) ? int(width * .5 - fontWidth * .5) : int(width - fontWidth - textOffsetX); //left,center,right (aligned)
    
    drawText(text, destX, destY);
}

void ofxTouchGUIBase::drawLargeText(const string &text, int destX, int destY){ 
    
    if(hasFont) {
        guiFontLarge->drawString(text, destX, destY );
    }
    else {
        ofDrawBitmapString(text, destX, destY );
    }
}

void ofxTouchGUIBase::drawGLRect(float *&vtxArray, float *&clrArray) {
    
    glVertexPointer(2, GL_FLOAT, 0, &vtxArray[0]); //GLint size, GLenum type, GLsizei stride, const GLvoid *pointer
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_FLOAT, 0, &clrArray[0]);
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); // number of vertexs/colours
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}




// TOUCH
//--------------------------------------------------------------
/*void ofxTouchGUIBase::touchDown(ofTouchEventArgs &touch){
    
     onDown(touch.x, touch.y);
}

//--------------------------------------------------------------
void ofxTouchGUIBase::touchMoved(ofTouchEventArgs &touch){
    
    onMoved(touch.x, touch.y);
}

//--------------------------------------------------------------
void ofxTouchGUIBase::touchUp(ofTouchEventArgs &touch){
    
    onUp(touch.x, touch.y);
}

//--------------------------------------------------------------
void ofxTouchGUIBase::touchDoubleTap(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofxTouchGUIBase::touchCancelled(ofTouchEventArgs& args){
    
}

// MOUSE
//--------------------------------------------------------------
void ofxTouchGUIBase::mouseMoved(ofMouseEventArgs& args){
    
}

//--------------------------------------------------------------
void ofxTouchGUIBase::mouseDragged(ofMouseEventArgs& args){
    
    onMoved(args.x, args.y);
}

//--------------------------------------------------------------
void ofxTouchGUIBase::mousePressed(ofMouseEventArgs& args){
    
    onDown(args.x, args.y);
}

//--------------------------------------------------------------
void ofxTouchGUIBase::mouseReleased(ofMouseEventArgs& args){
    
    onUp(args.x, args.y);
}*/



// TOUCH/MOUSE BINDED - to be overriden for different ui elements
//--------------------------------------------------------------
bool ofxTouchGUIBase::onMoved(float x, float y){
   
    // onMoved not used for most gui items - always returns false here. see slider for working implementation. 
    if(!isInteractive || hidden) return false;
    return false;
}

bool ofxTouchGUIBase::onDown(float x, float y){
    
    if(!isInteractive || hidden) return false;
    if(isPressed) return false;
    
    if(hitTest(x,y)) {
        isPressed = true;
        return true;
    }
    return false;
}

bool ofxTouchGUIBase::onUp(float x, float y){
    
    if(!isInteractive || hidden) return false;
    
    if(isPressed) {
        isPressed = false;
        return true;
    }
    
    return false;
}

bool ofxTouchGUIBase::getIsPressed() {
    return isPressed;
}

void ofxTouchGUIBase::setInteractive(bool interactive) {
    isInteractive = interactive;
}

bool ofxTouchGUIBase::hitTest(float x, float y) {

    //return posX >= x && posX <= x + width && posY >= y && posY <= y + height;
    return x >= posX && x <= posX + width && y >= posY && y <= posY + height;
}

bool ofxTouchGUIBase::hitTest(float x, float y, float w, float h) {
    
    return x >= posX && x <= posX + w && y >= posY && y <= posY + h;
}

//--------------------------------------------------------------
// STYLE COPYING (background clrs, active clrs, text clr)
void ofxTouchGUIBase::copyStyle(ofxTouchGUIBase* source) {
    
    setBackgroundClrs(source->bgClrTL, source->bgClrTR, source->bgClrBL, source->bgClrBR);
    setActiveClrs(source->activeClrTL, source->activeClrTR, source->activeClrBL, source->activeClrBR);
    setTextClr(source->textColour);
}

// CUSTOM COLORS
void ofxTouchGUIBase::setTextClr(ofColor clr) {
    textColour = clr;
}

void ofxTouchGUIBase::setBackgroundClrs(ofColor tl, ofColor tr, ofColor bl, ofColor br) {
    
    bgClrTL = tl; //rgba
    bgClrTR = tr; //rgba
    bgClrBL = bl; //rgba
    bgClrBR = br; //rgba  
    updateGLArrays();
}

void ofxTouchGUIBase::setBackgroundClrs(ofColor singleClr) {
    
    bgClrTL = singleClr; //rgba
    bgClrTR = singleClr; //rgba
    bgClrBL = singleClr; //rgba
    bgClrBR = singleClr; //rgba  
    updateGLArrays();
}

void ofxTouchGUIBase::setActiveClrs(ofColor tl, ofColor tr, ofColor bl, ofColor br) {
    
    activeClrTL = tl; //rgba
    activeClrTR = tr; //rgba
    activeClrBL = bl; //rgba
    activeClrBR = br; //rgba  
    updateGLArrays();
}

void ofxTouchGUIBase::setActiveClrs(ofColor singleClr) {
    
    activeClrTL = singleClr; //rgba
    activeClrTR = singleClr; //rgba
    activeClrBL = singleClr; //rgba
    activeClrBR = singleClr; //rgba  
    updateGLArrays();
}



// CUSTOM OFFSETS
//--------------------------------------------------------------
void ofxTouchGUIBase::setTextOffsets(int textOffsetX, int textOffsetY) {
    
    this->textOffsetX = textOffsetX;
    this->textOffsetY = textOffsetY;
}



// OPENGL - manually setting array values
//--------------------------------------------------------------
void ofxTouchGUIBase::updateGLArrays(){
    
    
    // POSITIONS
    vertexArr[0] = 0; // TL x
    vertexArr[1] = 0; // TL y   
    vertexArr[2] = width; // TR x
    vertexArr[3] = 0; // TR y
    vertexArr[4] = 0; // BL x
    vertexArr[5] = height; // BL y
    vertexArr[6] = width; // BR x
    vertexArr[7] = height; // BR y
    
    // 2nd rectangle: active area
    vertexArrActive[0] = 0; // TL x
    vertexArrActive[1] = 0; // TL y   
    vertexArrActive[2] = width; // TR x
    vertexArrActive[3] = 0; // TR y
    vertexArrActive[4] = 0; // BL x
    vertexArrActive[5] = height; // BL y
    vertexArrActive[6] = width; // BR x
    vertexArrActive[7] = height; // BR y
    
   
    // BACKGROUND
    // color 1: top left
    colorsArr[0] = bgClrTL.r /255.0f; // red
    colorsArr[1] = bgClrTL.g /255.0f; // green
    colorsArr[2] = bgClrTL.b /255.0f; // blue
    colorsArr[3] = bgClrTL.a /255.0f; // alpha
    
    // color 2: top right
    colorsArr[4] = bgClrTR.r /255.0f; // red
    colorsArr[5] = bgClrTR.g /255.0f; // green
    colorsArr[6] = bgClrTR.b /255.0f; // blue
    colorsArr[7] = bgClrTR.a /255.0f; // alpha
    
    // color 3: bottom left
    colorsArr[8] = bgClrBL.r /255.0f; // red
    colorsArr[9] = bgClrBL.g /255.0f; // green
    colorsArr[10] = bgClrBL.b /255.0f; // blue
    colorsArr[11] = bgClrBL.a /255.0f; // alpha
    
    // color 4: bottom right
    colorsArr[12] = bgClrBR.r /255.0f; // red
    colorsArr[13] = bgClrBR.g /255.0f; // green
    colorsArr[14] = bgClrBR.b /255.0f; // blue
    colorsArr[15] = bgClrBR.a /255.0f; // alpha
    

    // FOREEGROUND ACTIVE/HOVER
    // color 1: top left
    colorsArrActive[0] = activeClrTL.r /255.0f; // red
    colorsArrActive[1] = activeClrTL.g /255.0f; // green
    colorsArrActive[2] = activeClrTL.b /255.0f; // blue
    colorsArrActive[3] = activeClrTL.a /255.0f; // alpha
    
    // color 2: top right
    colorsArrActive[4] = activeClrTR.r /255.0f; // red
    colorsArrActive[5] = activeClrTR.g /255.0f; // green
    colorsArrActive[6] = activeClrTR.b /255.0f; // blue
    colorsArrActive[7] = activeClrTR.a /255.0f; // alpha
    
    // color 3: bottom left
    colorsArrActive[8] = activeClrBL.r /255.0f; // red
    colorsArrActive[9] = activeClrBL.g /255.0f; // green
    colorsArrActive[10] = activeClrBL.b /255.0f; // blue
    colorsArrActive[11] = activeClrBL.a /255.0f; // alpha
    
    // color 4: bottom right
    colorsArrActive[12] = activeClrBR.r /255.0f; // red
    colorsArrActive[13] = activeClrBR.g /255.0f; // green
    colorsArrActive[14] = activeClrBR.b /255.0f; // blue
    colorsArrActive[15] = activeClrBR.a /255.0f; // alpha
 
}


/*
 int Button::centerAlignX(string s, int destX)
 {
 return int(destX - (vagFont.stringWidth(s) * .5));
 }
 */


void ofxTouchGUIBase::enableSendOSC(ofxOscSender * oscSender) {
    
    // setup osc host + port after settings have loaded
    if(!oscEnabled) {
        
        // formats the gui label into an osc valid address
        // eg. "SLIDER X" becomes "/sliderx"
        string oscLabel = "";
        for(int i = 0; i < label.length(); i++){            
            // only letters or numbers are valid...
            if(isCharacter(label[i]) || isNumber(label[i])) oscLabel += label[i];
        }
        fullOscAddress = "/"+ ofToLower(oscLabel); // + type + "/" oscAddress +
        ofLogVerbose() << "OSC address for " + ofToString(label) + " = " + fullOscAddress;
        oscSenderRef = oscSender;
        oscEnabled = true;
    }
}

void ofxTouchGUIBase::disableSendOSC() {
    
    if(oscEnabled) {
        oscEnabled = false;
        delete oscSenderRef;
    }
}

void ofxTouchGUIBase::setOSCAddress(string address) {
    fullOscAddress = address;
}

void ofxTouchGUIBase::sendOSC(int val) {
    
    if(oscEnabled) {
        msg.clear();
        msg.setAddress(fullOscAddress); // eg. "/tg/slider/mythingy"
        msg.addIntArg(val); 
        oscSenderRef->sendMessage( msg ); 
    }    
}

void ofxTouchGUIBase::sendOSC(float val) {
    
    if(oscEnabled) {
        msg.clear();
        msg.setAddress(fullOscAddress);//oscAddress + "/" + label); // eg. "/tg/mythingy"
        msg.addFloatArg(val); 
        oscSenderRef->sendMessage( msg ); 
    }    
}

void ofxTouchGUIBase::sendOSC(string val) {
    
    if(oscEnabled) {
        msg.clear();
        msg.setAddress(fullOscAddress); // eg. "/tg/mythingy"
        msg.addStringArg(val); 
        oscSenderRef->sendMessage( msg ); 
    }    
}

bool ofxTouchGUIBase::isCharacter(const char Character)
{
	return ( (Character >= 'a' && Character <= 'z') || (Character >= 'A' && Character <= 'Z'));
	//Checks if a Character is a Valid A-Z, a-z Character, based on the ascii value
}
bool ofxTouchGUIBase::isNumber(const char Character)
{
	return ( Character >= '0' && Character <= '9');
	//Checks if a Character is a Valid 0-9 Number, based on the ascii value
}
