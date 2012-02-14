#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#include "ofxCvMain.h"

struct Lamp {
    float color[4];
    int channel;
    ofVec2f pos;
};

#define NUM_LAMPS 50
#define GRID 300
@interface LEDGrid : ofPlugin {
    Lamp lamps[NUM_LAMPS];
    
    ofImage * chessImage;
    
    ofxCvFloatImage cvImage;
    ofxCvFloatImage trackerFloat;
    ofxCvGrayscaleImage mask;


}

@end
