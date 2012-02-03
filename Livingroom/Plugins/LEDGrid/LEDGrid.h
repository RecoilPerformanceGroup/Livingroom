#pragma once
#import <ofxCocoaPlugins/Plugin.h>

struct Lamp {
    float color[4];
    int channel;
    ofVec2f pos;
};

#define NUM_LAMPS 50

@interface LEDGrid : ofPlugin {
    Lamp lamps[NUM_LAMPS];
    
    ofImage * chessImage;
}

@end
