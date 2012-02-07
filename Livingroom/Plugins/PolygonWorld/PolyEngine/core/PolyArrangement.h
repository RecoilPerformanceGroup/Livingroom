//
//  PolyArrangement.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "lrAppDelegate.h"
#import "PolyDataObserver.h"

#import <Foundation/Foundation.h>

@interface PolyArrangement : NSObject{
    Arrangement_2 * arr;
    PolyDataObserver * obs;
    vector<Arrangement_2::Face_handle> holes;
}

@property (readwrite) Arrangement_2 * arrData;

-(Point_2) n_point;

-(vector< Polygon_2 >) hulls;
-( vector< vector<Arrangement_2::Halfedge_const_handle> >) boundaryHandles;
-(CGAL::Object) cgalObjectAtPoint: (Point_2) queryPoint;
-(Arrangement_2::Vertex_const_handle) vertexAtPoint: (Point_2) queryPoint;
//-(Arrangement_2::Halfedge_const_handle) halVerfedgeAtPoint: (Point_2) queryPoint;
-(Arrangement_2::Face_const_handle) faceAtPoint: (ofVec2f) queryPoint;
-(BOOL) vecInsideBoundary:(ofVec3f)p;
-(BOOL) vecInsideHole:(ofVec3f)p;
-(Arrangement_2::Halfedge_const_handle) nearestBoundaryHalfedge:(ofVec2f)p;
-(Arrangement_2::Halfedge_const_handle) nearestHoleHalfedge:(ofVec2f)p;
-(void) updateHoles;


-(void) saveArrangement:(int)num;
-(void) loadArrangement:(int)num;
-(void) clearArrangement;

-(void) enumerateVertices:(void(^)(Arrangement_2::Vertex_iterator vit, BOOL * stop))func;
-(void) enumerateEdges:(void(^)(Arrangement_2::Edge_iterator eit))func;
-(void) enumerateHalfedges:(void(^)(Arrangement_2::Halfedge_iterator eit))func;
-(void) enumerateFaces:(void(^)(Arrangement_2::Face_iterator fit))func;
-(void) enumerateFaceEdges:(void(^)(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit))func;

@end
