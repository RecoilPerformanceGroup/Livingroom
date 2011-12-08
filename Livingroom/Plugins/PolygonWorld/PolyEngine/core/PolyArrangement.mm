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
@synthesize arr;

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


- (Arrangement_2 *)arr
{
    @synchronized(self)
    {
        return arr;
    }
}
- (void)setSomeRect:(Arrangement_2 *)aArr
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

#pragma mark Search Functions

// should be implemented as in:
// http://www.cgal.org/Manual/3.3/doc_html/cgal_manual/Arrangement_2/Chapter_main.html#Subsection_20.3.1

-(CGAL::Object) cgalObjectAtPoint:(Point_2) queryPoint{
    
    @synchronized(self)
    {

        if(arr->is_valid()){
            
            typedef CGAL::Arr_landmarks_point_location<Arrangement_2>  Landmarks_pl;
            
            Landmarks_pl     pl;
            
            pl.attach (*arr);
            
            // Perform the point-location query.
            CGAL::Object obj = pl.locate (queryPoint);
            
            Arrangement_2::Vertex_const_handle    v;
            Arrangement_2::Halfedge_const_handle  e;
            Arrangement_2::Face_const_handle      f;
            
            // std::cout << "The point " << queryPoint << " is located ";
            if (CGAL::assign (f, obj)) {
                // q is located inside a face:
                if (f->is_unbounded())
                    ;//    std::cout << "inside the unbounded face." << std::endl;
                else
                    ;//    std::cout << "inside a bounded face." << std::endl;
                return obj;
            }
            else if (CGAL::assign (e, obj)) {
                // q is located on an edge:
                // std::cout << "on an edge: " << e->curve() << std::endl;
                return obj;
            }
            else if (CGAL::assign (v, obj)) {
                // q is located on a vertex:
                if (v->is_isolated())
                    ;//    std::cout << "on an isolated vertex: " << v->point() << std::endl;
                else
                    ;//    std::cout << "on a vertex: " << v->point() << std::endl;
                return obj;
            }
            else {
                CGAL_assertion_msg (false, "Invalid object.");
                return;
            }
            
        }
    }
    
}


//
//-------------
//

-(void) saveArrangement{
    std::ofstream    out_file ("arr_ex_io.dat");
    
    out_file << *arr;
    out_file.close();
}

//
//-------------
//

-(void) loadArrangement{
    arr = new Arrangement_2();
    
    std::ifstream    in_file ("arr_ex_io.dat");
    
    in_file >> *arr;
    in_file.close();
    
}

@end
