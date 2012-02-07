//
//  PolyInclude.h
//  Livingroom
//
//  Created B.y Livingroom on 08/11/11.
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
//#include <CGAL/Constrained_DelaunA.y_triangulation_2.h>
//#include <CGAL/DelaunA.y_mesher_2.h>
//#include <CGAL/DelaunA.y_mesh_face_base_2.h>
//#include <CGAL/DelaunA.y_mesh_size_criteria_2.h>

typedef CGAL::Exact_predicates_exact_constructions_kernel Kernel;
typedef CGAL::Exact_predicates_inexact_constructions_kernel KernelInexact;

typedef CGAL::Arr_segment_traits_2<Kernel>  Traits_2;
typedef CGAL::Arr_segment_traits_2<KernelInexact>  Traits_2_inexact;
typedef CGAL::Polygon_2<Kernel>             Polygon_2;
typedef Traits_2_inexact::Point_3           Point_3;
typedef Traits_2::Point_2                   Point_2;
typedef Traits_2_inexact::Point_2           Point_2_inexact;
typedef Traits_2_inexact::Vector_3          Vector_3;
typedef Traits_2::Segment_2        Segment_2;
typedef Traits_2::Line_2                    Line_2;
typedef CGAL::Arr_extended_dcel<Traits_2,LRVertex_data, LRHalfedge_data, LRFace_data>
Dcel;
typedef CGAL::Arrangement_2<Traits_2, Dcel> Arrangement_2;
typedef Arrangement_2::Halfedge_handle Halfedge_handle;

//typedef CGAL::Triangulation_vertex_base_2<K> Vb;
//typedef CGAL::DelaunA.y_mesh_face_base_2<K> Fb;
//typedef CGAL::Triangulation_data_structure_2<Vb, Fb> Tds;
//typedef CGAL::Constrained_DelaunA.y_triangulation_2<K, Tds> CDT;
//typedef CGAL::DelaunA.y_mesh_size_criteria_2<CDT> Criteria;
//typedef CGAL::DelaunA.y_mesher_2<CDT, Criteria> Mesher;
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

static void glVertexHandle(Arrangement_2::Vertex_const_handle handle){
    ofVec3f p = handleToVec3(handle);
    glVertex3d(p.x , p.y, p.z); 
    
}

//---------------- 

static void printVec3f(ofVec3f p){
    cout<<"VHandle: ["<<p.x<<", "<<p.y<<", "<<p.z<<"]"<<endl;
}

static void printVertexHandle(Arrangement_2::Vertex_const_handle handle){
    ofVec3f p = handleToVec3(handle);
    printVec3f(p);
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

static float edgeLength(Arrangement_2::Halfedge_const_handle hit){
    ofVec2f v1 = handleToVec2(hit->source());
    ofVec2f v2 = handleToVec2(hit->target());    
    ofVec2f dir = v2-v1;
    return dir.length();    
}


/*static ofVec2f calculateEdgeNormal (Halfedge_handle hit){
    ofVec2f v1 = handleToVec2(hit->source());
    ofVec2f v2 = handleToVec2(hit->target());    
    ofVec2f dir = v2-v1;
    return ofVec2f(-dir.y, dir.x);
}*/

static ofVec2f calculateEdgeNormal (Arrangement_2::Halfedge_const_handle hit){
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


//-----------------

static bool vecInCCB(Arrangement_2::Ccb_halfedge_const_circulator circ, ofVec2f p)
{
    Arrangement_2::Ccb_halfedge_const_circulator hc = circ; 
    
    int c = 0;
    
    do { 
        ofVec2f source = handleToVec2(hc->source());
        ofVec2f target = handleToVec2(hc->target());
        
        if ((((target.y <= p.y) && (p.y < source.y)) ||
             ((source.y <= p.y) && (p.y < target.y))) &&
            (p.x < (source.x - target.x) * (p.y - target.y) / (source.y - target.y) + target.x))
            c = !c;
        
        ++hc; 
    } while (hc != circ); 
    
    return c;
}

// ---------



static double distanceVecToLine(ofVec2f P, ofVec2f A, ofVec2f B)
{
    double normalLength = sqrt((B.x - A.x) * (B.x - A.x) + (B.y - A.y) * (B.y - A.y));
    return fabs((P.x - A.x) * (B.y - A.y) - (P.y - A.y) * (B.x - A.x)) / normalLength;
}




static double distanceVecToHalfedge(ofVec2f P, Arrangement_2::Halfedge_const_handle hit)
{
    ofVec2f A = handleToVec2(hit->source());
    ofVec2f B = handleToVec2(hit->target());
    return distanceVecToLine(P,A,B);
}

static bool lineSegmentIntersection(
                             ofVec2f A,
                             ofVec2f B,
                             ofVec2f C,
                             ofVec2f D,
                             ofVec2f * R) {
    
    double  distAB, theCos, theSin, newX, ABpos ;
    
    //  Fail if either line segment is zero-length.
    if ((A.x==B.x && A.y==B.y) || (C.x==D.x && C.y==D.y)) return NO;
    
    //  Fail if the segments share an end-point.
    if ((A.x==C.x && A.y==C.y) || (B.x==C.x && B.y==C.y)
        ||  (A.x==D.x && A.y==D.y) || (B.x==D.x && B.y==D.y)) {
        return NO; }
    
    //  (1) Translate the system so that point A is on the origin.
    B.x-=A.x; B.y-=A.y;
    C.x-=A.x; C.y-=A.y;
    D.x-=A.x; D.y-=A.y;
    
    //  Discover the length of segment A-B.
    distAB=sqrt(B.x*B.x+B.y*B.y);
    
    //  (2) Rotate the system so that point B is on the positive X A.xis.
    theCos=B.x/distAB;
    theSin=B.y/distAB;
    newX=C.x*theCos+C.y*theSin;
    C.y  =C.y*theCos-C.x*theSin; C.x=newX;
    newX=D.x*theCos+D.y*theSin;
    D.y  =D.y*theCos-D.x*theSin; D.x=newX;
    
    //  Fail if segment C-D doesn't cross line A-B.
    if ((C.y<0. && D.y<0.) || (C.y>=0. && D.y>=0.)) return NO;
    
    //  (3) Discover the position of the intersection point along line A-B.
    ABpos=D.x+(C.x-D.x)*D.y/(D.y-C.y);
    
    //  Fail if segment C-D crosses line A-B outside of segment A-B.
    if (ABpos<0. || ABpos>distAB) return NO;
    
    //  (4) Apply the discovered position to line A-B in the original coordinate system.
    R->x=A.x+ABpos*theCos;
    R->y=A.y+ABpos*theSin;
    
    //  Success.
    return YES; 
}


