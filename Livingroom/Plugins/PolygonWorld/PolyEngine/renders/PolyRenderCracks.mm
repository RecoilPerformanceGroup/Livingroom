//
//  PolyRenderCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyRenderCracks.h"

@implementation PolyRenderCracks

-(void)draw:(NSDictionary *)drawingInformation{
    
    ofEnableAlphaBlending();
    
    ofSetColor(255,255,255,255);
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);

    ofRect(0,0,1,1);

    Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();    
    
    for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
        
        ofSetColor(0,0,0,255*eit->data().crackAmount);

        ofSetLineWidth(eit->data().crackAmount*20);

        glBegin(GL_LINES);

        glVertex2d(CGAL::to_double(eit->source()->point().x()) , CGAL::to_double(eit->source()->point().y()));
        glVertex2d(CGAL::to_double(eit->target()->point().x()) , CGAL::to_double(eit->target()->point().y()));
        
        glEnd();
                
    }      

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
