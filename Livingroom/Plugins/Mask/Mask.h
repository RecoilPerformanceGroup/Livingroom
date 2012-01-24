#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import <ofxCocoaPlugins/Keystoner.h>


@interface Mask : ofPlugin {
    KeystoneSurface * triangleRight;
    KeystoneSurface * triangleLeft;
    
    BOOL adjustInProgress;
}

@end
