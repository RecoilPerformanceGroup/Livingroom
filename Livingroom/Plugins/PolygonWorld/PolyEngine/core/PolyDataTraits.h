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
    
    // Cracks
    float crackAmount = 0.0;
    int crackEdgeCount = 2;    
    
};

// --------
// HALFEDGE
// --------

struct LRHalfedge_data {
    ofColor color;

    // Cracks
    float crackAmount = 0.0;

};

// ----
// FACE
// ----

struct LRFace_data {
    ofColor color;
};

#endif