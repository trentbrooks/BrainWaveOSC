#include "BrainWaveGUI.h"



BrainWaveGUI::BrainWaveGUI(){
}

BrainWaveGUI::~BrainWaveGUI(){
    
}


EegTimeGraph* BrainWaveGUI::addCustomTimeGraph(string graphLabel, int maxValues, int posX, int posY, int width, int height) {
    
    EegTimeGraph* tgtg = new EegTimeGraph();
    tgtg->type = DATAGRAPH_TYPE;
    checkItemPosSize(posX, posY, width, height);
    tgtg->setDisplay(graphLabel, posX, posY, width, height);    
    tgtg->setInteractive(false); // disable mouse, touch
    if(hasFont) tgtg->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    tgtg->setMaximumValues(maxValues);

    guiItems.push_back(tgtg);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgtg->enableSendOSC(oscSender);
   
    return tgtg; 
}

EegFrequencyGraph* BrainWaveGUI::addCustomTimeFrequencyGraph(string graphLabel, int maxValues, int posX, int posY, int width, int height) {
    
    EegFrequencyGraph* tgtg = new EegFrequencyGraph();
    tgtg->type = DATAGRAPH_TYPE;
    checkItemPosSize(posX, posY, width, height);
    tgtg->setDisplay(graphLabel, posX, posY, width, height);
    tgtg->setInteractive(false); // disable mouse, touch
    if(hasFont) tgtg->assignFonts(&guiFont,fontSize, &guiFontLarge,fontSizeLarge);
    tgtg->setMaximumValues(maxValues);
    
    guiItems.push_back(tgtg);
    numGuiItems = guiItems.size();
    
    if(oscSendEnabled) tgtg->enableSendOSC(oscSender);
    
    return tgtg;
}

