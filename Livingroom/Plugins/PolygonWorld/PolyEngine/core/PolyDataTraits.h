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

// documentation for extended arrangment dcels :
// http://www.cgal.org/Manual/latest/doc_html/cgal_manual/Arrangement_on_surface_2_ref/Class_Arr_extended_dcel.html#Index_anchor_1476

// ------
// VERTEX
// ------

struct LRVertex_data {
    ofColor color;
    double z                    = 0;
    
    //CracksAnimator
    float crackAmount           = 0.0;
    int crackEdgeCount          = 2;    
    
    //SpringsAnimator
    ofVec3f springF             = ofVec3f(0,0,0);
    ofVec3f springV             = ofVec3f(0,0,0);
    
    //CrumbleAnimator
    ofVec3f crumbleforce        = ofVec3f(0,0,0);
    bool crumbleAnchor          = true;
};

// --------
// HALFEDGE
// --------

struct LRHalfedge_data {
    ofColor color;

    //CracksAnimator
    float crackAmount = 0.0;
    
    //SpringsAnimator
    float springOptimalLength   = -1;
    
    //Crumble
    float crumbleOptimalLength  = -1;
    float crumbleOptimalAngle   = -1;
};

// ----
// FACE
// ----

struct LRFace_data {
    ofColor color;
};

#endif