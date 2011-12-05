//
//  PolyAnimatorCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyAnimatorCracks.h"

@implementation PolyAnimatorCracks

-(void)update:(NSDictionary *)drawingInformation{
    
    Arrangement_2::Vertex_iterator vit = [[engine arrangement] arr]->vertices_begin();    
    for ( ; vit !=[[engine arrangement] arr]->vertices_end(); ++vit) {
        
//        vit->data().crackAmount+=0.1;
        
    } 
    
    Arrangement_2::Edge_iterator eit = [[engine arrangement] arr]->edges_begin();    
    
    for ( ; eit !=[[engine arrangement] arr]->edges_end(); ++eit) {
        
        eit->data().crackAmount = (eit->data().crackAmount*0.85) + (ofRandom(0.0,1.0)*.15);
      //  cout << eit->data().crackAmount << endl; 
    }      
    
    glEnd();   

        
}

@end
