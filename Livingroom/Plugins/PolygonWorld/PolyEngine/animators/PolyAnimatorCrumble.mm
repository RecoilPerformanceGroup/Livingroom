//
//  PolyAnimatorCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//


#import "PolyAnimatorCrumble.h"
#import "PolyAnimatorPhysics.h"
#import "PolyAnimatorGravity.h"
#import <ofxCocoaPlugins/CustomGraphics.h>


@implementation PolyAnimatorCrumble
@synthesize crumbleSum;

-(id)init{
    if(self = [super init]){
        [self addPropF:@"mouseForce"];
        [self addPropF:@"mouseRadius"];
        
        [self addPropF:@"crumbleForce"];
        [self addPropF:@"crumbleForce2"];
        [[self addPropF:@"decrumbleForce"] setMidiSmoothing:0.9];
        [[self addPropF:@"decrumbleForceRadius"] setMidiSmoothing:0.96];
        
        [self addPropF:@"crumbleEdgeDistance"];
        [self addPropF:@"crumbleEdgeFalloff"];
        [self addPropF:@"crumbleEdgeStrength"];

        [self addPropF:@"decrumbleCenterStrength"];


        [self addPropF:@"crumbleCheat"];

        
        [self addPropF:@"cutHole"];
        
        [self addPropF:@"centroid"];
        
    }
    
    return self;
}

-(void) addCrumbleSum:(float)sum{
    crumbleSum += sum;
}



#pragma mark Common

