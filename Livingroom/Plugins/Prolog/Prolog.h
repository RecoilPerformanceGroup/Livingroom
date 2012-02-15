#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/filter.h>
#import <ofxCocoaPlugins/Keystoner.h>

@interface Prolog : ofPlugin {
    Filter filterX;
    Filter filterY;
    Filter filterSize;
    
    ofVec2f p;    
    float size;
    
    KeystoneSurface * surface;
    
    ofVec2f top,bottom;
}

@end
