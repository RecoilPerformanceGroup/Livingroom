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
        [[self addPropF:@"iterations"] setMinValue:1];
        
        [self addPropF:@"minForce"];
                [self addPropF:@"floorFriction"];
        
        //        [self addPropF:@"elasticity"];
        
        //       [self addPropF:@"springDamping"];
        //State 1:
        [self addPropF:@"springStrength"];
        [self addPropF:@"mouseForce"];
        [self addPropF:@"mouseRadius"];
        
        //State 2:
        [self addPropF:@"angleStiffnesForce"];
        
        //State 3:
        [self addPropF:@"anchorThreshold"];
        
        
    }
    
    return self;
}

#pragma mark CGAL Helpers 

//The length of the edge
static float edgeLength(Arrangement_2::Edge_iterator eit, ofVec3f * dir = nil){
    ofVec3f source = handleToVec3(eit->source());
    ofVec3f target = handleToVec3(eit->target());      
    ofVec3f dir3 = source-target;
    if(dir != nil){
        //        dir->set(dir3.x, dir3.y);
        dir->set(dir3);
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
    ofVec2f middle = handleToVec2(eit->target());
    
    //Vectors to left and right point
    ofVec2f left = handleToVec2(eit->source()) - middle;
    ofVec2f right = handleToVec2(eit->next()->target()) - middle;
    
    float angle = left.angle(right);
    if(angle < 0){
        angle = 360 + angle;
    }
    
    if(middleDir != nil){
        left.normalize();
        
        
        if(angle > 179.9 && angle < 180.1){ //Special case where the line is straight
            middleDir->set(left.y, -left.x);
        } else {  
            
            left.rotate(angle*0.5);
            middleDir->set(-left);
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
    

    
    
    
    
    if(PropI(@"state") >= 1){
        
        //Optimal length
        eit = [[engine arrangement] arrData]->edges_begin();        
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
                        if(hc->data().crumbleOptimalAngle == -1){                            
                            updateInitialAngle(hc);
                        }
                    } while (++hc != ccb_start); 
                }            
            }
        }
        
        //Random z value (so its never 0
        vit = [[engine arrangement] arrData]->vertices_begin();        
        for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
            if(vit->data().z == 0){
                vit->data().z = ofRandom(-0.001,0.001);
            }
        }
        
        
        
        for(int i=0;i<PropI(@"iterations"); i++){
            //Reset forces
            vit = [[engine arrangement] arrData]->vertices_begin();        
            for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
                vit->data().springF = ofVec2f(0,0);
            }
            
            
            //Mouse force
            if(mousePressed){
                float mouseR = PropF(@"mouseRadius");
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
                        
                        //Force in z=0
                        float zDiff = vit->data().z;
                        vit->data().springF += ofVec3f(0,0,-zDiff *0.9);
                        
                    }
                }
            }
            
            
            //
            //Calculate the vertex to vertex spring force
            //
            eit = [[engine arrangement] arrData]->edges_begin();        
            for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
                ofVec3f dir;
                
                float length = edgeLength(eit, &dir);
                float optimalLength = eit->data().crumbleOptimalLength;
                
                dir.normalize();
                
                dir *= (length - optimalLength) * PropF(@"springStrength");
                
                //float elasticity = PropF(@"elasticity");
                
                eit->source()->data().springF += -dir;// * (1-elasticity);
                eit->target()->data().springF +=  dir;// * (1-elasticity);
            }
            
            //
            //Calculate angular stiffness force
            //
            if(PropI(@"state") >= 2 && PropF(@"angleStiffnesForce") > 0){
                
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
                                
                                int minus = (angle*optimalAngle < 0) ? -1 : 1;
                                
                                float diff = minus*(fabs(angle)-fabs(optimalAngle));
                                
                                hc->target()->data().springF +=  dir*diff*PropF(@"angleStiffnesForce")*0.0001;
                                
                                ofVec2f target =  pointToVec(hc->target()->point());
                                
                                
                            } while (++hc != ccb_start); 
                        }            
                    }
                }
            }
            
            //Anchor
            if(PropI(@"state") >= 3){
                vit = [[engine arrangement] arrData]->vertices_begin();        
                for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
                    if(vit->data().crumbleAnchor == true){
                        if(vit->data().springF.length() > PropF(@"anchorThreshold")){
                            vit->data().crumbleAnchor = false;
                        } 
                    }
                }
            }
            
            
            
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // !!!! Vertex position update !!!!
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            vit = [[engine arrangement] arrData]->vertices_begin();        
            for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
                vit->data().springV *= 0;//PropF(@"springDamping");
                
                if(PropI(@"state") < 3 || !vit->data().crumbleAnchor){
                    if( vit->data().springF.length() > PropF(@"minForce")){
                        vit->data().springV += vit->data().springF * 0.01;
                    }
                }
                
                //Friction
                vit->data().springV *= ofVec3f(1.0-PropF(@"floorFriction"),1.0-PropF(@"floorFriction"),1.0);
                
                vit->point() =   Arrangement_2::Point_2(vit->data().springV.x + vit->point().x(), 
                                                        vit->data().springV.y + vit->point().y());
                
                vit->data().z += vit->data().springV.z;
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
    
    //Visualize mouse
    if(mousePressed){
        ofEnableAlphaBlending();
        ofFill();
        ofSetColor(255,255,255,30);
        
        ofCircle(mouse.x,mouse.y, PropF(@"mouseRadius"));
    }
   /* 
    //Visualize total force
    ofSetColor(40,40,0);
    
    vit = [[engine arrangement] arrData]->vertices_begin();        
    for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
        of2DArrow( handleToVec2(vit) ,  handleToVec2(vit) + ofVec2f(vit->data().springF.x, vit->data().springF.y) , 0.01);
    }
    
    //Visualize angualar stress
    if(PropI(@"state") >= 2 && PropF(@"angleStiffnesForce") > 0){
        
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
                        float optimalAngle = hc->data().crumbleOptimalAngle;
                        
                        int minus = (angle*optimalAngle < 0) ? -1 : 1;
                        float diff = minus*(fabs(angle)-fabs(optimalAngle));
                        
                        dir *= diff*0.1;
                        
                        ofVec2f target =  pointToVec(hc->target()->point());                        
                        of2DArrow(target , target + dir*0.1 , 0.01);
                    } while (++hc != ccb_start); 
                }            
            }
        }
    }
    
    //Visualize anchor
    if(PropI(@"state") >= 3){        
        glPointSize(8);
        glBegin(GL_POINTS);
        
        vit = [[engine arrangement] arrData]->vertices_begin();        
        for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
            if(vit->data().crumbleAnchor){
                float diff =  1.0 - vit->data().springF.length()/PropF(@"anchorThreshold");
                ofSetColor(255,255.0*diff,255.0*diff);
                glVertexHandle(vit);
            }
        }
        glEnd();   
        
    }
    */
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