-(void)update:(NSDictionary *)drawingInformation{
    
    vector< vector<ofVec2f> > v = [GetTracker() getTrackerCoordinates];
    vector< ofVec2f > centroids = [GetTracker() getTrackerCoordinatesCentroids];
    
    /*  if(v.size() > 0 && PropB(@"cutHole")){
     SetPropF(@"cutHole", 0);
     
     Arrangement_2::Face_const_handle      face = [[engine arrangement] faceAtPoint:v[0][0]];
     {
     if(!face->is_fictitious() && !face->is_unbounded()){
     cout<<"Cut"<<endl;
     Arrangement_2::Face_handle faceCast = [[engine arrangement] arrData]->non_const_handle(face);
     faceCast->data().hole = true;
     }
     }
     
     }*/
    
    
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
    
    
    PolyAnimatorGravity* gravity = ((PolyAnimatorGravity*)GetModule(@"Gravity"));
    float midiInput = [[[gravity properties] valueForKey:@"midiInput"] floatValue]*[[[gravity properties] valueForKey:@"midiInputLevel"] floatValue];

    if(midiInput > 0){
        [Prop(@"crumbleEdgeStrength") setFloatValue:0.6*midiInput/2.0];
    }
    
    CachePropF(decrumbleCenterStrength);
    
    if(decrumbleCenterStrength){
        [GetPhysics() addPhysicsBlock:@"CrumbleCenterDecrumble" block:^(PolyArrangement *arrangement) {                           
            [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                //ofVec2f origP = point2ToVec2(vit->point());
                ofVec2f p = handleToVec2(vit);
                ofVec2f dir = ofVec2f(0.5,0.5) - p;
                
                float dist = p.distance(ofVec2f(0.5,0.5));
                vit->data().springF -= decrumbleCenterStrength * dir*(dist);
            }];
        }]; 
    }
    
    CachePropF(crumbleEdgeStrength);
    
    if(crumbleEdgeStrength){
        [GetPhysics() addPhysicsBlock:@"CrumbleCenterCrumble" block:^(PolyArrangement *arrangement) {                           
            [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                //ofVec2f origP = point2ToVec2(vit->point());
                ofVec2f p = handleToVec2(vit);
                ofVec2f dir = ofVec2f(0.5,0.5) - p;
                
                float dist = p.distance(ofVec2f(0.5,0.5));
                vit->data().springF += crumbleEdgeStrength * dir*(dist);
            }];
        }]; 
    }

    
    /*
    CachePropF(crumbleEdgeDistance);
    CachePropF(crumbleEdgeFalloff);
    CachePropF(crumbleEdgeStrength);
    if(crumbleEdgeStrength){
        PolyAnimatorGravity* gravity = ((PolyAnimatorGravity*)GetModule(@"Gravity"));
        float midiInput = [[[gravity properties] valueForKey:@"midiInput"] floatValue]/2.5;
       // if(midiInput > lastMidiInput){

        

        //  } else {
        [GetPhysics() addPhysicsBlock:@"CrumbleEdgeStrength" block:^(PolyArrangement *arrangement) {           
            {
                [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {                           
                    ofVec2f vertex = handleToVec2(vit);
                    float edgeDistance1 = fabs(vertex.x);
                    float edgeDistance2 = fabs(1-vertex.x);
                    float edgeDistance3 = fabs(vertex.y);
                    float edgeDistance4 = fabs(1-vertex.y);
                    
                    float edgeDistance = edgeDistance1;
                    if(edgeDistance2 < edgeDistance)
                        edgeDistance = edgeDistance2;
                    if(edgeDistance3 < edgeDistance)
                        edgeDistance = edgeDistance3;
                    if(edgeDistance4 < edgeDistance)
                        edgeDistance = edgeDistance4;
                    
                    if(edgeDistance < crumbleEdgeDistance){
                        ofVec2f p = handleToVec2(vit);
                        ofVec2f dir = ofVec2f(0.5,0.5) - p;

                        float f = (edgeDistance - crumbleEdgeDistance);
                        
                        dir.normalize();
                        dir *= f;
                        ofVec3f v3 = ofVec3f(dir.x, dir.y, 0);
                        vit->data().springF -= crumbleEdgeStrength*v3;      

                    }

                    
                }];
            }
            //  cout<<_crumbleSum<<endl;
            //            crumbleSum += _crumbleSum;
        }];
        //      }
        lastMidiInput = midiInput;   
    }
    */
    
    CachePropF(crumbleForce);
    float mouseR = PropF(@"mouseRadius");
    float mouseF = PropF(@"mouseForce")*0.05;
    CachePropF(centroid);
    
    
    if(crumbleForce > 0 && v.size() > 0){
        //Tracker force
        [GetPhysics() addPhysicsBlock:@"CrumbleForce" block:^(PolyArrangement *arrangement) {
            __block float _crumbleSum = 0;
            
            {
                [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                    for(int t=0;t<v.size();t++){
                        ofVec2f trackerCentroid = centroids[t];
                        for(int u=0;u<v[t].size();u++){
                            ofVec2f trackerPoint = v[t][u];
                            if(centroid > 0){
                                ofVec2f _dir = trackerCentroid-trackerPoint;
                                trackerPoint += _dir * centroid;
                            }
                            
                            ofVec2f vertex = handleToVec2(vit);
                            if(trackerPoint.distance(vertex) < mouseR){
                                ofVec2f vdir = vertex - trackerPoint;
                                
                                float l = vdir.length();
                                l *= 1.0/mouseR;
                                l = 1.0-l;
                                
                                vdir.normalize();
                                
                                ofVec3f v3 = ofVec3f(vdir.x, vdir.y, 0);
                                vit->data().springF += vdir*mouseF*l*2.0;      
                                
                                _crumbleSum += (vdir*mouseF*l*2.0).length();
                                //Force in z=0
                                float zDiff = vit->data().pos.z;
                                vit->data().springF += ofVec3f(0,0,-zDiff *0.9);
                            }
                        }
                    }
                }];
            }
            //  cout<<_crumbleSum<<endl;
            [self addCrumbleSum:_crumbleSum];
            //            crumbleSum += _crumbleSum;
        }];
        
    }
    
    
    
    CachePropF(crumbleForce2);
    if(crumbleForce2 > 0 && v.size() > 0){
        [GetPhysics() addPhysicsBlock:@"CrumbleForce2" block:^(PolyArrangement *arrangement) {
            
            for(int i=0;i<v.size();i++){
                ofVec2f trackerCentroid = centroids[i];
                
                for(int u=0;u<v[i].size();u++){
                    ofVec2f trackerPoint = v[i][u];
                    if(centroid > 0){
                        ofVec2f _dir = trackerCentroid-trackerPoint;
                        trackerPoint += _dir * centroid;
                    }
                    
                    //   if(![[engine arrangement] vecInsideHole:trackerPoint] && [[engine arrangement] numberHoles] > 0){
                    if([[engine arrangement] vecInsideBoundary:trackerPoint]){                        //  cout<<"Not inside hole"<<endl;
                        //Inside boundary
                        ofVec2f p = trackerPoint;
                        
                        //                        Arrangement_2::Halfedge_const_handle handle = [arrangement nearestHoleHalfedge:trackerPoint];
                        Arrangement_2::Halfedge_const_handle handle = [arrangement nearestBoundaryHalfedge:trackerPoint];
                        Arrangement_2::Vertex_handle h1 =  [arrangement arrData]->non_const_handle(handle->source());
                        Arrangement_2::Vertex_handle h2 =  [arrangement arrData]->non_const_handle(handle->target());
                        
                        ofVec2f p1 = handleToVec2(h1);
                        ofVec2f p2 = handleToVec2(h2);
                        
                        //  cout<<"Nearest p1 "<<p1.x<<"  "<<p1.y<<endl;
                        
                        float dist1 = p1.distance(p);
                        
                        float dist2 = p2.distance(p);
                        
                        float factor2 = dist1 / (dist1 + dist2);
                        float factor1 = dist2 / (dist1 + dist2);
                        
                        /*                        ofVec2f dir1 = (p-p1).normalized();
                         ofVec2f dir2 = (p-p2).normalized();*/
                        ofVec2f dir1 = -calculateEdgeNormal(handle).normalized();
                        ofVec2f dir2 = dir1;
                        
                        float dist = distanceVecToHalfedge(p, handle);
                        
                        h1->data().springF += crumbleForce2*dir1*dist*factor1;      
                        h2->data().springF += crumbleForce2*dir2*dist*factor2;  
                        
                        //    crumbleSum += (crumbleForce2*dir1*dist*factor1).length();
                        //    crumbleSum += (crumbleForce2*dir2*dist*factor2).length();
                        
                    }
                }
                //        Arrangement_2::Face_const_handle face = [[engine arrangement] faceAtPoint:Point_2(v[i].x,v[i].y)];
                //            
            }
        }];
        
    }
    
    // cout<<crumbleSum<<endl;
    CachePropF(crumbleCheat);
    
    if(crumbleCheat){
        [GetPhysics() addPhysicsBlock:@"crumbleCheat" block:^(PolyArrangement *arrangement) {
            [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                ofVec2f origP = point2ToVec2(vit->point());
                ofVec2f p = handleToVec2(vit);
                ofVec2f dir = ofVec2f(0,1) - p;
                
                float dist = p.distance(ofVec2f(0,1));
                if(dist < crumbleCheat*2 && p.y > 0.4){
                    vit->data().springF -= 10*dir*(crumbleCheat*2-dist);
                }
            }];
        }];
    }
    
    
    CachePropF(decrumbleForce);
    CachePropF(decrumbleForceRadius);
    
    if(decrumbleForce > 0){
        [GetPhysics() addPhysicsBlock:@"DecrumbleForce" block:^(PolyArrangement *arrangement) {
            /*
             if(centroids.size() >= 2){
             vector< vector<Arrangement_2::Halfedge_const_handle> > boundaryHandles = [arrangement boundaryHandles];
             
             for(int i=0;i<boundaryHandles.size();i++){
             for(int u=0;u<boundaryHandles[i].size();u++){
             Arrangement_2::Halfedge_handle handle = [arrangement arrData]->non_const_handle(boundaryHandles[i][u]);
             
             ofVec2f p = handleToVec2(handle->source());
             
             float dist = centroids[1].distance(p);
             if(dist < decrumbleForceRadius){
             ofVec2f origP = point2ToVec2(handle->source()->point());
             ofVec2f dir = origP - p;
             handle->source()->data().springF += decrumbleForce * dir * (decrumbleForceRadius-dist);
             }
             
             }
             }
             }*/
            
            [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                ofVec2f origP = point2ToVec2(vit->point());
                ofVec2f p = handleToVec2(vit);
                ofVec2f dir = origP - p;
                
                float dist = p.distance(ofVec2f(1,0));
                if(dist < decrumbleForceRadius*2){
                    vit->data().springF += decrumbleForce * dir*(decrumbleForceRadius*2-dist);
                }
            }];
            
        }];
    }
    
    crumbleSum = 0;
    
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
        
        vector< vector<ofVec2f> > v = [GetTracker() getTrackerCoordinates];
        for(int i=0;i<v.size();i++){
            for(int u=0;u<v[i].size();u++){
                ofCircle(v[i][u].x,v[i][u].y, PropF(@"mouseRadius"));
            }
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
