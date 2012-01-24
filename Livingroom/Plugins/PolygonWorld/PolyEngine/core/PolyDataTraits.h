//
//  PolyTraits.h
//  Livingroom
//
//  Created by ole kristensen on 09/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#ifndef Livingroom_PolyDataTraits_h
#define Livingroom_PolyDataTraits_h
#import "PolyInclude.h"

#import <ofxCocoaPlugins/Plugin.h>

//
typedef CGAL::Exact_predicates_inexact_constructions_kernel KernelInexact;
typedef CGAL::Arr_segment_traits_2<KernelInexact>  Traits_2_inexact;
typedef Traits_2_inexact::Point_3                   Point_3;


// documentation for extended arrangment dcels :
// http://www.cgal.org/Manual/latest/doc_html/cgal_manual/Arrangement_on_surface_2_ref/Class_Arr_extended_dcel.html#Index_anchor_1476

// ------
// VERTEX
// ------

struct LRVertex_data {
    ofColor color;
    ofVec3f pos                 = ofVec3f(-1,-1,-1);
    Point_3 pointPos            = Point_3(-1,-1,-1);
    
    bool vecPosOutdated         = true;
    bool pointPosOutdated       = true;
    
    //Physics General
    float physicsLock           = 0.0;
    
    //CracksAnimator
    float crackAmount           = 0.0;
    int crackEdgeCount          = 2;   
    ofVec2f crackDir;
    
    //SpringsAnimator
    ofVec3f springF             = ofVec3f(0,0,0);
    ofVec3f springV             = ofVec3f(0,0,0);
    ofVec3f accumF              = ofVec3f(0,0,0);
    
    //CrumbleAnimator
    ofVec3f crumbleforce        = ofVec3f(0,0,0);
    bool crumbleAnchor          = true;
};

// --------
// HALFEDGE
// --------

struct LRHalfedge_data {
    ofColor color;
    bool deleted                = false;
    //CracksAnimator
    float crackAmount           = 0.0;
    float crackCacheRatio       = 0.0;
    
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
    BOOL hole                   = false;
};

#endif

