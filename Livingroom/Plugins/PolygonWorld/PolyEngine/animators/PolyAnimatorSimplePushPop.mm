//
//  PolyAnimatorSimplePushPop.m
//  Livingroom
//
//  Created by Livingroom on 09/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyAnimatorSimplePushPop.h"

@implementation PolyAnimatorSimplePushPop
-(void)update:(NSDictionary *)drawingInformation{
    float v = 99.2;
    
    vector<Arrangement_2::Halfedge_handle> deleteHandles;
    
    Arrangement_2::Face_iterator fit = [[engine arrangement] arr]->faces_begin();    
    for ( ; fit !=[[engine arrangement] arr]->faces_end(); ++fit) {
        if(fit->number_of_outer_ccbs() == 1){
            
            if(ofRandom(0,100) > v){
                BOOL canDelete = NO;
                int threeCount = 0;
                int fiveCount = 0;
                int i=0;
                
                Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                do { 
               //     Arrangement_2::Halfedge_around_vertex_circulator hcirc = hc->vertex()->in
                    if(hc->source()->degree() == 2 ){
                        canDelete = YES;                        
                    }
                    if(hc->source()->degree() == 3){
                        threeCount++;
                    }
                    if(hc->source()->degree() > 4){
                        fiveCount++;
                    }
                    ++hc; 
                    i++;
                } while (hc != ccb_start); 
                
            /*   if(threeCount > i/2 && fiveCount > 0)
                    canDelete = YES;
                */
                if(canDelete){
                    hc = ccb_start = fit->outer_ccb();
                    do { 
                        if(hc->twin()->face()->is_unbounded()){
                            deleteHandles.push_back(hc);
                            
                        }
                        ++hc; 
                    } while (hc != ccb_start); 
                }
            }            
        } 
        
    }
    
    for(int i=0;i<deleteHandles.size();i++){
        [[engine arrangement] arr]->remove_edge(deleteHandles[i]);
    }
    
    
    
}
@end
