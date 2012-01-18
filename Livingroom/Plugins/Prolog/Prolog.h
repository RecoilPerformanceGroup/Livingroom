#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/filter.h>

@interface Prolog : ofPlugin {
    Filter filterX;
    Filter filterY;
    
    ofVec2f p;
}

@end
