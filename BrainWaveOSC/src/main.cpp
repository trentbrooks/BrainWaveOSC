#include "ofMain.h"
#include "testApp.h"
#include "ofAppGlutWindow.h"

//========================================================================
int main( ){
    
    ofAppGlutWindow window;
    
	#if defined(TARGET_WIN32)
        // hide console window?
		HWND handleWindow;  
		AllocConsole();  
		handleWindow = FindWindowA("ConsoleWindowClass", NULL);  
		ShowWindow(handleWindow, 0);

		//window.setGlutDisplayString("rgb double depth alpha samples>=4");
    #elif defined(TARGET_OSX)
        window.setGlutDisplayString("rgba double samples>=4 depth");
    #endif
	


	ofSetupOpenGL(&window, 1280,960, OF_WINDOW);			// <-------- setup the GL context
    
	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp( new testApp());
    
}
