#pragma once

#import <ofxCocoaPlugins/Plugin.h>

@interface PolygonWorld : ofPlugin {
    
    int cW,cH;
    
    int mode;
}
- (IBAction)delaunay:(id)sender;
- (IBAction)clear:(id)sender;

@end
