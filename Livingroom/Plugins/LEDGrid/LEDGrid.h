#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#include "ofxCvMain.h"

struct Lamp {
    float color[4];
    int channel;
    ofVec2f pos;
    int maxDim;
};

struct gradientVals {
    float x;
    float y;
    float size;
    float intensity;
    float val;
};

#define NUM_LAMPS 58
#define GRID 300
@interface LEDGrid : ofPlugin {
    Lamp lamps[NUM_LAMPS];
    
    ofImage * chessImage;
    
    ofxCvFloatImage cvImage;
    ofxCvFloatImage trackerFloat;
    ofxCvGrayscaleImage mask;

    ofxCvFloatImage cloudImage;
    ofxCvFloatImage tmpImage;

    gradientVals * gradients;
    int numGradients;
}

-(void) setGradients:(gradientVals*)_gradients num:(int)num;

@end
