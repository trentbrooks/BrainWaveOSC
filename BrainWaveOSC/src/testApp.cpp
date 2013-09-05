#include "testApp.h"


float goertzel_mag(int numSamples,int TARGET_FREQUENCY,int SAMPLING_RATE, float* data)
{
    int     k,i;
    float   floatnumSamples;
    float   omega,sine,cosine,coeff,q0,q1,q2,magnitude,real,imag;
    
    float   scalingFactor = numSamples / 2.0;
    
    floatnumSamples = (float) numSamples;
    k = (int) (0.5 + ((floatnumSamples * TARGET_FREQUENCY) / SAMPLING_RATE));
    omega = (2.0 * PI * k) / floatnumSamples;
    sine = sin(omega);
    cosine = cos(omega);
    coeff = 2.0 * cosine;
    q0=0;
    q1=0;
    q2=0;
    
    for(i=0; i<numSamples; i++)
    {
        q0 = coeff * q1 - q2 + data[i];
        q2 = q1;
        q1 = q0;
    }
    
    // calculate the real and imaginary results
    // scaling appropriately
    real = (q1 - q2 * cosine) / scalingFactor;
    imag = (q2 * sine) / scalingFactor;
    
    magnitude = sqrtf(real*real + imag*imag);
    return magnitude;
}


//--------------------------------------------------------------
void testApp::setup(){
    
    ofSetFrameRate(30);
    ofEnableAlphaBlending();
    ofSetLogLevel(OF_LOG_VERBOSE);
    
    // defaults
    timeElapsed = startTime = 0;
    playhead = 0;
    smallWindow = false;
    sendOscEveryFrame = true;
    EegTimeGraph::dynamicEegMax = 1;
    rawDataValue = 0;
    rawDataBuffer = "";
    playbackMode = false;
    isRecording = false;
    isPaused = false;
    
    allData.attention = 0;
	allData.meditation = 0;
	allData.signal = 200;
	allData.eegDelta = 0;
	allData.eegHighAlpha = 0;
	allData.eegHighBeta = 0;
	allData.eegLowAlpha = 0;
	allData.eegLowBeta = 0;
	allData.eegLowGamma = 0;
	allData.eegMidGamma = 0;
	allData.eegTheta = 0;
	allData.elapsed = 0;
    
    normaliseMaxToCurrentSet = false;
    
    
    // default device settings
    deviceName = "/dev/tty.BrainBand-DevB";
    deviceBaudRate = 57600;
    
    // osc settings
    host = "127.0.0.1"; // change via xml
    port = 4444; // change via xml
    
    setupGui();
    
    // setup thinkgear hardware using serial streamer or comms driver (osx only tested).
    tg.setup(deviceName, deviceBaudRate, TG_COMMS_DRIVER, 1);
    tg.addEventListener(this);
    
    if(smallWindow) {
        settings.hide();
    }
}

