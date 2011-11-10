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
//    cout << "hep" << endl;
    
    Arrangement_2::Vertex_iterator vit = [[engine arrangement] arr]->vertices_begin();    
    for ( ; vit !=[[engine arrangement] arr]->vertices_end(); ++vit) {
        cout << ": " << vit->data().crackAmount << endl;
        vit->data().crackAmount+=0.1;
    } 
        
}

@end
