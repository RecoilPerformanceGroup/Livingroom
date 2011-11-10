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
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);

    
    ofSetColor(0,255,0);
    Arrangement_2::Face_iterator fit = [[engine data] arr]->faces_begin();    
    
    for ( ; fit !=[[engine data] arr]->faces_end(); ++fit) {
        ofSetColor(0,0,255);
        glBegin(GL_POLYGON);
        
        if(!fit->is_fictitious()){
            if(fit->number_of_outer_ccbs() == 1){
                Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                do { 
                    glVertex2d(hc->source()->point().x() , hc->source()->point().y());
                    ++hc; 
                } while (hc != ccb_start); 
            }            
        }
        
        //        
        glEnd();   
        
    }      
    
    
    ofSetColor(0,255,0);
    glBegin(GL_LINES);
    Arrangement_2::Edge_iterator eit = [[engine data] arr]->edges_begin();    
    
    for ( ; eit !=[[engine data] arr]->edges_end(); ++eit) {
        glVertex2d(eit->source()->point().x() , eit->source()->point().y());
        glVertex2d(eit->target()->point().x() , eit->target()->point().y());
    }      
    
    glEnd();   
    
    glPointSize(1);
    
    
    ofSetColor(255,0,0);
    glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);

    vector< Polygon_2> hull = [[engine data] hulls];
    
    for(int i=0;i<hull.size();i++){
        
        glBegin(GL_POLYGON);
        Polygon_2::Vertex_iterator vit = hull[i].vertices_begin();
        for( ; vit != hull[i].vertices_end(); ++vit){
            glVertex2d(vit->x(), vit->y());
        }
        glEnd();
    }
}

@end
