//
//  PolyInclude.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Livingroom_PolyInclude_h
#define Livingroom_PolyInclude_h

//#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>

#include <CGAL/Exact_predicates_exact_constructions_kernel.h>
#include <CGAL/Arr_segment_traits_2.h>
#include <CGAL/Arrangement_2.h>
#include <CGAL/Arr_extended_dcel.h>


#include <CGAL/Polygon_2.h>
#include "PolyDataTraits.h"

//
////#include <CGAL/Projection_traits_xy_3.h>
//#include <CGAL/Constrained_Delaunay_triangulation_2.h>
//#include <CGAL/Delaunay_mesher_2.h>
//#include <CGAL/Delaunay_mesh_face_base_2.h>
//#include <CGAL/Delaunay_mesh_size_criteria_2.h>

typedef CGAL::Exact_predicates_exact_constructions_kernel Kernel;
//typedef CGAL::Exact_predicates_inexact_constructions_kernel Kernel;

typedef CGAL::Arr_segment_traits_2<Kernel>  Traits_2;
typedef CGAL::Polygon_2<Kernel>             Polygon_2;
typedef Traits_2::Point_2                   Point_2;
typedef Traits_2::X_monotone_curve_2        Segment_2;
typedef CGAL::Arr_extended_dcel<Traits_2,LRVertex_data, LRHalfedge_data, LRFace_data>
                                            Dcel;
typedef CGAL::Arrangement_2<Traits_2, Dcel> Arrangement_2;

//typedef CGAL::Triangulation_vertex_base_2<K> Vb;
//typedef CGAL::Delaunay_mesh_face_base_2<K> Fb;
//typedef CGAL::Triangulation_data_structure_2<Vb, Fb> Tds;
//typedef CGAL::Constrained_Delaunay_triangulation_2<K, Tds> CDT;
//typedef CGAL::Delaunay_mesh_size_criteria_2<CDT> Criteria;
//typedef CGAL::Delaunay_mesher_2<CDT, Criteria> Mesher;
//
//typedef CDT::Edge_iterator  Edge_iterator;
//
//typedef CDT::Vertex_handle Vertex_handle;
//typedef CDT::Point Point2;

static ofVec2f pointToVec(Point_2 p){
    return ofVec2f(CGAL::to_double(p.x()),CGAL::to_double(p.y()));
}

static ofVec3f handleToVec3(Arrangement_2::Vertex_handle handle){
//    return ofVec3f(CGAL::to_double(handle->point().x()),CGAL::to_double(handle->point().y()), handle->data().z);
    if(handle->data().pos.x == -1 && handle->data().pos.y == -1 && handle->data().pos.z == -1){
        ofVec2f v2 = pointToVec(handle->point());
        handle->data().pos = ofVec3f(v2.x, v2.y, handle->data().pos.z);
    }
    return handle->data().pos;
}

static ofVec2f handleToVec2(Arrangement_2::Vertex_handle handle){
    //return ofVec2f(CGAL::to_double(handle->point().x()),CGAL::to_double(handle->point().y()));
    ofVec3f v = handleToVec3(handle);
    return ofVec2f(v.x,v.y);
}

static void glVertexHandle(Arrangement_2::Vertex_handle handle){
    ofVec3f p = handleToVec3(handle);
    glVertex3d(p.x , p.y, p.z);
}


static ofVec3f calculateFaceNormal (Arrangement_2::Face_handle fit){
    if(!fit->is_fictitious()){
        if(fit->number_of_outer_ccbs() == 1){
            Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
            Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
            
            ofVec3f middle =  handleToVec3(hc->source());
            
            ofVec3f u = handleToVec3(hc->prev()->source()) - middle;
            ofVec3f v = handleToVec3(hc->target()) - middle;
            
            ofVec3f normal = u.cross(v);
            normal.normalize();
            
            return normal;
        }            
    }
    return ofVec3f();
}
#endif
