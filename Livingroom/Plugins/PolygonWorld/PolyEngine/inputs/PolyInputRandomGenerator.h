//
//  PolyInputRandomGenerator.h
//  Livingroom
//
//  Created by Livingroom on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolyInput.h"

#include <CGAL/Constrained_Delaunay_triangulation_2.h>
#include <CGAL/point_generators_2.h>


typedef CGAL::Constrained_Delaunay_triangulation_2<Kernel>  Delaunay;
typedef CGAL::Creator_uniform_2<double,Delaunay::Point>            Creator;


@interface PolyInputRandomGenerator : PolyInput {
    
}

-(void) generate;

@end
