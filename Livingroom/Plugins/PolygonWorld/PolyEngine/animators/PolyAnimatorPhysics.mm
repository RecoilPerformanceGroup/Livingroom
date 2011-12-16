//
//  PolyAnimatorCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//


#import "PolyAnimatorPhysics.h"
#import <ofxCocoaPlugins/CustomGraphics.h>
#include <CGAL/centroid.h>


@implementation PolyAnimatorPhysics 
@synthesize debugText;

-(id)init{
    if(self = [super init]){
        [[self addPropF:@"state"] setMaxValue:3];
        [[self addPropF:@"iterations"] setMinValue:1];
        
        [self addPropF:@"minForce"];
        [self addPropF:@"floorFriction"];
        
        //State 1:
        [self addPropF:@"springStrength"];
        [self addPropF:@"ZzeroForce"];
        [self addPropF:@"FlatNormalForce"];
        
        //State 2:
        [self addPropF:@"angleStiffnesForce"];
        
        //State 3:
        [self addPropF:@"anchorThreshold"];
        
        blockPhysics = [NSMutableDictionary dictionary];
        blockTiming = [NSMutableDictionary dictionary];
        NSTextField * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        [textField setBordered:NO];
        [textField setEditable:NO];
        [textField setDrawsBackground:NO];
        
        debugText = [NSMutableString string];
        [textField bind:@"value" toObject:self withKeyPath:@"debugText" options:nil];
        [[self view] addSubview:textField];
        
        lastDebugUpdate = 0;
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


#pragma mark Accesors
-(void) addPhysicsBlock:(NSString *)name block:(void(^)(PolyArrangement * arrangement))block {
    [blockPhysics setObject:[[block copy] autorelease] forKey:name];
    [blockTiming setObject:[NSNumber numberWithInt:0] forKey:name];
}


#pragma mark Common

-(void)update:(NSDictionary *)drawingInformation{
    BOOL updateDebug = NO;
    
    if(ofGetElapsedTimeMillis() > lastDebugUpdate + 100){
        updateDebug = YES;
        lastDebugUpdate = ofGetElapsedTimeMillis();
    }
    
    [blockTiming removeAllObjects];
    if(PropI(@"state") >= 1){
        
        //Optimal length
        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
            if(eit->data().crumbleOptimalLength == -1){
                updateInitialLength(eit);
            }
        }];
        
        //Optimal angle
        [[engine arrangement] enumerateFaceEdges:^(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit) {
            if(hc->data().crumbleOptimalAngle == -1){                            
                updateInitialAngle(hc);
            }
        }];
        
        
        //Random z value (so its never 0)
        [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
            if(vit->data().pos.z == 0){
                vit->data().pos.z = ofRandom(-0.001,0.001);
            }
        }];
        
        
        
        [self addPhysicsBlock:@"StringForce" block:^(PolyArrangement *arrangement) {
            //
            //Calculate the vertex to vertex spring force
            //
            [arrangement enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
                ofVec3f dir;
                
                float length = edgeLength(eit, &dir);
                float optimalLength = eit->data().crumbleOptimalLength;
                
                dir.normalize();
                
                dir *= (length - optimalLength) * PropF(@"springStrength");
                
                //float elasticity = PropF(@"elasticity");
                
                eit->source()->data().springF += -dir;// * (1-elasticity);
                eit->target()->data().springF +=  dir;// * (1-elasticity);
            }];
        }];
        
        
        [self addPhysicsBlock:@"AngularStiffness" block:^(PolyArrangement *arrangement) {
            
            //
            //Calculate angular stiffness force
            //
            if(PropI(@"state") >= 2 && PropF(@"angleStiffnesForce") > 0){
                
                [ arrangement enumerateFaceEdges:^(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit) {
                    ofVec2f dir;
                    float angle = edgeAngleToNext(hc, &dir);
                    float optimalAngle = hc->data().crumbleOptimalAngle;
                    
                    int minus = (angle*optimalAngle < 0) ? -1 : 1;
                    
                    float diff = minus*(fabs(angle)-fabs(optimalAngle));
                    
                    hc->target()->data().springF +=  dir*diff*PropF(@"angleStiffnesForce")*0.0001;
                    
                }];
            }
        }];
        
        
        [self addPhysicsBlock:@"ZzeroForce" block:^(PolyArrangement *arrangement) {
            //
            //Calculate the vertex to vertex spring force
            //
            float f = PropF(@"ZzeroForce");
            if(f > 0){
                [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                    vit->data().springF += ofVec3f(0,0,-f*vit->data().pos.z);
                }];
            }
        }];
        
       
        [self addPhysicsBlock:@"FlatNormalForce" block:^(PolyArrangement *arrangement) {
            //
            //Calculate the vertex to vertex spring force
            //
            float f = PropF(@"FlatNormalForce");
            __block  Arrangement_2::Face_iterator lastfit;
            __block ofVec3f normal;
            [arrangement enumerateFaces:^(Arrangement_2::Face_iterator fit) {
                Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();

                Arrangement_2::Vertex_handle h1 = ccb_start->source();
                Arrangement_2::Vertex_handle h2 = ccb_start->target();
                Arrangement_2::Vertex_handle h3 = ccb_start->prev()->source();
                   
                ofVec3f v1 = handleToVec3(h1);
                ofVec3f v2 = handleToVec3(h2);
                ofVec3f v3 = handleToVec3(h3);
                
              
                ofVec3f u = v3 - v1;
                ofVec3f v = v2 - v1;
                
                ofVec3f normal = u.cross(v);
                normal.normalize();
               
                ofVec3f goal = -ofVec3f(0,0,1);
                
                
                
                Kernel::Triangle_3 triangle = Kernel::Triangle_3(vec3ToPoint3(v1), vec3ToPoint3(v2), vec3ToPoint3(v3));
                
                ofVec3f middle = point3ToVec3( CGAL::centroid(triangle));           
                
                ofQuaternion q;
                q.makeRotate(normal, goal);
                
                float angle;
                ofVec3f rotVec;
                q.getRotate(angle, rotVec);

                ofVec3f vv1 = v1-middle;
                ofVec3f vv2 = v2-middle;
                ofVec3f vv3 = v3-middle;
                
                
                vv1.rotate(angle, rotVec);
                vv2.rotate(angle, rotVec);
                vv3.rotate(angle, rotVec);
                
                ofVec3f v1goal = middle+vv1;
                ofVec3f v2goal = middle+vv2;
                ofVec3f v3goal = middle+vv3;
                
                h1->data().springF += (v1goal-v1)*f;
                h2->data().springF += (v2goal-v2)*f;
                h3->data().springF += (v3goal-v3)*f;*/
            }];
       /*     [arrangement enumerateFaceEdges:^(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit) {
                if(lastfit != fit){
                    normal = calculateFaceNormal(fit);
                    lastfit = fit;
                }
                
            }];*/
        }];
        
        for(int i=0;i<PropI(@"iterations"); i++){
            //Reset forces
            [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                vit->data().springF = ofVec3f(0,0,0);
            }];
            
            
            
            [blockPhysics enumerateKeysAndObjectsUsingBlock:^(id blockkey, id obj, BOOL *stop) {
                clock_t start = clock();
                
                
                void (^pointerToBlock)(PolyArrangement * arr) = obj;    
                pointerToBlock([engine arrangement]);
                
                double dur = 100000.0*((double)clock() - start ) / CLOCKS_PER_SEC;
                
                if(updateDebug){
                    NSNumber * num = [blockTiming valueForKey:blockkey];
                    if(num == nil){
                        [blockTiming setValue:[NSNumber numberWithDouble:dur] forKey:blockkey];                                        
                    } else {
                        double buf = [num doubleValue];
                        [blockTiming setValue:[NSNumber numberWithDouble:dur+buf] forKey:blockkey];                    
                    }
                }
                
                //  NSLog(@"%@",[blockTiming valueForKey:blockkey]);
                
            }];
            
            
            
            //Anchor
            if(PropI(@"state") >= 3){
                [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                    if(vit->data().crumbleAnchor == true){
                        if(vit->data().springF.length() > PropF(@"anchorThreshold")){
                            vit->data().crumbleAnchor = false;
                        } 
                    }
                }];
            }
            
            
            
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // !!!! Vertex position update !!!!
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
                vit->data().springV *= 0;//PropF(@"springDamping");
                
                if(PropI(@"state") < 3 || !vit->data().crumbleAnchor){
                    if( vit->data().springF.length() > PropF(@"minForce")){
                        vit->data().springV += vit->data().springF * 0.01;
                    }
                }
                
                //Friction
                vit->data().springV *= ofVec3f(1.0-PropF(@"floorFriction"),1.0-PropF(@"floorFriction"),1.0);
                
                vit->data().pos += vit->data().springV;                
            }];
            
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        }
    }
    
    [blockPhysics removeAllObjects];
    
    
    if(updateDebug){
        __block NSMutableString * str = [NSMutableString string];
        [blockTiming enumerateKeysAndObjectsUsingBlock:^(id blockkey, id obj, BOOL *stop) {
            
            [str appendFormat:@"%@:\t\t %@\n",blockkey, obj];
        }];
        
        [self setDebugText:str];    //  [[engine arrangement] cgalObjectAtPoint:Point_2(mouse.x, mouse.y)];
    }
    
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    
    
    //Visualize
    
    
    //total force
    ofSetColor(255,255,0);
    
    [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
        of2DArrow( handleToVec2(vit) ,  handleToVec2(vit) + ofVec2f(vit->data().springF.x, vit->data().springF.y) , 0.01);
    }];
    
    
    /* //Visualize angualar stress
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