void testApp::setupGui() {
    // setup gui
    settings.loadSettings("settings.xml", false, true);
    settings.loadFonts("fonts/stan0755.ttf", "fonts/abel.ttf", 6, 20);
    
    settings.setConstant("device", &deviceName);
    settings.setConstant("baud", &deviceBaudRate);
    settings.setConstant("host", &host);
    settings.setConstant("port", &port);
    settings.setConstant("smallwindow", &smallWindow);
    settings.setupSendOSC(host, port);
    
    
    int smallHeight = 20;
    int bigHeight = 35;
    int bigWidth = 512 - 40;
    int smallWidth = 200;
    

    // add items
    settings.defaultItemWidth = bigWidth;
    settings.defaultItemHeight = bigHeight;
    settings.addTitleText("BRAINWAVE OSC 0.9", 18, 18);
    settings.addText("Device - " + deviceName + ". BaudRate - " + ofToString(deviceBaudRate), 20, 55);
    settings.addText("OSC - " + host + ":" + ofToString(port), 20, 70);
    settings.addText("----------------------------------------------------------------------------------------------", 20, 85);
    
    // poor signal, attention, meditation
    int graphWidth = 470;
    int graphHeight = 60;
    int graphItemHeight = graphHeight + 25;
    int graphOffsetX = 20;
    int graphOffsetY = 100;//120;
    int valuesToSave = graphWidth; // 1 for each pixel
    EegTimeGraph::maxDynamicEegValues = valuesToSave;
    for(int i = 0;i < valuesToSave; i++) {
        EegTimeGraph::updateDynamicEegMaxValues(1);
    }
    
    poorSignalText = settings.addVarText("Poor Signal 0-200", &allData.signal, graphOffsetX, graphOffsetY);
    /*poorSignalGraph = settings.addTimeGraph("Poor Signal 0-200", valuesToSave, graphOffsetX, graphOffsetY, graphWidth, graphHeight);
    poorSignalGraph->setBackgroundClrs(ofColor(255,90));
    poorSignalGraph->setTextOffsets(0, -5);
    poorSignalGraph->setOscAddress("/signal");
    poorSignalGraph->setCustomRange(0, 200);*/
    attentionGraph = settings.addTimeGraph("Attention 0-100", valuesToSave, graphOffsetX, graphOffsetY+ 50, graphWidth, graphHeight);
    attentionGraph->setBackgroundClrs(ofColor(255,90));
    attentionGraph->setTextOffsets(0, -5);
    attentionGraph->setOscAddress("/attention");
    attentionGraph->setCustomRange(0, 100);
    meditationGraph= settings.addTimeGraph("Meditation 0-100", valuesToSave, graphOffsetX, graphOffsetY+ graphItemHeight + 50, graphWidth, graphHeight);
    meditationGraph->setBackgroundClrs(ofColor(255,90));
    meditationGraph->setTextOffsets(0, -5);
    meditationGraph->setOscAddress("/meditation");
    meditationGraph->setCustomRange(0, 100);
    
    int numSeconds = ceil(valuesToSave / ofGetFrameRate());// 5;
    int rawDataFreq = 512 * numSeconds;
    rawDataGraph= settings.addTimeGraph("Raw data -2048-2048", rawDataFreq, graphOffsetX, graphOffsetY+ (graphItemHeight*2) + 50, graphWidth, graphHeight);
    rawDataGraph->setTextOffsets(0, -5);
    rawDataGraph->setBackgroundClrs(ofColor(255,90));
    rawDataGraph->setTextOffsets(0, -5);
    rawDataGraph->setOscAddress("/raw");  
    rawDataGraph->setCustomRange(-2048, 2048);
    
    settings.defaultItemHeight = bigHeight;
    settings.defaultItemWidth = smallWidth;
    int lastX = settings.lastItemPosX;
    int lastY = settings.lastItemPosY;
    settings.addToggleButton("SEND RAW DATA WITH OSC", &tg.allowRawDataEvents, lastX, lastY + graphHeight + 10);
    
    settings.defaultItemHeight = smallHeight;
    settings.defaultItemWidth = bigWidth;
    
    // moving the settings position cursor
    settings.lastItemPosY = 390;//eegDeltaText->posY; // move the settings to start from here
    
    // reset graph max
    settings.addText("----------------------------------------------------------------------------------------------");    
    settings.defaultItemWidth = smallWidth;
    settings.defaultItemHeight = bigHeight;    
    ofxTouchGUIButton* resetMaxBtn = settings.addButton("RESET EEG GRAPH'S TO MAX VALUE");
    ofAddListener(resetMaxBtn->onChangedEvent, this, &testApp::onGuiChanged);
    lastX = settings.lastItemPosX;
    lastY = settings.lastItemPosY;
    //settings.addVarText("Max eeg graph value", &EegTimeGraph::dynamicEegMax, lastX + settings.defaultItemWidth + 20, lastY);
    settings.addToggleButton("USE GLOBAL EEG RANGES", &EegTimeGraph::useGlobalRanges, lastX + settings.defaultItemWidth + 20, lastY);
    settings.lastItemPosY = lastY;
    settings.lastItemPosX = lastX;
    settings.defaultItemHeight = smallHeight;
    settings.defaultItemWidth = bigWidth;
    
    // raw data osc
//    settings.addText("----------------------------------------------------------------------------------------------");    
//    settings.defaultItemHeight = bigHeight;
//    settings.defaultItemWidth = smallWidth;    
//    settings.addToggleButton("SEND RAW DATA WITH OSC", &tg.allowRawDataEvents);
//    lastX = settings.lastItemPosX;
//    lastY = settings.lastItemPosY;
//    /*rawDataText = settings.addVarText("Raw data value", &rawDataValue, lastX + settings.defaultItemWidth + 20, lastY);
//    settings.lastItemPosY = lastY;
//    settings.lastItemPosX = lastX;
//    rawDataText->setOscAddress("/raw");  */
//    settings.defaultItemHeight = smallHeight;
//    settings.defaultItemWidth = bigWidth;
    
    // playback mode
    settings.addText("----------------------------------------------------------------------------------------------");
    
    settings.defaultItemWidth = smallWidth;
    settings.defaultItemHeight = bigHeight;
    ofxTouchGUIToggleButton* playbackBn = settings.addToggleButton("PLAYBACK MODE (test.csv)", &playbackMode);
    ofAddListener(playbackBn->onChangedEvent, this, &testApp::onGuiChanged);
    lastX = settings.lastItemPosX;
    lastY = settings.lastItemPosY;
    //settings.addVarText("Playback frame", &playhead, lastX + settings.defaultItemWidth + 20, lastY);
    settings.addToggleButton("PAUSE PLAYBACK", &isPaused, lastX + settings.defaultItemWidth + 20, lastY);
    settings.lastItemPosY = lastY;
    settings.lastItemPosX = lastX;
    settings.defaultItemWidth = bigWidth;
    timeline = settings.addSlider("PLAYBACK TIMELINE", &playhead, 0, 1);
    settings.defaultItemHeight = smallHeight;
    settings.defaultItemWidth = bigWidth;
    
    // recording
    settings.addText("----------------------------------------------------------------------------------------------");
    settings.defaultItemHeight = bigHeight;
    settings.defaultItemWidth = bigWidth;
    settings.addText("Recording info:\nToggle ON to start recording data, toggle OFF to save .csv file to 'data/exports' folder. Filename will be the current date & time. Drag/drop on app or rename to test.csv to view in playback mode.");//, lastX + settings.defaultItemWidth + 20, lastY);
    settings.defaultItemWidth = smallWidth;
    ofxTouchGUIToggleButton* recordBn = settings.addToggleButton("RECORD TO CSV", &isRecording);
    ofAddListener(recordBn->onChangedEvent, this, &testApp::onGuiChanged);
    settings.defaultItemHeight = smallHeight;
    settings.defaultItemWidth = bigWidth;
    
    // last notes
    settings.addText("----------------------------------------------------------------------------------------------");
    settings.defaultItemHeight = bigHeight;
    settings.defaultItemWidth = bigWidth;
    settings.addText("Press 'spacebar' to minimise window (performance mode).");//, lastX + settings.defaultItemWidth + 20, lastY);
    
    // 8 bands
    graphWidth = bigWidth = 725;
    graphHeight = 60;
    graphItemHeight = graphHeight + 25;
    graphOffsetX = 512 + 20;
    graphOffsetY = 20;
    eegDeltaGraph= settings.addCustomTimeGraph("EEG delta", valuesToSave, graphOffsetX, graphOffsetY, graphWidth, graphHeight);
    eegDeltaGraph->setTextOffsets(0, -5);
    eegDeltaGraph->setOscAddress("/eegdelta");
    //eegDeltaGraph->setCustomRange(0, 1500000);
    eegThetaGraph= settings.addCustomTimeGraph("EEG theta", valuesToSave, graphOffsetX, graphOffsetY + graphItemHeight, graphWidth, graphHeight);
    eegThetaGraph->setTextOffsets(0, -5);
    eegThetaGraph->setOscAddress("/eegtheta");
    //eegThetaGraph->setCustomRange(0, 600000);
    eegLowAlphaGraph= settings.addCustomTimeGraph("EEG low alpha", valuesToSave, graphOffsetX, graphOffsetY + graphItemHeight * 2, graphWidth, graphHeight);
    eegLowAlphaGraph->setTextOffsets(0, -5);
    eegLowAlphaGraph->setOscAddress("/eeglowalpha");
    //eegLowAlphaGraph->setCustomRange(0, 75000);
    eegHighAlphaGraph= settings.addCustomTimeGraph("EEG high alpha", valuesToSave, graphOffsetX, graphOffsetY + graphItemHeight * 3, graphWidth, graphHeight);
    eegHighAlphaGraph->setTextOffsets(0, -5);
    eegHighAlphaGraph->setOscAddress("/eeghighalpha");
    //eegHighAlphaGraph->setCustomRange(0, 150000);
    eegLowBetaGraph= settings.addCustomTimeGraph("EEG low beta", valuesToSave, graphOffsetX, graphOffsetY + graphItemHeight * 4, graphWidth, graphHeight);
    eegLowBetaGraph->setTextOffsets(0, -5);
    eegLowBetaGraph->setOscAddress("/eeglowbeta");
    //eegLowBetaGraph->setCustomRange(0, 60000);
    eegHighBetaGraph= settings.addCustomTimeGraph("EEG high beta", valuesToSave, graphOffsetX, graphOffsetY + graphItemHeight * 5, graphWidth, graphHeight);
    eegHighBetaGraph->setTextOffsets(0, -5);
    eegHighBetaGraph->setOscAddress("/eeghighbeta");
    //eegHighBetaGraph->setCustomRange(0, 60000);
    eegLowGammaGraph= settings.addCustomTimeGraph("EEG low gamma", valuesToSave, graphOffsetX, graphOffsetY + graphItemHeight * 6, graphWidth, graphHeight);
    eegLowGammaGraph->setTextOffsets(0, -5);
    eegLowGammaGraph->setOscAddress("/eeglowgamma");
    //eegLowGammaGraph->setCustomRange(0, 300000);
    eegMidGammaGraph= settings.addCustomTimeGraph("EEG mid gamma", valuesToSave, graphOffsetX, graphOffsetY + graphItemHeight * 7, graphWidth, graphHeight);
    eegMidGammaGraph->setTextOffsets(0, -5);
    eegMidGammaGraph->setOscAddress("/eegmidgamma");
    //eegMidGammaGraph->setCustomRange(0, 300000);
    
    // number of high values to then average and use as the local maximum
    int samples = 500;
    /*eegDeltaGraph->enableMaxAveraging(samples);
    eegThetaGraph->enableMaxAveraging(samples);
    eegLowAlphaGraph->enableMaxAveraging(samples);
    eegHighAlphaGraph->enableMaxAveraging(samples);
    eegLowBetaGraph->enableMaxAveraging(samples);
    eegHighBetaGraph->enableMaxAveraging(samples);
    eegLowGammaGraph->enableMaxAveraging(samples);
    eegMidGammaGraph->enableMaxAveraging(samples);*/
    
    
    int freqValues = 9;
    graphHeight = 230;
    //graphItemHeight = graphHeight + 25;
    frequencyGraph= settings.addCustomTimeFrequencyGraph("EEG frequencies (normalised)", freqValues, graphOffsetX, graphOffsetY + graphItemHeight * 8, graphWidth, graphHeight);
    frequencyGraph->setBackgroundClrs(ofColor(255,90));
    frequencyGraph->setTextOffsets(0, -5);
    //frequencyGraph->setBackgroundClrs(ofColor(40,40,40,255));
    //frequencyGraph->graphFillClr = ofColor(180,180,180,255);
    //frequencyGraph->setTextClr(frequencyGraph->textColourLight);
    frequencyGraph->setCustomRange(0, 1.0);//200000);
    
    // save the 8 eeg bands
    eegSet.push_back(eegDeltaGraph);
    eegSet.push_back(eegThetaGraph);
    eegSet.push_back(eegLowAlphaGraph);
    eegSet.push_back(eegHighAlphaGraph);
    eegSet.push_back(eegLowBetaGraph);
    eegSet.push_back(eegHighBetaGraph);
    eegSet.push_back(eegLowGammaGraph);
    eegSet.push_back(eegMidGammaGraph);

}

