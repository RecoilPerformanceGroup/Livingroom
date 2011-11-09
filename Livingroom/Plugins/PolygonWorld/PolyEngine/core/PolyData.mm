//
//  PolyData.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyData.h"
#include <CGAL/convex_hull_2.h>



@implementation PolyData
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
-(vector< vector<Point_2> >) hulls{
   /* Arrangement_2 output;
    output.assign(*arr);
    
    Arrangement_2::Edge_iterator eit = arr->edges_begin();
    
    int i=0;
    for( ; eit != arr->edges_end(); ++eit){
        if(!eit->face()->is_unbounded() && !eit->twin()->face()->is_unbounded()){
            
        }
        
        cout<<i++<<endl;
    }
    
    
    return vector< vector<Point_2> >();*/
}


@end
