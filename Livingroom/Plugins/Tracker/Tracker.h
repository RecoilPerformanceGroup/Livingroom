#pragma once
#import <ofxCocoaPlugins/Plugin.h>

#define USE_

@interface Tracker : ofPlugin {
    ofVec2f controlMouse;
}

-(int) numberTrackers;
-(ofVec2f) trackerCentroid:(int)n;

@end
