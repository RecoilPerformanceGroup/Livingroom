#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/Keystoner.h>


@interface Mask : ofPlugin {
    KeystoneSurface * triangleRight;
    KeystoneSurface * triangleLeft;
    
    BOOL adjustInProgress;
    
    ofVec2f triangleFloorCoordinate[2];
}

-(ofVec2f) triangleFloorCoordinate:(float)n;

@end
