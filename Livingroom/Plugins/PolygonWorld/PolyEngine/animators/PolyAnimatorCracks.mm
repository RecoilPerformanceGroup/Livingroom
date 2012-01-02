//
//  PolyAnimatorCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyAnimatorCracks.h"

@implementation PolyAnimatorCracks


-(id)init{
    if(self = [super init]){
        [self addPropF:@"active"];
        
        [self addPropF:@"pressure"];
        
        [self addPropF:@"overflowThreshold"];
        [self addPropF:@"overflowSpeed"];
    }
    
    return self;
}
-(void)update:(NSDictionary *)drawingInformation{
    float active = PropF(@"active");
    float pressure = PropF(@"pressure");
    float overflowTheshold = PropF(@"overflowThreshold");
    float overflowSpeed = PropF(@"overflowSpeed");    
    
    if(active > 0){
        //Reset
        /*[[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
         vit->data().crackDir = ofVec2f();
         vit->data().crackAmount = 0;
         }];
         */        
        
        //avarage halfedges
        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
            float avg = (eit->twin()->data().crackAmount +  eit->data().crackAmount) * 0.5;
            eit->twin()->data().crackAmount = eit->data().crackAmount = avg;
        }];
        
        
        //Tracker
        vector<ofVec2f> v = [GetTracker() getTrackerCoordinates];        
        [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
            for(int t=0;t<v.size();t++){
                if(v[t].distance(handleToVec2(vit)) < 0.1){
                    Arrangement_2::Halfedge_around_vertex_circulator first, curr;
                    first = curr = vit->incident_halfedges();
                    do {
                        curr->data().crackAmount += 1.0;
                    } while (++curr != first);
                  
                }
            }
        }];
        	
        
        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
            float crackAmm = eit->data().crackAmount;
            if(crackAmm > overflowTheshold){
                float press = crackAmm - overflowTheshold;
                
                //Spred det videre
                
                Arrangement_2::Vertex_handle h1 = eit->source();
                Arrangement_2::Vertex_handle h2 = eit->target();
                
                ofVec2f dir = handleToVec2(h2) - handleToVec2(h1);
                // dir.normalize();
                
                
                //Calculate crackCacheRatio
                float crackRatioTotal = 0;
                
                Arrangement_2::Halfedge_around_vertex_circulator first, curr;
                first = curr = h1->incident_halfedges();
                do {
                    if((Arrangement_2::Halfedge_handle) curr != eit){
                        // Note that the current halfedge is directed from u to h1:
                        Arrangement_2::Vertex_handle u = curr->source(); 
                        ofVec2f odir = handleToVec2(u) - handleToVec2(h1);
                        //odir.normalize();         
                        float ratio = 1.0/fabs((odir).angle(-dir));
                        curr->data().crackCacheRatio = ratio;
                        crackRatioTotal += ratio;
                    }
                } while (++curr != first);

                first = curr = h2->incident_halfedges();
                do {
                    if((Arrangement_2::Halfedge_handle) curr != eit){
                        // Note that the current halfedge is directed from u to h1:
                        Arrangement_2::Vertex_handle u = curr->source(); 
                        ofVec2f odir = handleToVec2(u) - handleToVec2(h2);
                        //odir.normalize();         
                        float ratio = 1.0/fabs((odir).angle(-dir));
                        curr->data().crackCacheRatio = ratio;
                        crackRatioTotal += ratio;
                    }
                } while (++curr != first);
                
                
                //Flow
                first = curr = h1->incident_halfedges();
                do {
                    if((Arrangement_2::Halfedge_handle) curr != eit){
                        if(curr->data().crackAmount < crackAmm){
                            curr->data().crackAmount +=  overflowSpeed*press * curr->data().crackCacheRatio / crackRatioTotal;
                            eit->data().crackAmount -= overflowSpeed*press * curr->data().crackCacheRatio / crackRatioTotal;
                        }
                    }
                } while (++curr != first);
                
                first = curr = h2->incident_halfedges();
                do {
                    if((Arrangement_2::Halfedge_handle) curr != eit){
                        if(curr->data().crackAmount < crackAmm){
                            curr->data().crackAmount +=  overflowSpeed*press * curr->data().crackCacheRatio / crackRatioTotal;
                            eit->data().crackAmount -= overflowSpeed*press * curr->data().crackCacheRatio / crackRatioTotal;
                        }
                    }
                } while (++curr != first);

                
                /*
                 
                 eit->source()->data().crackAmount += (crackAmm - overflowTheshold)*0.5;        
                 eit->target()->data().crackAmount += (crackAmm - overflowTheshold)*0.5;    
                 
                 ofVec2f dir = handleToVec2(eit->source()) - handleToVec2(eit->target());
                 dir.normalize();
                 dir *= (crackAmm - overflowTheshold);
                 
                 eit->source()->data().crackDir += dir;
                 eit->target()->data().crackDir -= dir;*/
            }
            
        }];
    }
    
    
}



/**
 -(void)addCrackAmount:float amount toVertex: Arrangement_2::Vertex v{
 
 // add crack
 
 vit->data().crackAmount+=0.1;
 
 // if crack is > 1, distribute to the nearest halfedge with most crack
 
 if(vit->data().crackAmount > 1.0){
 
 Arrangement_2::Vertex vToPress;
 float highestPressure = 0.0;
 
 Arrangement_2::Halfedge_around_vertex_circulator eit = vit->vertex_begin();
 
 for ( ; eit !=vit->vertex_begin(); ++eit) {
 
 
 float pressure = eit->vertex()->data().crackAmount;
 if(pressure > highestPressure){
 vToPress = eit->vertex();
 }
 }
 
 // if none of the vertices were a'crackin' we pick the 'middle' one
 
 if(highestPressure == 0){
 
 int numberVertices = vit.vertex_degree ()
 
 eit = vit->vertex_begin();
 
 for ( ; eit !=vit->vertex_begin(); ++eit) {
 float pressure = eit->data().crackAmount;
 if(pressure > highestPressure){
 vToPress = eit;
 }
 }
 
 }
 
 Halfedge_around_vertex_circulator
 
 vit->vertex_begin () 
 
 
 }
 
 
 }
 
 **/

@end
