//
//  PolyArrangement.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyArrangement.h"
#include <CGAL/convex_hull_2.h>

#include <CGAL/Arr_landmarks_point_location.h>

#include <CGAL/IO/Arr_iostream.h>
#include <fstream>


@implementation PolyArrangement

-(id)init{
    if(self = [super init]){
        arr = new Arrangement_2;
        obs = new PolyDataObserver(arr);
    }
    return self;
}

//
//-----------
//


- (Arrangement_2 *)arrData
{
    @synchronized(self)
    {
        return arr;
    }
}
- (void)setArrData:(Arrangement_2 *)aArr
{
    @synchronized(self)
    {
        arr = aArr;
    }
}


CGAL::Cartesian_converter<Kernel,CGAL::Convex_hull_traits_2<Kernel> > converter;
CGAL::Cartesian_converter<CGAL::Convex_hull_traits_2<Kernel>, Kernel > converter2;

-(Point_2) n_point{
    vector< CGAL::Convex_hull_traits_2<Kernel>::Point_2> output;    
    vector< CGAL::Convex_hull_traits_2<Kernel>::Point_2> input;
    
    Arrangement_2::Vertex_iterator vit = arr->vertices_begin();
    for( ; vit != arr->vertices_end(); ++vit){
        input.push_back( converter(vit->point()));
    }
    
    CGAL::convex_hull_2(input.begin(), input.end(), back_inserter( output));
    
    return converter2(output[0]);
}

//
//-----------
//
-(vector< Polygon_2>) hulls{
    Arrangement_2 output;
    @synchronized(self)
    {
        output.assign(*arr);
    }    
    vector<Arrangement_2::Halfedge_handle> deleteHandles;
    
    Arrangement_2::Edge_iterator eit = output.edges_begin();
    
    for( ; eit != output.edges_end(); ++eit){
        if(!eit->face()->is_unbounded() && !eit->twin()->face()->is_unbounded()){
            deleteHandles.push_back(eit);
        }
    }
    
    for(int i=0;i<deleteHandles.size();i++){
        output.remove_edge(deleteHandles[i], false, false);
    }
    
    vector< Polygon_2> ret = vector< Polygon_2>();
    ret.clear();
    
    Arrangement_2::Face_iterator fit = output.faces_begin();
    for( ; fit != output.faces_end(); ++fit){
        Polygon_2 p;
        
        if(fit->number_of_outer_ccbs() == 1){
            
            Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
            Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
            do { 
                p.push_back(hc->source()->point());
                ++hc; 
            } while (hc != ccb_start); 
        }
        
        if(!p.is_empty())
            ret.push_back(p);
    }
    return ret;
}

-( vector< vector<Arrangement_2::Halfedge_const_handle> >) boundaryHandles{
    vector< vector<Arrangement_2::Halfedge_const_handle> > output;
    Arrangement_2::Unbounded_face_iterator ufit = arr->unbounded_faces_begin();
    for( ; ufit != arr->unbounded_faces_end(); ++ufit){
        int i=0;
        if(!ufit->is_fictitious() && ufit->number_of_inner_ccbs() >= 1){
            Arrangement_2::Hole_iterator hit = ufit->holes_begin();
            for( ; hit != ufit->holes_end(); ++hit){
                vector<Arrangement_2::Halfedge_const_handle> v;

                Arrangement_2::Ccb_halfedge_const_circulator ccb_start = *hit;
                Arrangement_2::Ccb_halfedge_const_circulator hc = ccb_start; 
                do { 
                    v.push_back(hc);
                    i++;
                    ++hc; 
                } while (hc != ccb_start); 
                output.push_back(v);

            }
        }
    }
    return output;
}

-(BOOL) vecInsideBoundary:(ofVec3f)p {
    Arrangement_2::Unbounded_face_iterator ufit = arr->unbounded_faces_begin();
    for( ; ufit != arr->unbounded_faces_end(); ++ufit){
        if(!ufit->is_fictitious() && ufit->number_of_inner_ccbs() >= 1){
            Arrangement_2::Hole_iterator hit = ufit->holes_begin();
            for( ; hit != ufit->holes_end(); ++hit){
                if(vecInCCB(*hit, p)){
                    return true;
                }
            }
        }
    }
    
    return false;
}

