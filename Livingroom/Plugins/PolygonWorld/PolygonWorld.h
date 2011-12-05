#pragma once

#import <ofxCocoaPlugins/Plugin.h>

@class PolyEngine;

@interface PolygonWorld : ofPlugin {
    
    int cW,cH;
    float cMouseX,cMouseY;
    
    PolyEngine * polyEngine;
    NSOutlineView *modulesOutlineview;
}

@property (readonly) PolyEngine * polyEngine;
@property (assign) IBOutlet NSOutlineView *modulesOutlineview;

- (IBAction)saveArrangement:(id)sender;
- (IBAction)loadArrangement:(id)sender;

@end
