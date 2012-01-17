//
//  PolyInclude.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#pragma once 
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>

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
typedef CGAL::Exact_predicates_inexact_constructions_kernel KernelInexact;

typedef CGAL::Arr_segment_traits_2<Kernel>  Traits_2;
typedef CGAL::Arr_segment_traits_2<KernelInexact>  Traits_2_inexact;
typedef CGAL::Polygon_2<Kernel>             Polygon_2;
typedef Traits_2_inexact::Point_3           Point_3;
typedef Traits_2::Point_2                   Point_2;
typedef Traits_2_inexact::Vector_3          Vector_3;
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

static ofVec2f point2ToVec2(Point_2 p){
    return ofVec2f(CGAL::to_double(p.x()),CGAL::to_double(p.y()));
}

static ofVec3f point3ToVec3(Point_3 p){
    return ofVec3f(CGAL::to_double(p.x()),CGAL::to_double(p.y()), CGAL::to_double(p.z()));
}

static Point_3 vec3ToPoint3(ofVec3f v){
    return Point_3(v.x, v.y, v.z);
}

static ofVec3f cgalVec3ToVec3(Vector_3 v){
    return ofVec3f(v.x(), v.y(), v.z());
}

//---------------- 

static ofVec3f handleToVec3(Arrangement_2::Vertex_handle handle){
    if(handle->data().vecPosOutdated){
        handle->data().vecPosOutdated = false;
        ofVec2f v2 = point2ToVec2(handle->point());
        handle->data().pos = ofVec3f(v2.x, v2.y, 0);
    }
    return handle->data().pos;
}

static ofVec3f handleToVec3(Arrangement_2::Vertex_const_handle handle){
    if(handle->data().vecPosOutdated){
        return point2ToVec2(handle->point());
    }
    return handle->data().pos;
}


static Point_3 handleToPoint3(Arrangement_2::Vertex_handle handle){
    if(handle->data().pointPosOutdated){
        handle->data().pointPosOutdated = false;
        ofVec3f v = handleToVec3(handle);
        handle->data().pointPos = Point_3(v.x, v.y, v.z);
    }
    return handle->data().pointPos;
}


static ofVec2f handleToVec2(Arrangement_2::Vertex_handle handle){
    ofVec3f v = handleToVec3(handle);
    return ofVec2f(v.x,v.y);
}

static ofVec2f handleToVec2(Arrangement_2::Vertex_const_handle handle){
    ofVec3f v = handleToVec3(handle);
    return ofVec2f(v.x,v.y);
}

//---------------- 


static void glVertexHandle(Arrangement_2::Vertex_handle handle){
    ofVec3f p = handleToVec3(handle);
    glVertex3d(p.x , p.y, p.z); 
    
}

//---------------- 

static void setHandlePos(ofVec3f v, Arrangement_2::Vertex_handle handle){
    if(v.x != handle->data().pos.x || v.y != handle->data().pos.y || v.z != handle->data().pos.z){
    handle->data().pointPosOutdated = true;
    handle->data().pos = v;
    }
}
/*
static void setHandlePos(Point_3 p, Arrangement_2::Vertex_handle handle){
    handle->data().vecPosOutdated = true; //Forkert outdated flag (tager den fra arrangement original data)
    handle->data().pointPos = p;
}*/



//---------------- 
static ofVec2f calculateEdgeNormal (Arrangement_2::Halfedge_handle hit){
    ofVec2f v1 = handleToVec2(hit->source());
    ofVec2f v2 = handleToVec2(hit->target());    
    ofVec2f dir = v2-v1;
    return ofVec2f(-dir.y, dir.x);
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
        //    cout<<"nil normal"<<endl;
        
    }
    return ofVec3f();
}

static ofVec3f calculateFaceMid(Arrangement_2::Face_handle fit){
    if(!fit->is_fictitious()){ 
        if(fit->number_of_outer_ccbs() == 1){
            Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
            Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
            
            ofVec3f middle =  handleToVec3(hc->source());
            
            ofVec3f u = handleToVec3(hc->prev()->source());
            ofVec3f v = handleToVec3(hc->target());
            
         //   cout<<"Triangle: "<<middle.x<<", "<<middle.y<<", "<<middle.z<<"   -   "<<u.x<<", "<<u.y<<", "<<u.z<<"   -   "<<v.x<<", "<<v.y<<", "<<v.z<<"   -   "<<
            
            return (middle+u+v)/3.0;
        }                   
    }
    return ofVec3f();
}
