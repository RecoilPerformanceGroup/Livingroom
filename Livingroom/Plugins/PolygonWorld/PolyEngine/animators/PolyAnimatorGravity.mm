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
        
        [self addPropF:@"tracker"];  
        
        [self addPropF:@"offsetX"];  
        [self addPropF:@"offsetY"];  
        
        [[self addPropF:@"midiInput"] setMidiSmoothing:0.95];
        [Prop(@"midiInput") setMidiNumber:[NSNumber numberWithInt:8]];
        [Prop(@"midiInput") setForcedMidiNumber:YES];
        
        [[self addPropF:@"midiInputLevel"] setMidiSmoothing:0.95];
        
    }
    return self;
}

-(void)reset{
    SetPropF(@"fallingTime", 0);
    
}

-(void)update:(NSDictionary *)drawingInformation{
    //
    // Tracker Gravity
    //
    
    CachePropF(tracker);
    vector<ofVec2f> centroids;
    if(tracker){
        centroids = [GetPlugin(Tracker) trackerFeetVector];
    } else {
        centroids.push_back(ofVec2f(0.5,0.5));
    }
    
    for(int i=0;i<gravityTrackerPoints.size();i++){
        if(tracker){
        gravityTrackerPoints[i].z *= 0;        
        } else {
        gravityTrackerPoints[i].z *= 0.9;
        }
    }
    
    for(int i=0;i<centroids.size();i++){
        if(centroids[i].x > 0){
            if(gravityTrackerPoints.size() <= i){
                gravityTrackerPoints.push_back(ofVec3f(centroids[i].x, centroids[i].y,0));
            }
            gravityTrackerPoints[i] += (ofVec3f(centroids[i].x, centroids[i].y,1)-gravityTrackerPoints[i])*tracker;
        }
//        cout<<gravityTrackerPoints[i].x<<"  "<<gravityTrackerPoints[i].y<<"  "<<gravityTrackerPoints[i].z<<endl;
        
    }
    

    float f = PropF(@"trackerForce") + PropF(@"midiInput")*PropF(@"midiInputLevel");
    
    if(tracker && f > 0 && centroids.size() > 0){
        [GetPhysics() addPhysicsBlock:@"TrackerGravity" block:^(PolyArrangement *arrangement) {
            
            float dist = PropF(@"trackerRadius");
            
            if(f > 0){
                [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                    for(int i=0; i<gravityTrackerPoints.size();i++){
                        if(gravityTrackerPoints[i].z > 0.01){
                            ofVec3f centroid = gravityTrackerPoints[i] + ofVec3f(PropF(@"offsetX"), PropF(@"offsetY"),0);
                            ofVec2f centroid2d = ofVec2f(gravityTrackerPoints[i].x, gravityTrackerPoints[i].y) + ofVec3f(PropF(@"offsetX"), PropF(@"offsetY"));
                            
                            float _dist = centroid2d.distance( handleToVec2(vit) ) ;
                            if(_dist < dist){
                                float _f = f*(dist - _dist)/dist;
                                //      float _f = f*(1/_dist);
                                if(tracker == 1){
                                    vit->data().springF += ofVec3f(0,0,_f);                        
                                } else {
                                    vit->data().springF += centroid.z*ofVec3f(0,0,_f);                        

                                }
                            }
                        }
                    }
                }];
                
                
            }        
        }];
    }
        
    if(!tracker && f > 0){
        [GetPhysics() addPhysicsBlock:@"CenterGravity" block:^(PolyArrangement *arrangement) {
            
            float dist = PropF(@"trackerRadius");
            
            [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                        ofVec2f centroid = centroids[0] + ofVec2f(PropF(@"offsetX"), PropF(@"offsetY"));
                        
                        float _dist = centroid.distance( handleToVec2(vit) ) ;
                        if(_dist < dist){
                            float _f = f*(dist - _dist)/dist;
                            //      float _f = f*(1/_dist);
                            vit->data().springF += ofVec3f(0,0,_f);                        
                        }
            }];
            
            
        }];
    }
    
    
    //
    // Falling Gravity
    //
    float fallingForce = PropF(@"fallingForce");
    float fallingTime = PropF(@"fallingTime");
    if(fallingForce > 0){
        [GetPhysics() addPhysicsBlock:@"Falling Gravity" block:^(PolyArrangement *arrangement) {
            [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                vit->data().springF += ofVec3f(0,0,fallingForce); 
                
                float fallDist = 1.0-fallingTime;
                
                if(fallingTime == 0){
                    vit->data().fallingFloorLock = 1.0;
                }
                
                //Distance to center
                float centDist = ofVec2f(0.5,0.5).distance(handleToVec2(vit));
                if(centDist > fallDist){
                    vit->data().fallingFloorLock = 0.0;
                } 
            }];
        }];
        
    }
}
@end
