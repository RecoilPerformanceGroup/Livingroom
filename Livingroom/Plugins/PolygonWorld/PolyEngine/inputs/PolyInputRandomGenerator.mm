//
//  PolyInputRandomGenerator.m
//  Livingroom
//
//  Created by Livingroom on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolyInputRandomGenerator.h"
#import "Mask.h"

@implementation PolyInputRandomGenerator

- (id)init {
    self = [super init];
    if (self) {
        [self addPropF:@"numPoints"];
        [self addPropF:@"generate"];
        [self addPropF:@"deleteLength"];        
        [self addPropF:@"triangleFilter"];        
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
    
    
    
    //Trip around boundary and delete it
    
    CachePropF(deleteLength);
    
    for(int i=0;i<10;i++){
        vector< vector<Arrangement_2::Halfedge_const_handle> > v = [[engine arrangement] boundaryHandles];
        for(int i=0;i<v.size();i++){
            for(int u=0;u<v[i].size();u++){
                Halfedge_handle h= [[engine arrangement] arrData]->non_const_handle(v[i][u]);
                if(edgeLength(h) > deleteLength)
                    [[engine arrangement] arrData]->remove_edge(h);
            }
        }
    }
    
    if(PropB(@"triangleFilter")){
        __block vector< Halfedge_handle > deleteHandles;
        
        ofVec2f corner1 = [GetPlugin(Mask) triangleFloorCoordinate:0];
        ofVec2f corner2 = [GetPlugin(Mask) triangleFloorCoordinate:1];
        
        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
            ofVec2f v1 = handleToVec2(eit->source()); 
            ofVec2f v2 = handleToVec2(eit->target());
            
            bool added = false;
            if(v1.x > corner1.x && v1.x < corner2.x){
                if(v1.y < corner1.y){
                    deleteHandles.push_back( eit);
                    added = true;
                }
            }
            if(!added && v2.x > corner1.x && v2.x < corner2.x){
                if(v2.y < corner1.y){
                    deleteHandles.push_back( eit);
                }
            }

        }];
        
        for(int i=0;i<deleteHandles.size();i++){
            [[engine arrangement] arrData]->remove_edge(deleteHandles[i]);
        }
    }
    
    
}
@end
