![https://raw.github.com/trentbrooks/BrainWaveOSC/master/screenshot.png](https://raw.github.com/trentbrooks/BrainWaveOSC/master/screenshot.png)

## BrainWaveOSC ##

Opensource collaboration project with George Khut and James Brown for Creative Neurofeedback Workshops in Sydney. http://georgekhut.com/2013/05/sydney-creative-neurofeedback-workshops/#1

Application connects to and transmits data from Neurosky ThinkGear-based EEG sensors to multimedia applications like Max6, Ableton Live, PureData and Reaktor using the OpenSoundControl networking protocol. You can also record and playback the EEG sensor data within the application.

OSX and Windows applications in /Application_osx_win folder.

Windows users: If there is an error message about a missing "MSVCP100.dll", you need to download the 'Microsoft Visual C++ 2010 Redistributable Package' from here: [http://www.microsoft.com/en-au/download/details.aspx?id=5555](http://www.microsoft.com/en-au/download/details.aspx?id=5555)

Made with Openframeworks. 

## Openframeworks addons ##
* 	ofxXmlSettings & ofxOsc (core addons)
*	ofxTouchGUI & ofxThinkgear (included in this repo in /addons folder)

## Credit ##
Original ofxThinkgear addon by Laurent Bedubourg <laurent@labe.me> [https://github.com/labe-me/ofxThinkgear](https://github.com/labe-me/ofxThinkgear). Note, the included ofxThinkgear addon has been modified for this application (deleted a bunch of stuff and added some reconnection fixes).