//
//  PolyAnimatorCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyAnimatorCracks.h"
#import <ofxCocoaPlugins/Midi.h>
struct VectorSortP {
    bool operator()(Arrangement_2::Halfedge_around_vertex_circulator a, Arrangement_2::Halfedge_around_vertex_circulator b) const {
        return a->data().crackCacheRatio < b->data().crackCacheRatio;
    }
};


@implementation PolyAnimatorCracks


-(id)init{
    if(self = [super init]){
        [self addPropF:@"active"];
        
        [[self addPropF:@"pressure"] setMaxValue:100];
        
        [self addPropF:@"overflowThreshold"];
        [self addPropF:@"overflowSpeed"];
        [[self addPropF:@"impulse"] setMaxValue:128];

    }
    
    return self;
}

-(void)setup{
    [[[GetPlugin(Midi) midiData] objectAtIndex:1] addObserver:self forKeyPath:@"noteon48" options:0 context:@"midi"];
    [[[GetPlugin(Midi) midiData] objectAtIndex:1] addObserver:self forKeyPath:@"noteoff48" options:0 context:@"midioff"];

}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([(NSString*)context isEqualToString:@"midi"]){
        cout<<"Impiulse "<<[[object valueForKey:@"noteon48"] intValue]<<endl;
        SetPropF(@"impulse", [[object valueForKey:@"noteon48"] intValue]);
    }
  //  if([(NSString*)context isEqualToString:@"midioff"]){
//        SetPropF(@"impulse", 0);
//    }
}
-(void)update:(NSDictionary *)drawingInformation{
    
    //Reset
    /*[[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
     vit->data().crackDir = ofVec2f();
     vit->data().crackAmount = 0;
     }];
     */        
    
    //avarage halfedges
    
    CachePropF(impulse);
    
    if(impulse > 0){
        SetPropF(@"impulse",0);
        
        
        float active = PropF(@"active");
        float pressure = PropF(@"pressure")*impulse/128.0;
        float overflowTheshold = PropF(@"overflowThreshold");
        float overflowSpeed = PropF(@"overflowSpeed");    
        
        if(active > 0){
            
            [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
                if(eit->twin()->data().crackAmount > overflowTheshold || eit->data().crackAmount > overflowTheshold){
                    float avg = (eit->twin()->data().crackAmount +  eit->data().crackAmount) * 0.5;
                    eit->twin()->data().crackAmount = eit->data().crackAmount = avg;
                }
            }];
            
            
            //Tracker
            vector<ofVec2f> v = [GetTracker() getTrackerCoordinates];        
            [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                for(int t=0;t<v.size();t++){
                    if(v[t].distance(handleToVec2(vit)) < 0.02){
                        Arrangement_2::Halfedge_around_vertex_circulator first, curr;
                        first = curr = vit->incident_halfedges();
                        //do {
                        curr->data().crackAmount += pressure;
                        curr++;
                        curr++;
                        curr++;
                        curr++;
                        curr++;
                        curr->data().crackAmount += pressure;
                        //} while (++curr != first);
                        
                    }
                }
            }];
            
            
            
            [[engine arrangement] enumerateHalfedges:^(Arrangement_2::Halfedge_iterator eit) {
                //        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
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
                    vector<Arrangement_2::Halfedge_around_vertex_circulator> ratios;
                    int crackCount = 0;
                    
                    Arrangement_2::Halfedge_around_vertex_circulator first, curr;             
                    first = curr = h2->incident_halfedges();
                    do {
                        if((Arrangement_2::Halfedge_handle) curr != eit){
                            // Note that the current halfedge is directed from u to h1:
                            Arrangement_2::Vertex_handle u = curr->source(); 
                            ofVec2f odir = handleToVec2(u) - handleToVec2(h2);
                            //odir.normalize();         
                            float ratio = fabs((odir).angle(dir));
                            ratio = 1.0/ratio;
                            
                            curr->data().crackCacheRatio = ratio;
                            crackRatioTotal += ratio;
                            
                            if(press > ofRandom(3.3,30) && h2->data().crackEdgeCount < 3){
                                h2->data().crackEdgeCount ++;
                            }
                            
                            //Determine if this edge is interesting at all
                            if(curr->face()->is_unbounded() || curr->twin()->face()->is_unbounded()){
                                //Edge is not OK
                            } else if(ratio < 1.0/50 && press < 3.0){
                                //Angle not OK
                            } else if(ratio < 1.0/90 && press < 5.0){
                                //Angle not OK
                            } else if(ratio < 1.0/170){
                                //Angle not OK
                            } else { 
                                ratios.push_back(curr);
                            }
                        }
                        
                        if(curr->data().crackAmount > 0){
                            crackCount ++;
                        }
                        
                    } while (++curr != first);
                    
                    //Sort ratios               
                    sort(ratios.begin(), ratios.end(), VectorSortP());
                    
                    
                    //Crack while crackcount is to low
                    while (ratios.size() > 0) {                            
                        if(ratios[ratios.size()-1]->data().crackAmount < crackAmm){
                            //Hvis den allerede er revnet lidt, eller der ikke er cracked nok
                            if(ratios[ratios.size()-1]->data().crackAmount > 0 
                               || crackCount < h2->data().crackEdgeCount){
                                
                                if(ratios[ratios.size()-1]->data().crackAmount == 0){
                                    crackCount ++;
                                }
                                
                                float amm = overflowSpeed*press * ratios[ratios.size()-1]->data().crackCacheRatio / crackRatioTotal;
                                ratios[ratios.size()-1]->data().crackAmount += amm;
                                eit->data().crackAmount -= amm;
                                
                            }
                            
                        }
                        ratios.pop_back();                            
                        
                    } ;
                    
                    
                    //                //Flow
                    //                first = curr = h2->incident_halfedges();
                    //                do {
                    //                    if((Arrangement_2::Halfedge_handle) curr != eit){
                    //                        if(curr->data().crackAmount < crackAmm){
                    //                            curr->data().crackAmount +=  overflowSpeed*press * curr->data().crackCacheRatio / crackRatioTotal;
                    //                            eit->data().crackAmount -= overflowSpeed*press * curr->data().crackCacheRatio / crackRatioTotal;
                    //                        }
                    //                    }
                    //                } while (++curr != first);
                    //                
                    
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
            
            
            //Calculate vertices
            [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                vit->data().crackAmount = 0;
                vit->data().crackEdgeCount = 0;
                
                Arrangement_2::Halfedge_around_vertex_circulator first, curr;
                first = curr = vit->incident_halfedges();
                do{
                    if(curr->data().crackAmount > 0){
                        vit->data().crackAmount += curr->data().crackAmount;
                        vit->data().crackEdgeCount ++;
                    }
                } while(++curr != first);
            }];
        }
        

    }
    
}



- (void) controlKeyPressed:(int)_key modifier:(int)modifier{
    NSLog(@"Key %i",_key);
    
    if(_key == 49){
        SetPropF(@"impulse", 128);
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
