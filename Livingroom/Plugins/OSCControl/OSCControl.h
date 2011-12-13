#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import "ofxOsc.h"

@interface OSCControl : ofPlugin {
    ofxOscSender * sender;
    ofxOscReceiver * receiver;
}

@end