void testApp::onGuiChanged(const void* sender, string &buttonLabel) {
    // could use the pointer to button that was pressed? eg.
    ofxTouchGUIButton * button = (ofxTouchGUIButton*)sender;
    cout << buttonLabel << " - " << button->getValue() << endl;
    
    // or just use the label as the identifier
    if(buttonLabel == "SAVE") {
        settings.saveSettings();
    }
    else if(buttonLabel == "RESET") {
        settings.resetDefaultValues();
    }
    else if(buttonLabel == "RESET EEG GRAPH'S TO MAX VALUE") {

        EegTimeGraph::dynamicEegMax = 1;
        for(int i = 0; i < eegSet.size(); i++) {
            eegSet[i]->eegMax = 1;
        }
        
        if(normaliseMaxToCurrentSet) {
            
            for(int i = 0; i < eegSet.size(); i++) {
                int j = eegSet[i]->savedValues.size() - 1; // last value
                //for(int j = 0; j < eegSet[i]->savedValues.size(); j++) {
                float value = eegSet[i]->savedValues[j];
                if(value > EegTimeGraph::dynamicEegMax) EegTimeGraph::dynamicEegMax = value; //global
                if(value > eegSet[i]->eegMax) eegSet[i]->eegMax = value; // local
                //}
            }
        } else {
            for(int i = 0; i < eegSet.size(); i++) {
                for(int j = 0; j < eegSet[i]->savedValues.size(); j++) {
                    float value = eegSet[i]->savedValues[j];
                    if(value > EegTimeGraph::dynamicEegMax) EegTimeGraph::dynamicEegMax = value; //global
                    if(value > eegSet[i]->eegMax) eegSet[i]->eegMax = value; // local
                }
            }
        }
        
    }
    else if(buttonLabel == "PLAYBACK MODE (test.csv)") {
        startTime = timeElapsed;
        rawDataBuffer = "";        
        allData.attention = 0;
        allData.meditation = 0;
        allData.signal = 200;
        allData.eegDelta = 0;
        allData.eegHighAlpha = 0;
        allData.eegHighBeta = 0;
        allData.eegLowAlpha = 0;
        allData.eegLowBeta = 0;
        allData.eegLowGamma = 0;
        allData.eegMidGamma = 0;
        allData.eegTheta = 0;
        allData.elapsed = 0;
        //EegTimeGraph::dynamicEegMaxValues.clear();
        
        if(playbackMode) {
            
            // close device            
            tg.close();
            tg.removeEventListener(this);
            tg.isReady = false;
            
            loadPlaybackFile("export/test.csv");
        } else {
            tg.addEventListener(this);
            tg.flush();//close();            
            
        }
        
        // reset all the graphs
        EegTimeGraph::dynamicEegMax = 1;
        //poorSignalGraph->reset();
        poorSignalText->setValue(&allData.signal);
        attentionGraph->reset();
        meditationGraph->reset();
        rawDataGraph->reset();
        frequencyGraph->reset();
        
        for(int i = 0; i < eegSet.size(); i++) {
            eegSet[i]->reset();
        }
        
        // set last values to 0
        attentionGraph->insertValue(0);
        meditationGraph->insertValue(0);
        
        eegDeltaGraph->insertValue(0);
        eegThetaGraph->insertValue(0);
        eegLowAlphaGraph->insertValue(0);
        eegHighAlphaGraph->insertValue(0);
        eegLowBetaGraph->insertValue(0);
        eegHighBetaGraph->insertValue(0);
        eegLowGammaGraph->insertValue(0);
        eegMidGammaGraph->insertValue(0);
    }
    else if(buttonLabel == "RECORD TO CSV") {
        
        startTime = timeElapsed;
        if(isRecording) {
            // start recording
            string filePath = "export/" + ofGetTimestampString() + ".csv";
            output.open(filePath,ofFile::WriteOnly);
            output << "Time elapsed,Signal,Attention,Meditation,EEG delta, EEG theta,EEG low alpha,EEG high alpha,EEG low beta,EEG high beta,EEG low gamma,EEG mid gamma,Raw\n";
            ofLog() << "saving file: " << filePath;
        } else {
            // end recording
            output.close();
            ofLog() << "finished saving!";
        }
    }
    
}

