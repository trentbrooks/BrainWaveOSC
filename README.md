![https://raw.github.com/trentbrooks/BrainWaveOSC/master/screenshot.png](https://raw.github.com/trentbrooks/BrainWaveOSC/master/screenshot.png)

## BrainWaveOSC ##

Opensource collaboration project with George Khut and James Brown for Creative Neurofeedback Workshops in Sydney. http://georgekhut.com/2013/05/sydney-creative-neurofeedback-workshops/#1

Application connects to and transmits data from Neurosky ThinkGear-based EEG sensors to multimedia applications like Max6, Ableton Live, PureData and Reaktor using the OpenSoundControl networking protocol. You can also record and playback the EEG sensor data within the application.

OSX and Windows applications in /Application_osx_win folder.

Windows users: If there is an error message about a missing "MSVCP100.dll", you need to download the 'Microsoft Visual C++ 2010 Redistributable Package' from here: [http://www.microsoft.com/en-au/download/details.aspx?id=5555](http://www.microsoft.com/en-au/download/details.aspx?id=5555)

Made with Openframeworks. 

## OSC messages ##
The 8 EEG band frequencies (sent 30x per second as floats): 
    "eegdelta" : 1-3Hz
    "eegtheta" : 4-7Hz
    "eeglowalpha" : 8-9Hz
    "eeghighalpha" : 10-12Hz
    "eeglowbeta" : 13-17Hz
    "eeghighbeta" : 18-30Hz
    "eeglowgamma" : 31-40Hz
    "eegmidgamma" : 41-50Hz
Other values (sent 30x per second as floats):
    "signal" : 0-200 (0 = good connection, 200 = no connection)
    "attention" : 0-100 (higher number = more attention)
    "meditation" : 0-100 (higher number = more attention)
Optional raw data value (sent 512x per second as floats):
    "raw" : -32768-32768 or -2048-2048 (depends on device)

Note: the 8 EEG band frequencies, signal, attention, and meditation values only update around once per second due to device limitations. We are sending these values at 30x per second anyway, this made it easier to work in Max/PureData for audio feedback applications. 

## Openframeworks addons ##
* 	ofxXmlSettings & ofxOsc (core addons)
*	ofxTouchGUI & ofxThinkgear (included in this repo in /addons folder)

## Credit ##
Original ofxThinkgear addon by Laurent Bedubourg <laurent@labe.me> [https://github.com/labe-me/ofxThinkgear](https://github.com/labe-me/ofxThinkgear). Note, the included ofxThinkgear addon has been modified for this application (deleted a bunch of stuff and added some reconnection fixes).