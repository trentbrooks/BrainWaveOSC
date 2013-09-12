![https://raw.github.com/trentbrooks/BrainWaveOSC/develop/screenshot.png](https://raw.github.com/trentbrooks/BrainWaveOSC/develop/screenshot.png)

## About ##

BrainWaveOSC was designed by Trent Brooks for George Khut - to pass EEG data from Neurosky ThinkGear-based bluetooth EEG sensors to other applications like Max-MSP and PureData via the OpenSoundControl networking protocol. Originally developed for the Creative Neurofeedback Workshops in Sydney- http://georgekhut.com/2013/05/sydney-creative-neurofeedback-workshops/#1 

It's been tested with the BrainBand interface produced by MyndPlay, but should work with other sensors that also use the Thinkgear system. BrainWaveOSC does not perform any filtering or analysis - it's function is purely to pass on the data that is being measured by the ThinkGear hardware. Data from each of the EEG bands is updated approximately every second – again - this is the rate that the data is being sent from the ThinkGear hardware - and is not determined by this sotware. All the the EEG frequency domain processing (i.e. Alpha, Theta, Delta etc.) is done on the ThinkGear chip, but you can also access the raw data as it is transmitted by the ThinkGear chip, by checking the "SEND RAW DATA WITH OSC" option. Neurosky's "Attention" and "Meditation" values seem quite random and not very useful, but the Alpha channels have been tested and are reasonably responsive, once you apply some scaling and normalisation, and figure out how to increase this EEG band by closing your eyes and quieting your mind.

## Instructions ##
- Pair the bluetooth device with your computer using your computer's bluetooth pairing process - and note the serial device name (OSX) or com port id (Windows).
- Check that this name/comport number is matched by the settings that can be edited in the "settings.xml" file located inside the "data" folder that is located in the same directory as the application.
- Once the device has been added to your computers Bluetooth devices list, you should not need to edit this info again.
- Turn off the ThinkGear device (i.e. BrainBand), then restart the device - while pairing with your computer  - on the BrainBand device - you will see the blue LED blinking rapidly for up to a minute, after which it will blink approximately once a second, indicating that it is now connected to your computer. 
- Now launch the BrainWaveOSC app - to pass the EEG data via OpenSoundControl.

## Recording and playback ##
You can record the EEG band data into a CSV text file, for later playback and analysis, by checking the "RECORD TO CSV" option - the recorded data will be saved into a file named with the current date and time. To play back this file - make a copy and rename it "test.csv". Then check the "PLAYBACK MODE" box in the app to playback the renamed recording.

## OSC messages ##
The 8 EEG band frequencies (sent 30x per second as floats): 

    "/eegdelta" : 1-3Hz
    "/eegtheta" : 4-7Hz
    "/eeglowalpha" : 8-9Hz
    "/eeghighalpha" : 10-12Hz
    "/eeglowbeta" : 13-17Hz
    "/eeghighbeta" : 18-30Hz
    "/eeglowgamma" : 31-40Hz
    "/eeghighgamma" : 41-50Hz
Other values (sent 30x per second as floats):

    "/signal" : 0-200 (0 = good connection, 200 = poor connection)
    "/attention" : 0-100 (higher number = more attention)
    "/meditation" : 0-100 (higher number = more meditation)
Optional raw data value (sent 512x per second as floats):

    "/raw" : -2048-2048 (depends on device)

## Other ##
Windows users: If there is an error message about a missing "MSVCP100.dll", you need to download the 'Microsoft Visual C++ 2010 Redistributable Package' from here: [http://www.microsoft.com/en-au/download/details.aspx?id=5555](http://www.microsoft.com/en-au/download/details.aspx?id=5555)

OSX and Windows applications in /Application_osx_win folder.

## Openframeworks addons ##
* 	ofxXmlSettings & ofxOsc (core addons)
*	ofxTouchGUI & ofxThinkgear (included in this repo in /addons folder)

## Credit ##
Original ofxThinkgear addon by Laurent Bedubourg <laurent@labe.me> [https://github.com/labe-me/ofxThinkgear](https://github.com/labe-me/ofxThinkgear). Note, the included ofxThinkgear addon has been modified for this application (deleted a bunch of stuff and added some reconnection fixes).