void testApp::loadPlaybackFile(string path) {

    ofLog() << "loading from file " << path;    
    rawDataValue = 0;
    playhead = 0;
    dataEntries.clear();
    ofFile loadedData;
    loadedData.open(path.c_str(),ofFile::ReadOnly);
    ofBuffer buf = loadedData.readToBuffer();
    vector<string> csvStringsPass1 = ofSplitString(buf.getText(), "\n");
    int entries = csvStringsPass1.size()-1;
    for (int i = 0; i < entries; i++) {
        
        // first row is just the labesl in the csv
        if( i > 0) {
            vector<string> csvStringsPass2 = ofSplitString(csvStringsPass1[i], ",");
            EegData data;
            data.elapsed = ofToFloat(csvStringsPass2[0]);
            data.signal = ofToFloat(csvStringsPass2[1]);
            data.attention = ofToFloat(csvStringsPass2[2]);
            data.meditation = ofToFloat(csvStringsPass2[3]);
            data.eegDelta = ofToFloat(csvStringsPass2[4]);
            data.eegTheta = ofToFloat(csvStringsPass2[5]);
            data.eegLowAlpha = ofToFloat(csvStringsPass2[6]);
            data.eegHighAlpha = ofToFloat(csvStringsPass2[7]);
            data.eegLowBeta = ofToFloat(csvStringsPass2[8]);
            data.eegHighBeta = ofToFloat(csvStringsPass2[9]);
            data.eegLowGamma = ofToFloat(csvStringsPass2[10]);
            data.eegMidGamma = ofToFloat(csvStringsPass2[11]);
            vector<string> rawDataAsStrings = ofSplitString(csvStringsPass2[12], "|");
            data.rawDataBufferValues.resize(rawDataAsStrings.size());
            for(int j = 0; j < rawDataAsStrings.size(); j++) data.rawDataBufferValues[j] = ofToFloat(rawDataAsStrings[j]);
            dataEntries.push_back(data);
        }
        
        
        
    }
    
    timeline->setRange(0, dataEntries.size()-1);
}