-(Arrangement_2::Halfedge_const_handle) nearestBoundaryHalfedge:(ofVec2f)p{
    //Could be more sophisticated with multiple boundaries
    
    BOOL insideBoundary = false;
    Arrangement_2::Ccb_halfedge_const_circulator boundary;
    
    //Is the point inside or outside?
    Arrangement_2::Unbounded_face_iterator ufit = arr->unbounded_faces_begin();
    for( ; ufit != arr->unbounded_faces_end(); ++ufit){
        if(!ufit->is_fictitious() && ufit->number_of_inner_ccbs() >= 1){
            Arrangement_2::Hole_iterator hit = ufit->holes_begin();
            for( ; hit != ufit->holes_end(); ++hit){
                if(vecInCCB(*hit, p)){
                    insideBoundary = true;
                    boundary = *hit;
                }
            }
        }
    }
    
    //Find nearest point
    Arrangement_2::Ccb_halfedge_const_circulator nearestPoint;
    float bestDist = -1;
    
    if(insideBoundary){
        //TODO
        cout<<"Inside Boundary TODO"<<endl;
        return Arrangement_2::Halfedge_const_handle();
    } else {
        Arrangement_2::Unbounded_face_iterator ufit = arr->unbounded_faces_begin();
        for( ; ufit != arr->unbounded_faces_end(); ++ufit){
            if(!ufit->is_fictitious() && ufit->number_of_inner_ccbs() >= 1){
                Arrangement_2::Hole_iterator hit = ufit->holes_begin();
                for( ; hit != ufit->holes_end(); ++hit){
                    Arrangement_2::Ccb_halfedge_const_circulator hc = *hit;                     
                    do { 
                        ofVec2f source = handleToVec2(hc->source());
                        
                        float dist = source.distance(p);
                        if(bestDist == -1 || dist < bestDist){
                            nearestPoint = hc;
                            bestDist = dist;
                        }

                        ++hc; 
                    } while (hc != *hit); 
                }
            }
        }
        
        if(bestDist == -1){
            cout<<"ARRGGH: No point"<<endl;
            return Arrangement_2::Halfedge_const_handle();
        } else {
            //cout<<bestDist<<"  ";
           // printVertexHandle(nearestPoint->source());
            
            ofVec2f vertex = handleToVec2(nearestPoint->source());
            ofVec2f pDir = p-vertex;
            
            Arrangement_2::Halfedge_const_handle handle2 = nearestPoint;
            Arrangement_2::Halfedge_const_handle handle1 = nearestPoint->prev();
            
            ofVec2f normal1 = calculateEdgeNormal(handle1);
            ofVec2f normal2 = calculateEdgeNormal(handle2);
            
            float angle1;
            float angle2;
            
            if(normal1.angle(normal2) < 0){
                angle1 = normal1.angle(pDir);
                angle2 = normal2.angle(pDir);
            } else {
                angle2 = normal1.angle(pDir);
                angle1 = normal2.angle(pDir);                
            }
            
        //    cout<<angle1<<"  "<<angle2<<endl;
        
            if(fabs(angle1) < fabs(angle2)){
                return handle1;
            } else {
                return handle2;
            }
        }
    }
/*    vector< vector<Arrangement_2::Halfedge_const_handle> > points = [self boundaryHandles];
    for(int i=0;i<points.size();i++){
        
    }
  */  
    return Arrangement_2::Halfedge_const_handle();
    
}

/*
 -(vector< Arrangement_2::Vertex_handle>) hullHandles{
 Arrangement_2 output;
 @synchronized(self)
 {
 output.assign(*arr);
 }    
 vector<Arrangement_2::Halfedge_handle> deleteHandles;
 
 Arrangement_2::Edge_iterator eit = output.edges_begin();
 
 for( ; eit != output.edges_end(); ++eit){
 if(!eit->face()->is_unbounded() && !eit->twin()->face()->is_unbounded()){
 deleteHandles.push_back(eit);
 }
 }
 
 for(int i=0;i<deleteHandles.size();i++){
 output.remove_edge(deleteHandles[i], false, false);
 }
 
 vector< Polygon_2> ret = vector< Polygon_2>();
 ret.clear();
 
 Arrangement_2::Face_iterator fit = output.faces_begin();
 for( ; fit != output.faces_end(); ++fit){
 Polygon_2 p;
 
 if(fit->number_of_outer_ccbs() == 1){
 
 Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
 Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
 do { 
 p.push_back(hc->source()->point());
 ++hc; 
 } while (hc != ccb_start); 
 }
 
 if(!p.is_empty())
 ret.push_back(p);
 }
 return ret;
 }
 */
#pragma mark Search Functions

// should be implemented as in:
// http://www.cgal.org/Manual/3.3/doc_html/cgal_manual/Arrangement_2/Chapter_main.html#Subsection_20.3.1

-(CGAL::Object) cgalObjectAtPoint:(Point_2) queryPoint{
    
    @synchronized(self)
    {
        typedef CGAL::Arr_landmarks_point_location<Arrangement_2>  Landmarks_pl;
        
        Landmarks_pl     pl;
        
        pl.attach (*arr);
        
        // Perform the point-location query.
        CGAL::Object obj = pl.locate (queryPoint);
        
        { /** DEBUG BEGIN
           
           Arrangement_2::Vertex_const_handle    v;
           Arrangement_2::Halfedge_const_handle  e;
           Arrangement_2::Face_const_handle      f;
           
           // std::cout << "The point " << queryPoint << " is located ";
           if (CGAL::assign (f, obj)) {
           // q is located inside a face:
           if (f->is_unbounded())
           std::cout << "inside the unbounded face." << std::endl;
           else
           std::cout << "inside a bounded face." << std::endl;
           }
           else if (CGAL::assign (e, obj)) {
           // q is located on an edge:
           std::cout << "on an edge: " << e->curve() << std::endl;
           }
           else if (CGAL::assign (v, obj)) {
           // q is located on a vertex:
           if (v->is_isolated())
           std::cout << "on an isolated vertex: " << v->point() << std::endl;
           else
           std::cout << "on a vertex: " << v->point() << std::endl;
           }
           else {
           CGAL_assertion_msg (false, "Invalid object.");
           }
           
           //DEBUG END **/ }
        
        return obj;
    }
}

