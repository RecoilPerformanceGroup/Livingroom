//
//  PolyTraits.h
//  Livingroom
//
//  Created by ole kristensen on 09/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#ifndef Livingroom_PolyDataTraits_h
#define Livingroom_PolyDataTraits_h

#import <ofxCocoaPlugins/Plugin.h>

// ------
// VERTEX
// ------

struct LRVertex_data {
    ofColor color;
    
    //SpringsAnimator
    ofVec2f springF;
    ofVec2f springV;
};

// --------
// HALFEDGE
// --------

struct LRHalfedge_data {
    ofColor color;
    
    //SpringsAnimator
    float springOptimalLength;
};

// ----
// FACE
// ----

struct LRFace_data {
    ofColor color;
};

#endif