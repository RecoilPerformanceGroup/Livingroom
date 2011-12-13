//
//  PolyAnimatorCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//


#import "PolyAnimatorCrumble.h"
#import <ofxCocoaPlugins/CustomGraphics.h>

@implementation PolyAnimatorCrumble


-(id)init{
    if(self = [super init]){
        [[self addPropF:@"state"] setMaxValue:3];
        
        //        [self addPropF:@"elasticity"];
        [self addPropF:@"mouseForce"];
        
        //       [self addPropF:@"springDamping"];
        [self addPropF:@"springStrength"];
        
        [[self addPropF:@"iterations"] setMinValue:1];
    }
    
    return self;
}

#pragma mark CGAL Helpers 

//The length of the edge
static float edgeLength(Arrangement_2::Edge_iterator eit, ofVec2f * dir = nil){
    ofVec2f source = pointToVec(eit->source()->point());
    ofVec2f target = pointToVec(eit->target()->point());        
    if(dir != nil){
        *dir = source-target;
    }   
    
    return source.distance(target);   
}

//Updates the initial length for a specific edge
static void updateInitialLength(Arrangement_2::Edge_iterator eit){
    eit->data().crumbleOptimalLength = edgeLength(eit);
}

//The angle between the provided edge and its next edge. Returns also optionaly a middle dir (for straighten up)
static float edgeAngleToNext(Arrangement_2::Ccb_halfedge_circulator eit, ofVec2f * middleDir = nil){
    //Middle point
    ofVec2f middle = pointToVec(eit->target()->point());
    
    //Vectors to left and right point
    ofVec2f left = pointToVec(eit->source()->point()) - middle;
    ofVec2f right = pointToVec(eit->next()->target()->point()) - middle;
    
    float angle = left.angle(right);
    
    if(middleDir != nil){
        left.normalize();
        if(angle > 179.9){ //Special case where the line is straight
            middleDir->set(left.y, -left.x);
        } else {        
            left.rotate(angle*0.5);
            middleDir->set(left);
        }
    }
    
    return angle;
}

//Updates the initial angle for a specific edge
static void updateInitialAngle(Arrangement_2::Ccb_halfedge_circulator eit){
    eit->data().crumbleOptimalAngle = edgeAngleToNext(eit);
}



#pragma mark Common

-(void)update:(NSDictionary *)drawingInformation{
    Arrangement_2::Edge_iterator eit;    
    Arrangement_2::Vertex_iterator vit;
    Arrangement_2::Face_iterator fit;

    //Reset forces
    vit = [[engine arrangement] arrData]->vertices_begin();        
    for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
        vit->data().springF = ofVec2f(0,0);
    }
    
    
    //Mouse force
    if(mousePressed){
        float mouseR = 0.3;
        float mouseF = 0.05;
        vit = [[engine arrangement] arrData]->vertices_begin();        
        for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
            if(mouse.distance(pointToVec(vit->point())) < mouseR){
                ofVec2f vertex = pointToVec(vit->point());
                ofVec2f v = vertex - mouse;
                
                float l = v.length();
                l *= 1.0/mouseR;
                l = 1.0-l;
                
                v.normalize();
                
                vit->data().springF += v*mouseF*l*PropF(@"mouseForce")*2.0;            
            }
        }
    }
    
    
    
    
    if(PropI(@"state") > 0){
        
        //Optimal length
        Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();        
        for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
            //Constructor
            if(eit->data().crumbleOptimalLength == -1){
                updateInitialLength(eit);
            }
        }
        
        //Optimal angle
        fit = [[engine arrangement] arrData]->faces_begin();        
        for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {        
            if(!fit->is_fictitious()){
                if(fit->number_of_outer_ccbs() == 1){
                    Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                    Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                    do { 
                        updateInitialAngle(hc);
                    } while (++hc != ccb_start); 
                }            
            }
        }
        
        
        
        for(int i=0;i<PropI(@"iterations"); i++){
            //
            //Calculate the vertex to vertex spring force
            //
            eit = [[engine arrangement] arrData]->edges_begin();        
            for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
                ofVec2f dir;
                
                float length = edgeLength(eit, &dir);
                float optimalLength = eit->data().crumbleOptimalLength;
                
                dir.normalize();
                
                dir *= (length - optimalLength);
                
                //float elasticity = PropF(@"elasticity");
                
                eit->source()->data().springF += -dir;// * (1-elasticity);
                eit->target()->data().springF +=  dir;// * (1-elasticity);
            }
            
            //
            //Calculate angular stiffness force
            //
            fit = [[engine arrangement] arrData]->faces_begin();        
            for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {        
                if(!fit->is_fictitious()){
                    if(fit->number_of_outer_ccbs() == 1){
                        Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                        Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                        do { 
                            ofVec2f dir;
                            float angle = edgeAngleToNext(hc, &dir);
                            float optimalAngle = hc->data().crumbleOptimalAngle;
                            
                            float diff = fabs(angle-optimalAngle);
                            
                            
                            
                            ofVec2f target =  pointToVec(hc->target()->point());
                            
                            
                        } while (++hc != ccb_start); 
                    }            
                }
            }

            
            
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // !!!! Vertex position update !!!!
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            vit = [[engine arrangement] arrData]->vertices_begin();        
            for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
                vit->data().springV *= 0;//PropF(@"springDamping");
                
                vit->data().springV += vit->data().springF * 0.01 * PropF(@"springStrength");
                
                vit->point() =   Arrangement_2::Point_2(vit->data().springV.x + vit->point().x(), 
                                                        vit->data().springV.y + vit->point().y());
            }
            
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        }
    }
    
    
    //  [[engine arrangement] cgalObjectAtPoint:Point_2(mouse.x, mouse.y)];
    
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    Arrangement_2::Edge_iterator eit;    
    Arrangement_2::Vertex_iterator vit;
    Arrangement_2::Face_iterator fit;
    
    //Visualize total force
    ofSetColor(255,255,0);

    vit = [[engine arrangement] arrData]->vertices_begin();        
    for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
        of2DArrow( pointToVec(vit->point()) ,  pointToVec(vit->point()) + ofVec2f(vit->data().springF.x,vit->data().springF.y) , 0.01);
    }
    
    //Visualize angualar stress
    ofSetColor(255,0,255);

    fit = [[engine arrangement] arrData]->faces_begin();        
    for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {        
        if(!fit->is_fictitious()){
            if(fit->number_of_outer_ccbs() == 1){
                Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                do { 
                    ofVec2f dir;
                    float angle = edgeAngleToNext(hc, &dir);
                    ofVec2f target =  pointToVec(hc->target()->point());                        
                    of2DArrow(target , target + dir*0.1 , 0.01);
                } while (++hc != ccb_start); 
            }            
        }
    }
    
    /*
     eit = [[engine arrangement] arrData]->edges_begin();        
     for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
     ofVec2f dir;
     float angle = edgeAngleToNext(eit, &dir);
     ofVec2f target =  pointToVec(eit->target()->point());
     
     ofSetColor(255,0,255);
     
     
     of2DArrow(target , target + dir*0.1 , 0.01);
     
     
     
     }*/
    
    
}

- (void) controlMousePressed:(float) x y:(float)y button:(int)button{
    mousePressed = YES;
    mouse = ofVec2f(x,y);    
}

- (void) controlMouseMoved:(float) x y:(float)y{
    mouse = ofVec2f(x,y);    
}

- (void) controlMouseReleased:(float) x y:(float)y{
    mousePressed = NO;
}

-(void)controlMouseDragged:(float)x y:(float)y button:(int)button{
    mouse = ofVec2f(x,y);
}

@end