-(Arrangement_2::Vertex_const_handle) vertexAtPoint: (Point_2) queryPoint{
    CGAL::Object obj = [self cgalObjectAtPoint:queryPoint];
    
    Arrangement_2::Vertex_const_handle    v;
    
    if (CGAL::assign (v, obj)) {
        return v; // this will be a valid vertex handle
    }
    return v; 
    // this is a default vertex handle, with pointers to NULL, 
    // ALLWAYS check for v.is_valid() before assuming you've got something 
}


-(Arrangement_2::Halfedge_const_handle) halfedgeAtPoint: (Point_2) queryPoint{
    CGAL::Object obj = [self cgalObjectAtPoint:queryPoint];
    
    Arrangement_2::Halfedge_const_handle  e;
    
    if (CGAL::assign (e, obj)) {
        return e; // this will be a valid halfedge
    }
    return e; // this will be a default halfedge, with pointers to NULL, 
    // ALLWAYS check if e.is_fictitious() before assuming you've got something
}

-(Arrangement_2::Face_const_handle) faceAtPoint: (ofVec2f) queryPoint{
    Point_2 p = Point_2(queryPoint.x, queryPoint.y);
    CGAL::Object obj = [self cgalObjectAtPoint:p];
    
    Arrangement_2::Face_const_handle      f;
    
    if (CGAL::assign (f, obj)) {
        return f; // this will be a valid face
    }
    return f; // this will be a default face, with pointers to NULL, 
    // ALLWAYS check for f.is_valid() before assuming you've got something
}



//
//-------------
//

-(void) saveArrangement:(int)num{
    @synchronized(self)
    {
        std::ofstream    out_file (("../../../../../arrangements/arr"+ofToString(num)+".dat").c_str());
        
        out_file << *arr;
        out_file.close();
    }
}

//
//-------------
//

-(void) loadArrangement:(int)num{
    @synchronized(self)
    {
        arr = new Arrangement_2();
        
        std::ifstream    in_file (("../../../../../arrangements/arr"+ofToString(num)+".dat").c_str());
        
        if(in_file.good()){
            in_file >> *arr;
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSString *question = @"No file to load!";
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert setMessageText:@"Error!"];
                [alert setInformativeText:question];
                //    [alert addButtonWithTitle:cancelButton];
                
                [alert runModal];
                [alert release];
                alert = nil;
            }];
            
        }
        in_file.close();
    }
}

//
//-------------
//

-(void) clearArrangement{
    [self setArrData:new Arrangement_2()];
}



#pragma mark Enumerators

-(void) enumerateVertices:(void(^)(Arrangement_2::Vertex_iterator vit, BOOL * stop))func {
    Arrangement_2::Vertex_iterator vit;
    vit = arr->vertices_begin();        
    BOOL stop = NO;
    for ( ; vit !=arr->vertices_end(); ++vit) {
        func(vit, &stop);
        if(stop){
            cout<<"Stop"<<endl;
            break;
        }
    }
}


-(void) enumerateEdges:(void(^)(Arrangement_2::Edge_iterator eit))func {
    Arrangement_2::Edge_iterator eit;    
    eit = arr->edges_begin();        
    for ( ; eit != arr->edges_end(); ++eit) {
        func(eit);
    }
}

-(void) enumerateHalfedges:(void(^)(Arrangement_2::Halfedge_iterator eit))func {
    Arrangement_2::Halfedge_iterator hit;    
    hit = arr->halfedges_begin();
    for ( ; hit != arr->halfedges_end(); ++hit) {
        func(hit);
    }
}

-(void) enumerateFaces:(void(^)(Arrangement_2::Face_iterator fit))func {
    Arrangement_2::Face_iterator fit = arr->faces_begin();
    for ( ; fit !=arr->faces_end(); ++fit) {        
        if(!fit->is_fictitious()){
            if(fit->number_of_outer_ccbs() == 1){
                func(fit);
            }
        }
    }
}

-(void) enumerateFaceEdges:(void(^)(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit))func {
    Arrangement_2::Face_iterator fit = arr->faces_begin();
    for ( ; fit !=arr->faces_end(); ++fit) {        
        if(!fit->is_fictitious()){
            if(fit->number_of_outer_ccbs() == 1){
                Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                do { 
                    func(hc, fit);
                } while (++hc != ccb_start); 
            }            
        }
    }
}


@end