//--------------------------------------------------------------
void testApp::update(){
    //
    //+ "fps: " + ofToString(ofGetFrameRate())
    ofSetWindowTitle(ofToString((tg.isReady) ? "Connected" : (playbackMode) ? "Playback mode" : "Connecting... (" + ofToString(tg.attempts) + " attempts)"));
    timeElapsed = ofGetElapsedTimef();
    
    // find global max
    /*for(int i= 0; i < eegSet.size(); i++) {
        if(i == 0) globalMax = eegSet[i]->value;
        if(eegSet[i]->value > globalMax) globalMax = eegSet[i]->value;
    }*/
    
    if(!playbackMode) {
        tg.update();
        
        float totalActivity = allData.getTotalActivity();
        
        if(!isPaused && tg.isReady) {
            
            // live data feed
            //poorSignalGraph->insertValue(allData.signal);
            attentionGraph->insertValue(allData.attention);
            meditationGraph->insertValue(allData.meditation);
            
            eegDeltaGraph->insertValue(allData.eegDelta);
            eegThetaGraph->insertValue(allData.eegTheta);
            eegLowAlphaGraph->insertValue(allData.eegLowAlpha);
            eegHighAlphaGraph->insertValue(allData.eegHighAlpha);
            eegLowBetaGraph->insertValue(allData.eegLowBeta);
            eegHighBetaGraph->insertValue(allData.eegHighBeta);
            eegLowGammaGraph->insertValue(allData.eegLowGamma);
            eegMidGammaGraph->insertValue(allData.eegMidGamma);
            
            // global max
            // this is gonna look weird over time...
            // need to store it every frame
            //EegTimeGraph::dynamicEegMax = totalActivity;
            EegTimeGraph::updateDynamicEegMaxValues(totalActivity);
            
            // freq graph            
            frequencyGraph->insertValue(allData.eegDelta/totalActivity);
            frequencyGraph->insertValue(allData.eegTheta/totalActivity);
            frequencyGraph->insertValue(allData.eegLowAlpha/totalActivity);
            frequencyGraph->insertValue(allData.eegHighAlpha/totalActivity);
            frequencyGraph->insertValue(allData.eegLowBeta/totalActivity);
            frequencyGraph->insertValue(allData.eegHighBeta/totalActivity);
            frequencyGraph->insertValue(allData.eegLowGamma/totalActivity);
            frequencyGraph->insertValue(allData.eegMidGamma/totalActivity);
            frequencyGraph->insertValue(0);
        }
        
                
        // all values except raw are sent at 30fps
        // raw data is sent around 512x a second (not sent in plyback mode, see event listener)
        // sending whether tg is ready or not
        if(sendOscEveryFrame) {
            
            //poorSignalGraph->sendOSC(allData.signal);// poorsignal.value);
            settings.sendOSC("/signal", allData.signal);
            settings.sendOSC("/activity", totalActivity);
            attentionGraph->sendOSC(allData.attention);// attention.value);
            meditationGraph->sendOSC(allData.meditation);// meditation.value);            
            eegDeltaGraph->sendOSC(allData.eegDelta);
            eegThetaGraph->sendOSC(allData.eegTheta);
            eegLowAlphaGraph->sendOSC(allData.eegLowAlpha);
            eegHighAlphaGraph->sendOSC(allData.eegHighAlpha);
            eegLowBetaGraph->sendOSC(allData.eegLowBeta);
            eegHighBetaGraph->sendOSC(allData.eegHighBeta);
            eegLowGammaGraph->sendOSC(allData.eegLowGamma);
            eegMidGammaGraph->sendOSC(allData.eegMidGamma);            
            //eegDeltaText->sendOSC(eegDelta.value);
            /*eegThetaText->sendOSC(eegTheta.value);
             eegLowAlphaText->sendOSC(eegLowAlpha.value);
             eegHighAlphaText->sendOSC(eegHighAlpha.value);
             eegLowBetaText->sendOSC(eegLowBeta.value);
             eegHighBetaText->sendOSC(eegHighBeta.value);
             eegLowGammaText->sendOSC(eegLowGamma.value);
             eegMidGammaText->sendOSC(eegMidGamma.value);*/
        }

    } else {
        //tg.idle();
        // manually playback data from file
        if(dataEntries.size() && (!isPaused || timeline->isPressed)) {
            
            float totalActivity = dataEntries[playhead].eegDelta + dataEntries[playhead].eegTheta + dataEntries[playhead].eegLowAlpha + dataEntries[playhead].eegHighAlpha + dataEntries[playhead].eegLowBeta + dataEntries[playhead].eegHighBeta + dataEntries[playhead].eegLowGamma + dataEntries[playhead].eegMidGamma;
            
            //poorSignalGraph->insertValue(dataEntries[playhead].signal);
            allData.signal = dataEntries[playhead].signal;
            attentionGraph->insertValue(dataEntries[playhead].attention);
            meditationGraph->insertValue(dataEntries[playhead].meditation);
            
            eegDeltaGraph->insertValue(dataEntries[playhead].eegDelta);
            eegThetaGraph->insertValue(dataEntries[playhead].eegTheta);
            eegLowAlphaGraph->insertValue(dataEntries[playhead].eegLowAlpha);
            eegHighAlphaGraph->insertValue(dataEntries[playhead].eegHighAlpha);
            eegLowBetaGraph->insertValue(dataEntries[playhead].eegLowBeta);
            eegHighBetaGraph->insertValue(dataEntries[playhead].eegHighBeta);
            eegLowGammaGraph->insertValue(dataEntries[playhead].eegLowGamma);
            eegMidGammaGraph->insertValue(dataEntries[playhead].eegMidGamma);
            
            // freq graph
            frequencyGraph->insertValue(dataEntries[playhead].eegDelta/totalActivity);
            frequencyGraph->insertValue(dataEntries[playhead].eegTheta/totalActivity);
            frequencyGraph->insertValue(dataEntries[playhead].eegLowAlpha/totalActivity);
            frequencyGraph->insertValue(dataEntries[playhead].eegHighAlpha/totalActivity);
            frequencyGraph->insertValue(dataEntries[playhead].eegLowBeta/totalActivity);
            frequencyGraph->insertValue(dataEntries[playhead].eegHighBeta/totalActivity);
            frequencyGraph->insertValue(dataEntries[playhead].eegLowGamma/totalActivity);
            frequencyGraph->insertValue(dataEntries[playhead].eegMidGamma/totalActivity);
            frequencyGraph->insertValue(0);
            
            // global max
            // this is gonna look weird over time...
            // need to store it every frame
            EegTimeGraph::dynamicEegMax = totalActivity;
            EegTimeGraph::updateDynamicEegMaxValues(totalActivity);
            
            
            if(sendOscEveryFrame) {
                //poorSignalGraph->sendOSC(dataEntries[playhead].signal);// poorsignal.value);
                settings.sendOSC("/signal", dataEntries[playhead].signal);
                settings.sendOSC("/activity", totalActivity);
                attentionGraph->sendOSC(dataEntries[playhead].attention);// attention.value);
                meditationGraph->sendOSC(dataEntries[playhead].meditation);// meditation.value);                
                eegDeltaGraph->sendOSC(dataEntries[playhead].eegDelta);
                eegThetaGraph->sendOSC(dataEntries[playhead].eegTheta);
                eegLowAlphaGraph->sendOSC(dataEntries[playhead].eegLowAlpha);
                eegHighAlphaGraph->sendOSC(dataEntries[playhead].eegHighAlpha);
                eegLowBetaGraph->sendOSC(dataEntries[playhead].eegLowBeta);
                eegHighBetaGraph->sendOSC(dataEntries[playhead].eegHighBeta);
                eegLowGammaGraph->sendOSC(dataEntries[playhead].eegLowGamma);
                eegMidGammaGraph->sendOSC(dataEntries[playhead].eegMidGamma);
                
            }
            
            //poorsignal.set(dataEntries[playhead].signal, timeElapsed);
            //attention.set(dataEntries[playhead].attention, timeElapsed);
            //meditation.set(dataEntries[playhead].meditation, timeElapsed);
            /*eegTheta.set(dataEntries[playhead].eegTheta, timeElapsed);
            eegLowAlpha.set(dataEntries[playhead].eegLowAlpha, timeElapsed);
            eegHighAlpha.set(dataEntries[playhead].eegHighAlpha, timeElapsed);
            eegLowBeta.set(dataEntries[playhead].eegLowBeta, timeElapsed);
            eegHighBeta.set(dataEntries[playhead].eegHighBeta, timeElapsed);
            eegLowGamma.set(dataEntries[playhead].eegLowGamma, timeElapsed);
            eegMidGamma.set(dataEntries[playhead].eegMidGamma, timeElapsed);*/
            //eegDelta.set(dataEntries[playhead].eegDelta, timeElapsed);
            
            // in playback mode - need to send the raw data osc seperately
            for(int i = 0; i < dataEntries[playhead].rawDataBufferValues.size(); i++) {
                rawDataGraph->insertValue(dataEntries[playhead].rawDataBufferValues[i]);
                if(tg.allowRawDataEvents) rawDataGraph->sendOSC(dataEntries[playhead].rawDataBufferValues[i]);
            }
            
            playhead++;
            if(playhead >= dataEntries.size()) playhead = 0;
        }
    }
    
    // saves the values and sends osc synced to current framerate
    // could send only on event, but need to keep the data sending constant for max/msp patch    
    //poorsignal.saveValue();
    //attention.saveValue();
    //meditation.saveValue();
    //eegDelta.saveValue();
    /*eegTheta.saveValue();
    eegLowAlpha.saveValue();
    eegHighAlpha.saveValue();
    eegLowBeta.saveValue();
    eegHighBeta.saveValue();
    eegLowGamma.saveValue();
    eegMidGamma.saveValue();*/
    
        
    if(isRecording) {
        
        // save shit
        output << (timeElapsed-startTime) << "," << allData.signal << "," << attentionGraph->currentValue << "," << meditationGraph->currentValue << "," << eegDeltaGraph->currentValue << "," << eegThetaGraph->currentValue << "," << eegLowAlphaGraph->currentValue << "," << eegHighAlphaGraph->currentValue << "," << eegLowBetaGraph->currentValue << "," << eegHighBetaGraph->currentValue << "," << eegLowGammaGraph->currentValue << "," << eegMidGammaGraph->currentValue << "," << rawDataBuffer << "\n";
        
        // clear rawDataBuffer every frame
        rawDataBuffer = "";
    }
    
    //ofLog() << globalMax;
}

