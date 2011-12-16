//
//  PolyAnimatorSprings.m
//  Livingroom
//
//  Created by Livingroom on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <CGAL/distance_predicates_2.h>


#import "PolyAnimatorSprings.h"

@implementation PolyAnimatorSprings

-(void)update:(NSDictionary *)drawingInformation{
    Arrangement_2::Vertex_iterator vit = [[engine arrangement] arrData]->vertices_begin();        
    for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
        vit->data().springF = ofVec2f(0,0);
    }
    
    Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();        
    for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
        //Constructor
        if(eit->data().springOptimalLength == -1){
            ofVec2f source = point2ToVec2(eit->source()->point());
            ofVec2f target = point2ToVec2(eit->target()->point());
            eit->data().springOptimalLength = source.distance(target);
            
            //            cout<<squared_distance(eit->source()->point(), eit->target()->point())<<endl;
        }
    }
    
    //Mouse force
    if(mousePressed){
        float mouseR = 0.3;
        float mouseF = 0.05;
        vit = [[engine arrangement] arrData]->vertices_begin();        
        for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
            if(mouse.distance(point2ToVec2(vit->point())) < mouseR){
                ofVec2f vertex = point2ToVec2(vit->point());
                ofVec2f v = vertex - mouse;
                
                float l = v.length();
                l *= 1.0/mouseR;
                l = 1.0-l;
                
                v.normalize();
                
                vit->data().springF += v*mouseF*l;            
            }
        }
    }
    
    for(int i=0;i<2;i++){
        //Spring force
        eit = [[engine arrangement] arrData]->edges_begin();        
        for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
            ofVec2f source = point2ToVec2(eit->source()->point());
            ofVec2f target = point2ToVec2(eit->target()->point());
            
            float length = source.distance(target);        
            float optimalLength = eit->data().springOptimalLength;
            
            ofVec2f v = source-target;
            v.normalize();
            
            v *= (length - optimalLength);
            
            eit->source()->data().springF += -v * 0.1;
            eit->target()->data().springF +=  v * 0.1;
        }
        
        //Vertex update
        vit = [[engine arrangement] arrData]->vertices_begin();        
        for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
            vit->data().springV *= 0.8;

            vit->data().springV += vit->data().springF * 0.002;
            
            vit->point() =   Arrangement_2::Point_2(vit->data().springV.x + vit->point().x(), 
                                                    vit->data().springV.y + vit->point().y());
        }
    }
}


-(void)draw:(NSDictionary *)drawingInformation{
   // ofBackground(255);
   // glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
    
    Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();        
    for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
        
        float diff = 0;
        if(fit->number_of_outer_ccbs() == 1){
            glBegin(GL_POLYGON);
            
            Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
            Arrangement_2::Ccb_halfedge_circulator hc = ccb_start;        
            int i=0;
            do { 
                ofVec2f source = point2ToVec2(hc->source()->point());
                ofVec2f target = point2ToVec2(hc->target()->point());
                
                float length = source.distance(target);        
                float optimalLength = hc->data().springOptimalLength;
                
                if(optimalLength == -1){
                    
                    optimalLength = hc->twin()->data().springOptimalLength;
                }
                diff += fabs(length-optimalLength);
                
                i++;
                ++hc; 
            } while (hc != ccb_start); 
            
           // float c = 1.0 - diff*30.0/i;
          //    float c = 0.1+diff*30.0/i;
           float c = -0.1+diff*10.0/i;
            
            //cout<<diff*100.0/i<<endl;
            glColor3f(c,c,c);
            
            hc = ccb_start;        
            do { 
                glVertex2d(CGAL::to_double( hc->source()->point().x()), CGAL::to_double(hc->source()->point().y()));            
                ++hc; 
            } while (hc != ccb_start); 
            
            glEnd();
            
        }
    }

}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);

    /*Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();        
    for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
        
        float diff = 0;
        if(fit->number_of_outer_ccbs() == 1){
            glBegin(GL_POLYGON);

            Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
            Arrangement_2::Ccb_halfedge_circulator hc = ccb_start;        
            int i=0;
            do { 
                ofVec2f source = pointToVec(hc->source()->point());
                ofVec2f target = pointToVec(hc->target()->point());
                
                float length = source.distance(target);        
                float optimalLength = hc->data().springOptimalLength;
                
                if(optimalLength == -1){
                
                    optimalLength = hc->twin()->data().springOptimalLength;
                }
                diff += fabs(length-optimalLength);
                
                i++;
                ++hc; 
            } while (hc != ccb_start); 
            
            float c = 1.0 - diff*10.0/i;
            
            cout<<diff*100.0/i<<endl;
            glColor3f(c,c,c);
            
            hc = ccb_start;        
            do { 
                glVertex2d(CGAL::to_double( hc->source()->point().x()), CGAL::to_double(hc->source()->point().y()));            
                ++hc; 
            } while (hc != ccb_start); 
            
            glEnd();
            
        }
    }*/
    
    /*  glBegin(GL_POINTS);
     Arrangement_2::Vertex_iterator vit = [[engine arrangement] arrData]->vertices_begin();        
     for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
     float a = 255-vit->data().springF.length()*255.0;
     glColor3f(255,a,a);
     glVertex2f(CGAL::to_double(vit->point().x()), CGAL::to_double(vit->point().y()));
     }
     glEnd();*/
    
}

- (void) controlMousePressed:(float) x y:(float)y button:(int)button{
    mousePressed = YES;
    mouse = ofVec2f(x,y);    
}
- (void) controlMouseReleased:(float) x y:(float)y{
    mousePressed = NO;
}

-(void)controlMouseDragged:(float)x y:(float)y button:(int)button{
    mouse = ofVec2f(x,y);    
}



@end
