//
//  PolyInputSimpleMouse.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Partition_traits_2.h>
#include <CGAL/Partition_is_valid_traits_2.h>
#include <CGAL/polygon_function_objects.h>
#include <CGAL/partition_2.h>
#include <CGAL/Delaunay_triangulation_2.h>


#import "PolyInput.h"



typedef CGAL::Partition_traits_2<Kernel>    PartTraits;
typedef PartTraits::Polygon_2               PartPolygon_2;
typedef CGAL::Delaunay_triangulation_2<Traits_2>  Delaunay;



@interface PolyInputSimpleMouse : PolyInput{
    vector<Point_2> pointsBuffer;
    
    vector<PartPolygon_2> convexPolygons;
    vector<Delaunay> delauneys;

}

@end
