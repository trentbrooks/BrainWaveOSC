#include "ThinkgearCommsDriver.h"

#ifdef TARGET_OSX
ThinkgearCommsDriver::ThinkgearCommsDriver() {

    isReady = false;
    thinkGearBundle = NULL;
    TG_GetDriverVersion = NULL;
    TG_GetNewConnectionId = NULL;
    TG_ReadPackets = NULL;
    TG_GetValue = NULL;
    TG_GetValueStatus = NULL;
    TG_Disconnect = NULL;
    TG_FreeConnection = NULL;
    TG_EnableBlinkDetection = NULL;
    connectionID = -1;

    
    unavailableCount = 0;
    noConnectionRestartCount = 250;
    noDataRestartCount = 500;
}

ThinkgearCommsDriver::~ThinkgearCommsDriver(){

    reset();
}

void ThinkgearCommsDriver::reset() {
    
    if(connectionID != -1){
        ofLogVerbose() << "Disconnecting ThinkGear device.";
        TG_Disconnect(connectionID);
        TG_FreeConnection(connectionID);
    }
    // release the bundle references
    if(bundleURL) CFRelease(bundleURL);
    if(thinkGearBundle) CFRelease(thinkGearBundle);
}


bool ThinkgearCommsDriver::connect() {

    reset();
    
    string ofTGPath = ofToDataPath("ThinkGear.bundle");
    CFStringRef filePath = CFStringCreateWithCString(kCFAllocatorDefault, ofTGPath.c_str(), kCFStringEncodingUTF8);    
    bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                              filePath,
                                              kCFURLPOSIXPathStyle,
                                              true);
    thinkGearBundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
    CFRelease(filePath);
    
    if (!thinkGearBundle) {
        ofLogVerbose() << "Error: Could not find ThinkGear.bundle. Does it exist in the current directory? " << ofTGPath;
        isReady = false;
        return isReady;
        //exit(1);
    }
    
    // now start setting the function pointers
    TG_GetDriverVersion = (int(*)())CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetDriverVersion"));
    TG_GetNewConnectionId = (int(*)())CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetNewConnectionId"));
    TG_Connect = (int(*)(int, const char*, int, int))CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_Connect"));
    TG_ReadPackets = (int(*)(int, int))CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_ReadPackets"));
    TG_GetValue = (float(*)(int, int))CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetValue"));
    TG_GetValueStatus = (bool(*)(int, int))CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_GetValueStatus"));
    TG_Disconnect = (int(*)(int))CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_Disconnect"));
    TG_FreeConnection = (void(*)(int))CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_FreeConnection"));
    TG_EnableBlinkDetection = (int(*)(int, int))CFBundleGetFunctionPointerForName(thinkGearBundle, CFSTR("TG_EnableBlinkDetection"));
    
    if (!TG_GetDriverVersion ||
        !TG_GetNewConnectionId ||
        !TG_Connect ||
        !TG_ReadPackets ||
        !TG_GetValue ||
        !TG_Disconnect ||
        !TG_FreeConnection ||
        !TG_EnableBlinkDetection)
    {
        ofLogVerbose() << "Error: Expected functions in ThinkGear.bundle were not found.";
        isReady = false;
        return isReady;
        //exit(1);
    }
    
    // get the connection ID
    connectionID = TG_GetNewConnectionId();
    int version = TG_GetDriverVersion();
    ofLogVerbose() << "Connecting to " << deviceName << ". Driver version: " << version;
    
    
    // attempt to connect    
    int conResult = TG_Connect(connectionID, deviceName.c_str(), baudRate, TG_STREAM_PACKETS);
    if (conResult != 0) {
        ofLogVerbose() << "Error: Connection Failed! " << conResult;
        if(conResult == -2)            
            ofLogVerbose() << "Serial port could not be opened!";
        isReady = false;
        return isReady;
    }
    
    
    // enable blinking for connection
    int resBlink = TG_EnableBlinkDetection(connectionID, 1);
    if (resBlink != 0)
        ofLogVerbose() << "Blink: Failed to enable blink detection";
    
    isReady = true;
    return isReady;
}



void ThinkgearCommsDriver::update() {
    
    // need to handle connection/reconnection issues
    if(!isReady) {        
        return;
    }
    
    // read each packet individually- use the callback
    int packetsRead = 0;
    while(TG_ReadPackets(connectionID, 1) > 0) {
        packetsRead++;
        if(TG_GetValueStatus(connectionID, TG_DATA_RAW) != 0) {
            float raw = TG_GetValue(connectionID, TG_DATA_RAW);
            callback(TG_DATA_RAW,raw);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_POOR_SIGNAL) != 0) {
            float signal = TG_GetValue(connectionID, TG_DATA_POOR_SIGNAL);
            callback(TG_DATA_POOR_SIGNAL,signal);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_BATTERY) != 0) {
            float battery = TG_GetValue(connectionID, TG_DATA_BATTERY);
            callback(TG_DATA_BATTERY,battery);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_ATTENTION) != 0) {
            float attention = TG_GetValue(connectionID, TG_DATA_ATTENTION);
            callback(TG_DATA_ATTENTION,attention);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_MEDITATION) != 0) {
            float meditation = TG_GetValue(connectionID, TG_DATA_MEDITATION);
            callback(TG_DATA_MEDITATION,meditation);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_DELTA) != 0) {
            float delta = TG_GetValue(connectionID, TG_DATA_DELTA);
            callback(TG_DATA_DELTA,delta);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_THETA) != 0) {
            float theta = TG_GetValue(connectionID, TG_DATA_THETA);
            callback(TG_DATA_THETA,theta);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_ALPHA1) != 0) {
            float alpha1 = TG_GetValue(connectionID, TG_DATA_ALPHA1);
            callback(TG_DATA_ALPHA1,alpha1);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_ALPHA2) != 0) {
            float alpha2 = TG_GetValue(connectionID, TG_DATA_ALPHA2);
            callback(TG_DATA_ALPHA2,alpha2);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_BETA1) != 0) {
            float beta1 = TG_GetValue(connectionID, TG_DATA_BETA1);
            callback(TG_DATA_BETA1,beta1);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_BETA2) != 0) {
            float beta2 = TG_GetValue(connectionID, TG_DATA_BETA2);
            callback(TG_DATA_BETA2,beta2);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_GAMMA1) != 0) {
            float gamma1 = TG_GetValue(connectionID, TG_DATA_GAMMA1);
            callback(TG_DATA_GAMMA1,gamma1);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_GAMMA2) != 0) {
            float gamma2 = TG_GetValue(connectionID, TG_DATA_GAMMA2);
            callback(TG_DATA_GAMMA2,gamma2);
        }
        if(TG_GetValueStatus(connectionID, TG_DATA_BLINK_STRENGTH) != 0) {
            float blinkStrength = TG_GetValue(connectionID, TG_DATA_BLINK_STRENGTH);
            callback(TG_DATA_BLINK_STRENGTH,blinkStrength);
        }

        
        /*stringstream s;
        for(int i = 0; i < 12; i++) {
            s << TG_GetValueStatus(connectionID, i);
        }                             
        ofLog() << s.str();// << raw;*/
        
        //[notice] 000010000000
    }

    // no data received.... reconnect
    if(packetsRead == 0) {
        unavailableCount++;
        if(unavailableCount >  noDataRestartCount) {
            ofLogVerbose() << "*** no data available - attempt to reconnect";
            unavailableCount = 0;
            isReady = false;
            
            //connect();
        }
    } else {
        unavailableCount = 0;
    }
}
#endif