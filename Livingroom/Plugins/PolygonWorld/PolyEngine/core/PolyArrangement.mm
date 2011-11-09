//
//  PolyArrangement.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyArrangement.h"
#include <CGAL/convex_hull_2.h>



@implementation PolyArrangement
@synthesize arr;

-(id)init{
    if(self = [super init]){
        arr = new Arrangement_2;
    }
    return self;
}

//
//-----------
//

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
    output.assign(*arr);
    
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


@end