//float attSmooth = 0;
//--------------------------------------------------------------
void testApp::draw(){
    
    //ofBackgroundGradient(ofColor(190),ofColor(130));
    ofBackground(130);
    
    if(playbackMode)
        ofSetColor(214, 209, 62);
    else if (tg.isReady)
        ofSetColor(68, 233, 177,180);
    else
        ofSetColor(250, 50, 50, 180);
    ofRect(0, 0, 512, ofGetHeight());
    
    
    // a circle that responds to attention
    // draw a circle on screen which visualises a vertical attention spand
    /*ofPushMatrix();
    ofPushStyle();
    attSmooth += (allData.attention - attSmooth) * .1;
    ofTranslate(512, ofMap(attSmooth, 0, 100, ofGetHeight(), 0));
    ofSetColor(255);
    ofCircle(0,0, 15);
    ofPopStyle();
    ofPopMatrix();*/
    
    // draw a red/green box behind signal to indicate a clean connection
    if(allData.signal == 0) {
        //ofSetColor(115, 180, 122);
        ofSetColor(97, 178, 106);
        ofRect(20, 109, 115, 15);
        
    } else {
        ofSetColor(153, 46, 31);
        ofRect(20, 109, 125, 15);
    }
    
    
    // draw a red circle at the bottom when recording
    if(isRecording) {
        ofSetColor(255, 0, 0);
        ofCircle(35, ofGetHeight() - 50, 15);
    }
    
    settings.draw();
    if(smallWindow) {
        
        // draw a red/green box behind signal to indicate a clean connection
        if(allData.signal == 0) {
            //ofSetColor(115, 180, 122);
            ofSetColor(97, 178, 106);
            ofRect(15, 33, 60, 15);
            
        } else {
            ofSetColor(153, 46, 31);
            ofRect(15, 33, 70, 15);
        }
        stringstream text;
        text << "Device - " << deviceName << ":" << deviceBaudRate << "\n"
        << "OSC - " << host << ":" << port << "\n"
        << "Signal - " << allData.signal << "\n"
        << "Attention - " << allData.attention;
        ofSetColor(255);
        settings.guiFont.drawString(text.str(), 20, 20);
    }
}



