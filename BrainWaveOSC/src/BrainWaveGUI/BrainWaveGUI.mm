#include "BrainWaveGUI.h"



BrainWaveGUI::BrainWaveGUI(){
}

BrainWaveGUI::~BrainWaveGUI(){
    
}


EegTimeGraph* BrainWaveGUI::addCustomTimeGraph(string graphLabel, int maxValues, int posX, int posY, int width, int height) {
    
    EegTimeGraph* tgtg = new EegTimeGraph();
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

