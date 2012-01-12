//
//  PolyAnimatorGravity.m
//  Livingroom
//
//  Created by Livingroom on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolyAnimatorGravity.h"
#import "PolyAnimatorPhysics.h"
#import "Tracker.h"

@implementation PolyAnimatorGravity
- (id)init {
    self = [super init];
    if (self) {
        [self addPropF:@"trackerForce"];  
        [self addPropF:@"trackerRadius"];  

        [self addPropF:@"fallingTime"];  
        [self addPropF:@"fallingForce"];  

        
    }
    return self;
}

-(void)update:(NSDictionary *)drawingInformation{
    //
    // Tracker Gravity
    //
    vector<ofVec2f> centroids = [GetPlugin(Tracker) trackerCentroidVector];
    float f = PropF(@"trackerForce");

    if(f > 0 && centroids.size() > 0){
        [GetPhysics() addPhysicsBlock:@"TrackerGravity" block:^(PolyArrangement *arrangement) {
            
            float dist = PropF(@"trackerRadius");
            
            if(f > 0){
                [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                    for(int i=0; i<centroids.size();i++){
                        ofVec2f centroid = centroids[i];
                        float _dist = centroid.distance( handleToVec2(vit) ) ;
                        if(_dist < dist){
                            float _f = f*(dist - _dist)/dist;
                            vit->data().springF += ofVec3f(0,0,_f);                        
                        }
                    }
                }];
                
                
            }        
        }];
    }
    
    
    //
    // Falling Gravity
    //
    float fallingForce = PropF(@"fallingForce");
    float fallingTime = PropF(@"fallingTime");
    if(fallingForce > 0){
        [GetPhysics() addPhysicsBlock:@"Falling Gravity" block:^(PolyArrangement *arrangement) {
                [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                    vit->data().springF += ofVec3f(0,0,fallingForce); 
                    
                    float fallDist = 1.0-fallingTime;
                    
                    if(fallingTime == 0){
                        vit->data().physicsLock = 1.0;
                    }
                    
                    //Distance to center
                    float centDist = ofVec2f(0.5,0.5).distance(handleToVec2(vit));
                    if(centDist > fallDist){
                        vit->data().physicsLock = 0.0;
                    } 
                }];
        }];

    }
}
@end