//--------------------------------------------------------------
void testApp::keyPressed(int key){
    if(key == ' ') {
        settings.toggleDisplay();
        smallWindow = !smallWindow;
        if(!smallWindow) {
            ofSetWindowShape(1280, 960);
        } else {
            ofSetWindowShape(250, 75);
        }
    } else if(key == 'p') {
        isPaused = !isPaused;
    } else if(key == 'P') {
        
        for(int i = 0; i < meditationGraph->savedValues.size() * 4; i++) {
            ofLog() << meditationGraph->shapeVertices[i];
        }
        
        ofLog() << "-----------";
        for(int i = 0; i < meditationGraph->savedValues.size(); i++) {
            ofLog() << meditationGraph->savedValues[i];
        }
        
    } else if(key == 'n') {
        normaliseMaxToCurrentSet = !normaliseMaxToCurrentSet;
    }
    
    else if(key == 'X') {
        tg.close();
    }
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){
}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){
}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){
    
    string filename = dragInfo.files.front();
	if(ofFilePath::getFileExt(filename) == "csv") {
        playbackMode = true;
        
        EegTimeGraph::dynamicEegMax = 1;
        //poorSignalGraph->reset();
        attentionGraph->reset();
        meditationGraph->reset();
        
        for(int i = 0; i < eegSet.size(); i++) {
            eegSet[i]->reset();
        }
        
        // close device
        tg.close();
        tg.removeEventListener(this);
        tg.isReady = false;
        
        loadPlaybackFile("export/test.csv");
    }
    
}

