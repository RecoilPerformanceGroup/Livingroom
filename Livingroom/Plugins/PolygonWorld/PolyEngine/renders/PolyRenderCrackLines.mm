//
//  PolyRenderCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyRenderCrackLines.h"
#import <ofxCocoaPlugins/CustomGraphics.h>

@implementation PolyRenderCrackLines

-(void)draw:(NSDictionary *)drawingInformation{
    ApplySurfaceForProjector(@"Floor",0);{
        
        ofEnableAlphaBlending();
        
        ofSetColor(255,255,255,255);
        
        glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
        
        ofRect(0,0,1,1);
        glLineWidth(1);
        
        Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();    
        
        for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
            float crack = eit->data().crackAmount + eit->twin()->data().crackAmount;
           // ofSetColor(255.0*crack,255.0*(1-crack),0,255);
             ofSetColor(0*crack,0,0,255.0*crack);
            
           // ofSetLineWidth(eit->data().crackAmount*2.0);
            
            Arrangement_2::Vertex_handle h1 = eit->source();
            Arrangement_2::Vertex_handle h2 = eit->target();
            
            ofLine(handleToVec2(h1).x, handleToVec2(h1).y, handleToVec2(h2).x, handleToVec2(h2).y);
            
         /*   ofVec2f dir = handleToVec2(h2) - handleToVec2(h1);
            dir.normalize();
            ofVec2f hat = ofVec2f(-dir.y, dir.x)*0.008;
            
            dir *= 0.02;
            
            of2DArrow(handleToVec2(eit->source())-hat+dir, handleToVec2(eit->target())-hat-dir, 0.015);
            
            crack = eit->twin()->data().crackAmount;
            ofSetColor(255.0*crack,255.0*(1-crack),0,255);

            
            of2DArrow(handleToVec2(eit->target())+hat-dir, handleToVec2(eit->source())+hat+dir, 0.015);*/
            
        }      
        
    }PopSurfaceForProjector();
    
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();    
    
    ofSetColor(255,255,255,128);
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
    
    for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
        
        ofCircle(CGAL::to_double(eit->source()->point().x()) , CGAL::to_double(eit->source()->point().y()), eit->data().crackAmount*0.05);
        
    }   
    
}

@end
