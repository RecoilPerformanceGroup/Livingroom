#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import "ofx3DModelLoader.h"

#define ApplySurfaceForProjector(s,p) {if([Surface(s,p) visible]) { [GetPlugin(Keystoner)  applySurface:s projectorNumber:p viewNumber:ViewNumber];
#define PopSurfaceForProjector() [GetPlugin(Keystoner)  popSurface]; }}

#define ApplySurface(s) {int appliedProjector=-1;for(KeystoneProjector*proj in [[[GetPlugin(Keystoner) outputViews] objectAtIndex:ViewNumber] projectors]){ appliedProjector++; if(appliedProjector > 0)[GetPlugin(Keystoner)  popSurface]; ApplySurfaceForProjector(s,appliedProjector)

#define PopSurface() PopSurfaceForProjector() }}


@interface Perspective : ofPlugin {
    
    ofx3DModelLoader squirrelModel;
    
    GLfloat m[16];
    
    /* ambient light in direction (10, 10, 10) */
    GLfloat light1_x;
    GLfloat light1_y;
    GLfloat light1_z;

}

@end
