//
//  PolyInputRandomGenerator.m
//  Livingroom
//
//  Created by Livingroom on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolyInputRandomGenerator.h"

@implementation PolyInputRandomGenerator

- (id)init {
    self = [super init];
    if (self) {
        [self addPropF:@"numPoints"];
        [self addPropF:@"generate"];
        
    }
    return self;
}

-(void)update:(NSDictionary *)drawingInformation{
    if(PropF(@"generate") > 0){
        [Prop(@"generate") setIntValue:0];
        [self generate];
    }
}

-(void) generate {
    cout<<"Generate"<<endl;
    
    Delaunay dt;
    
    /*
    CGAL::Random_points_in_square_2<Delaunay::Point,Creator> g(0.5);    
    CGAL::copy_n( g, PropI(@"numPoints"), std::back_inserter(dt));*/
    
    for(int i=0;i<PropI(@"numPoints"); i++){
        dt.push_back(Point_2(ofRandom(0,1), ofRandom(0,1)));
    }


    Delaunay::Finite_faces_iterator vit = dt.finite_faces_begin();
    for( ; vit != dt.finite_faces_end(); ++vit){     
        for(int i=0;i<3;i++){
            CGAL::insert(*[[engine arrangement] arrData],  dt.segment(vit, i));
        }
    }
//    dt.insert(convexPolygons[i].vertices_begin(), 
  //            convexPolygons[i].vertices_end());
}
@end
