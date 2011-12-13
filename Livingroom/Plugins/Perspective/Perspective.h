#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#import "ofx3DModelLoader.h"

@interface Perspective : ofPlugin {
    ofx3DModelLoader squirrelModel;
    
    GLfloat m[16];
    
    /* ambient light in direction (10, 10, 10) */
    GLfloat light1_x;
    GLfloat light1_y;
    GLfloat light1_z;

    GLfloat * mat_specular;
    GLfloat * mat_shininess;
}

@end