void testApp::onThinkgearReady(ofxThinkgearEventArgs& args){
    ofLog() << "*** THINKGEAR Ready...";
}

void testApp::onThinkgearError(ofMessage& err){
    ofLog() << "*** THINKGEAR onError..." << err.message;
}

// raw data does not send at frame rate - it sends faster! 512 samples a second
void testApp::onThinkgearRaw(ofxThinkgearEventArgs& args){
    
    //ofLog() << "raw: " << args.raw;
    rawDataValue = args.raw;
    if(tg.allowRawDataEvents) {        
        rawDataGraph->sendOSC(rawDataValue );
    }
    
    if(isRecording) {
        if(rawDataBuffer == "") {
            rawDataBuffer += ofToString(rawDataValue);
        } else {
            rawDataBuffer += "|" + ofToString(rawDataValue); // values seperated by '|". eg. -550|1029|30
        }
        
    }
    
    rawDataGraph->insertValue(rawDataValue);
    
   
}

void testApp::onThinkgearBattery(ofxThinkgearEventArgs& args){
    ofLog() << "*** THINKGEAR battery: " << args.battery;
}

void testApp::onThinkgearPoorSignal(ofxThinkgearEventArgs& args){
    allData.signal = args.poorSignal;
}

void testApp::onThinkgearBlinkStrength(ofxThinkgearEventArgs& args){
    // have not received blink data from Myndplay device?
}

void testApp::onThinkgearAttention(ofxThinkgearEventArgs& args){
    allData.attention = args.attention;
}

void testApp::onThinkgearMeditation(ofxThinkgearEventArgs& args){
    allData.meditation = args.meditation;
}

void testApp::onThinkgearEeg(ofxThinkgearEventArgs& args){

    // about the 8 eeg bands (Comparison table of EEG rhythmic activity frequency bands): http://en.wikipedia.org/wiki/Electroencephalography
    allData.eegDelta = args.eegDelta;
    allData.eegTheta = args.eegTheta;
    allData.eegLowAlpha = args.eegLowAlpha;
    allData.eegHighAlpha = args.eegHighAlpha;
    allData.eegLowBeta = args.eegLowBeta;
    allData.eegHighBeta = args.eegHighBeta;
    allData.eegLowGamma = args.eegLowGamma;
    allData.eegMidGamma = args.eegMidGamma;
}

void testApp::onThinkgearConnecting(ofxThinkgearEventArgs& args){
    ofLog() << "*** THINKGEAR connecting...";
}
