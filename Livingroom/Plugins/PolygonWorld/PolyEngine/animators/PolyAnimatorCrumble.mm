//
//  PolyAnimatorCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//


#import "PolyAnimatorCrumble.h"
#import "PolyAnimatorPhysics.h"
#import <ofxCocoaPlugins/CustomGraphics.h>


@implementation PolyAnimatorCrumble


-(id)init{
    if(self = [super init]){
        [self addPropF:@"mouseForce"];
        [self addPropF:@"mouseRadius"];
        
        [self addPropF:@"crumbleForce"];
        [self addPropF:@"decrumbleForce"];
        
        [self addPropF:@"cutHole"];
    }
    
    return self;
}

#pragma mark CGAL Helpers 




#pragma mark Common

-(void)update:(NSDictionary *)drawingInformation{
    
    vector<ofVec2f> v = [GetTracker() getTrackerCoordinates];
    
    if(v.size() > 0 && PropB(@"cutHole")){
        SetPropF(@"cutHole", 0);
        
        /*        CGAL::Object obj = [[engine arrangement] cgalObjectAtPoint:Point_2(v[0].x, v[0].y)];
         
         Arrangement_2::Face_const_handle      face;
         
         if (CGAL::assign (face, obj)) {*/
        
        Arrangement_2::Face_const_handle      face = [[engine arrangement] faceAtPoint:v[0]];
        {
            if(!face->is_fictitious() && !face->is_unbounded()){
                cout<<"Cut"<<endl;
                Arrangement_2::Face_handle faceCast = [[engine arrangement] arrData]->non_const_handle(face);
                faceCast->data().hole = true;
            }
        }
        
    }
    
    
    //Remove lonely edges
    {
        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
            if(eit->face()->is_unbounded() || eit->face()->data().hole){
                if(eit->twin()->face()->is_unbounded() || eit->twin()->face()->data().hole){
                    //Delete edge
                    eit->data().deleted = true;
                    eit->twin()->data().deleted = true;
                }            
            }
        }];
    }
    
    CachePropF(crumbleForce);
    if(crumbleForce > 0 && v.size() > 0){
        //Tracker force
        [GetPhysics() addPhysicsBlock:@"CrumbleForce" block:^(PolyArrangement *arrangement) {
            {
                float mouseR = PropF(@"mouseRadius");
                float mouseF = PropF(@"mouseForce")*0.05;
                
                [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                    for(int t=0;t<v.size();t++){
                        ofVec2f vertex = handleToVec2(vit);
                        if(v[t].distance(vertex) < mouseR){
                            ofVec2f vdir = vertex - v[t];
                            
                            float l = vdir.length();
                            l *= 1.0/mouseR;
                            l = 1.0-l;
                            
                            vdir.normalize();
                            
                            ofVec3f v3 = ofVec3f(vdir.x, vdir.y, 0);
                            vit->data().springF += vdir*mouseF*l*2.0;      
                            
                            //Force in z=0
                            float zDiff = vit->data().pos.z;
                            vit->data().springF += ofVec3f(0,0,-zDiff *0.9);
                            
                        }
                    }
                }];
                /*  
                 for(int i=0;i<v.size();i++){
                 Arrangement_2::Face_const_handle      face = [[engine arrangement] faceAtPoint:v[i]];
                 if(!face->is_fictitious() && !face->is_unbounded() && !face->data().hole){
                 Arrangement_2::Face_handle fit = [[engine arrangement] arrData]->non_const_handle(face);
                 
                 
                 if(fit->number_of_outer_ccbs() == 1){
                 
                 Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                 Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                 do { 
                 if(hc->twin()->face()->is_unbounded() || hc->twin()->face()->data().hole){
                 
                 //Inside face that is at the boundary
                 ofVec2f p = v[i];
                 
                 
                 Arrangement_2::Vertex_handle h1 =  hc->source();
                 Arrangement_2::Vertex_handle h2 =  hc->target();
                 
                 ofVec2f p1 = handleToVec2(h1);
                 ofVec2f p2 = handleToVec2(h2);
                 
                 float dist1 = p1.distance(p);
                 float dist2 = p2.distance(p);
                 
                 float factor2 = dist1 / (dist1 + dist2);
                 float factor1 = dist2 / (dist1 + dist2);
                 
                 ofVec2f dir1 = (p-p1).normalized();
                 ofVec2f dir2 = (p-p2).normalized();
                 
                 float dist = distanceVecToHalfedge(p, hc);
                 
                 h1->data().springF += crumbleForce*dir1*dist*factor1;      
                 h2->data().springF += crumbleForce*dir2*dist*factor2;      
                 
                 }
                 
                 
                 
                 ++hc; 
                 } while (hc != ccb_start); 
                 }
                 
                 }
                 
                 */
                /*if([[engine arrangement] vecInsideBoundary:v[i]]){
                 //Outside boundary
                 ofVec2f p = v[i];
                 
                 Arrangement_2::Halfedge_const_handle handle = [arrangement nearestBoundaryHalfedge:v[i]];
                 
                 Arrangement_2::Vertex_handle h1 =  [arrangement arrData]->non_const_handle(handle->source());
                 Arrangement_2::Vertex_handle h2 =  [arrangement arrData]->non_const_handle(handle->target());
                 
                 ofVec2f p1 = handleToVec2(h1);
                 ofVec2f p2 = handleToVec2(h2);
                 
                 float dist1 = p1.distance(p);
                 float dist2 = p2.distance(p);
                 
                 float factor2 = dist1 / (dist1 + dist2);
                 float factor1 = dist2 / (dist1 + dist2);
                 
                 ofVec2f dir1 = (p-p1).normalized();
                 ofVec2f dir2 = (p-p2).normalized();
                 
                 float dist = distanceVecToHalfedge(p, handle);
                 
                 h1->data().springF += decrumbleForce*dir1*dist*factor1;      
                 h2->data().springF += decrumbleForce*dir2*dist*factor2;      
                 
                 }
                 //        Arrangement_2::Face_const_handle face = [[engine arrangement] faceAtPoint:Point_2(v[i].x,v[i].y)];
                 //            
                 }*/
            }
        }];
        
    }
    
    
    CachePropF(decrumbleForce);
    if(decrumbleForce > 0 && v.size() > 0){
        [GetPhysics() addPhysicsBlock:@"DecrumbleForce" block:^(PolyArrangement *arrangement) {
            
            for(int i=0;i<v.size();i++){
                if(![[engine arrangement] vecInsideBoundary:v[i]]){
                    //Outside boundary
                    ofVec2f p = v[i];
                    
                    Arrangement_2::Halfedge_const_handle handle = [arrangement nearestBoundaryHalfedge:v[i]];
                    
                    Arrangement_2::Vertex_handle h1 =  [arrangement arrData]->non_const_handle(handle->source());
                    Arrangement_2::Vertex_handle h2 =  [arrangement arrData]->non_const_handle(handle->target());
                    
                    ofVec2f p1 = handleToVec2(h1);
                    ofVec2f p2 = handleToVec2(h2);
                    
                    float dist1 = p1.distance(p);
                    float dist2 = p2.distance(p);
                    
                    float factor2 = dist1 / (dist1 + dist2);
                    float factor1 = dist2 / (dist1 + dist2);
                    
                    ofVec2f dir1 = (p-p1).normalized();
                    ofVec2f dir2 = (p-p2).normalized();
                    
                    float dist = distanceVecToHalfedge(p, handle);
                    
                    h1->data().springF += decrumbleForce*dir1*dist*factor1;      
                    h2->data().springF += decrumbleForce*dir2*dist*factor2;      
                    
                }
                //        Arrangement_2::Face_const_handle face = [[engine arrangement] faceAtPoint:Point_2(v[i].x,v[i].y)];
                //            
            }
        }];
        
    }
    
    
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    Arrangement_2::Edge_iterator eit;    
    Arrangement_2::Vertex_iterator vit;
    Arrangement_2::Face_iterator fit;
    
    //Visualize mouse
    if([GetTracker() getTrackerCoordinates].size() > 0){
        ofEnableAlphaBlending();
        ofFill();
        ofSetColor(255,255,255,30);
        
        vector<ofVec2f> v = [GetTracker() getTrackerCoordinates];
        for(int i=0;i<v.size();i++){
            ofCircle(v[i].x,v[i].y, PropF(@"mouseRadius"));
        }
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
