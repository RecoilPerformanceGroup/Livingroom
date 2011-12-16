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
}

@property (readonly) Arrangement_2 * arrData;

-(Point_2) n_point;

-(vector< Polygon_2 >) hulls;
-(CGAL::Object) cgalObjectAtPoint: (Point_2) queryPoint;
-(Arrangement_2::Vertex_const_handle) vertexAtPoint: (Point_2) queryPoint;
//-(Arrangement_2::Halfedge_const_handle) halVerfedgeAtPoint: (Point_2) queryPoint;
-(Arrangement_2::Face_const_handle) faceAtPoint: (Point_2) queryPoint;

-(void) saveArrangement;
-(void) loadArrangement;
-(void) clearArrangement;

-(void) enumerateVertices:(void(^)(Arrangement_2::Vertex_iterator vit))func;
-(void) enumerateEdges:(void(^)(Arrangement_2::Edge_iterator eit))func;
-(void) enumerateFaces:(void(^)(Arrangement_2::Face_iterator fit))func;
-(void) enumerateFaceEdges:(void(^)(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit))func;

@end
