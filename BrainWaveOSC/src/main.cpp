#include "ofMain.h"
#include "ofApp.h"

//========================================================================
int main( ){
    
    
	#if defined(TARGET_WIN32)
        // hide console window?
		HWND handleWindow;  
		AllocConsole();  
		handleWindow = FindWindowA("ConsoleWindowClass", NULL);  
		ShowWindow(handleWindow, 0);
    #endif

    
    ofSetupOpenGL(1280,960, OF_WINDOW);			// <-------- setup the GL context
    
	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp( new ofApp());
    
}
