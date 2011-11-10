#pragma once

#import <ofxCocoaPlugins/Plugin.h>

@class PolyEngine;

@interface PolygonWorld : ofPlugin {
    
    int cW,cH;
    float cMouseX,cMouseY;
    
    PolyEngine * polyEngine;
}
- (IBAction)saveArrangement:(id)sender;
- (IBAction)loadArrangement:(id)sender;

@end
