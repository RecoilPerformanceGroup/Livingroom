//
//  PolyRenderSimpleWireframe.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyRenderSimpleWireframe.h"
@implementation PolyRenderSimpleWireframe

-(void)controlDraw:(NSDictionary *)drawingInformation{
    ofSetColor(255,0,0);
    
    
    

    
    glPointSize(5);
    glBegin(GL_POINTS);
    Arrangement_2::Vertex_iterator vit = [[engine data] arr]->vertices_begin();    
    for ( ; vit !=[[engine data] arr]->vertices_end(); ++vit) {
        glVertex2d(vit->point().x() , vit->point().y());

    }    
    glEnd();   
    
    ofSetColor(0,255,0);
    glBegin(GL_LINES);
    Arrangement_2::Edge_iterator eit = [[engine data] arr]->edges_begin();    
    
    for ( ; eit !=[[engine data] arr]->edges_end(); ++eit) {
        glVertex2d(eit->source()->point().x() , eit->source()->point().y());
        glVertex2d(eit->target()->point().x() , eit->target()->point().y());
    }      
   
    glEnd();   
    
    glPointSize(1);
}

@end
