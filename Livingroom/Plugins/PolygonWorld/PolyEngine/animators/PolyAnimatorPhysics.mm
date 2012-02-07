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
        [[self addPropF:@"iterations"] setMinValue:1];
        [[self addPropF:@"forceIterations"] setMinValue:1];
        [[self addPropF:@"forceIterationsRatio"] setMinValue:0];
        [[self addPropF:@"forceIterationsRatioZ"] setMinValue:0];
        [[self addPropF:@"forceIterationsRatioDir"] setMinValue:0];
        
        [self addPropF:@"minForce"];
        [self addPropF:@"floorFriction"];
        
        //State 1:
        [self addPropF:@"springStrength"];
        [self addPropF:@"spring2dStrength"];
        [self addPropF:@"ZzeroForce"];  
        [self addPropF:@"FlatNormalForce"];
        [[self addPropF:@"FlatNormalForceAngle"] setMaxValue:180.0];
        
        //State 2:
        [self addPropF:@"angleStiffnesForce"];
        
        //State 3:
        [self addPropF:@"deleteStrength"];
        [self addPropF:@"hullStiffness"];       
        [self addPropF:@"burn"];
        
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

static float angleBetweenEdges(Halfedge_handle h1, Halfedge_handle h2, ofVec2f * middleDir = nil){
    
    //Middle point
    ofVec2f middle = handleToVec2(h1->target());
    
    //Vectors to left and right point
    ofVec2f left = handleToVec2(h1->source()) - middle;
    ofVec2f right = handleToVec2(h2->target()) - middle;
    
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

//The angle between the provided edge and its next edge. Returns also optionaly a middle dir (for straighten up)
static float edgeAngleToNext(Arrangement_2::Ccb_halfedge_circulator eit, ofVec2f * middleDir = nil){
    return angleBetweenEdges(eit, eit->next(), middleDir);
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
    
    //Clear physics
    [blockTiming removeAllObjects];
    
    //
    //Reset data
    //
    {   
        //Set optimal length
        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
            if(eit->data().crumbleOptimalLength == -1){
                updateInitialLength(eit);
            }
        }];
        
        //Set optimal angle
        [[engine arrangement] enumerateFaceEdges:^(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit) {
            if(hc->data().crumbleOptimalAngle == -1){                            
                updateInitialAngle(hc);
            }
        }];
        
        //Set hull optimal angle
        vector< vector<Arrangement_2::Halfedge_const_handle> > boundaryHandles = [[engine arrangement] boundaryHandles];    
        for(int i=0;i<boundaryHandles.size();i++){
            for(int u=1;u<boundaryHandles[i].size();u++){
                Halfedge_handle h1 = [[engine arrangement] arrData]->non_const_handle(boundaryHandles[i][u-1]);
                Halfedge_handle h2 = [[engine arrangement] arrData]->non_const_handle(boundaryHandles[i][u]);
                
                if(h1->target()->data().hullOptimalAngle == -1){
                    float angle = angleBetweenEdges(h1, h2);
                    h1->target()->data().hullOptimalAngle = angle;
                }
            }
        }
        
        //Set random z value (so its never 0)
        //Reset accumF
        __block int i=0;
        [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
            if(vit->data().pos.z == 0){
                vit->data().pos.z = sin(i*141.2151)*0.001;
                vit->data().bornZ = vit->data().pos.z;
            }
            vit->data().accumF = ofVec3f();
            i++;
        }];
    } //End reset data
    
    
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //%%%%%%%%%%%%%%%%%%%%%% PHYSICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    {
        
        //
        //Calculate the vertex to vertex spring force
        //
        float springStrength = PropF(@"springStrength");
        if(springStrength > 0){
            [self addPhysicsBlock:@"StringForce" block:^(PolyArrangement *arrangement) {
                
                [arrangement enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
                    ofVec3f dir;
                    
                    float length = edgeLength(eit, &dir);
                    float optimalLength = eit->data().crumbleOptimalLength;
                    
                    dir.normalize();
                    
                    dir *= (length - optimalLength) * springStrength;
                    
                    //float elasticity = PropF(@"elasticity");
                    
                    eit->source()->data().springFNoItt += -dir;// * (1-elasticity);
                    eit->target()->data().springFNoItt +=  dir;// * (1-elasticity);
                }];
            }];
        }
        
        
        
        //
        //Calculate the vertex to vertex spring force
        //
        springStrength = PropF(@"spring2dStrength");
        if(springStrength > 0){
            [self addPhysicsBlock:@"Spring2dStrength" block:^(PolyArrangement *arrangement) {
                
                [arrangement enumerateEdges:^(Arrangement_2::Edge_iterator eit) {                   
                    ofVec2f p1 = handleToVec2(eit->source());
                    ofVec2f p2 = handleToVec2(eit->target());
                    
                    ofVec2f dir = p2-p1;
                    
                    float length = p1.distance(p2);
                    float optimalLength = eit->data().crumbleOptimalLength;
                    
                    dir.normalize();
                    
                    dir *= (length - optimalLength) * springStrength;
                    
                    //float elasticity = PropF(@"elasticity");
                    
                    eit->source()->data().springFNoItt += dir;// * (1-elasticity);
                    eit->target()->data().springFNoItt +=  -dir;// * (1-elasticity);
                }];
            }];
        }
        
        //
        //Burn
        //
        float burn = PropF(@"burn");
        if(burn > 0){
            [self addPhysicsBlock:@"burn" block:^(PolyArrangement *arrangement) {
                ofVec2f center = ofVec2f(0.5,0.5);
                
                [arrangement enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL *stop) {
                    
                    
                    if(handleToVec2(vit).y > (1-burn)){
                        ofVec3f p = handleToVec3(vit);
                        ofVec3f dir = ofVec3f(0,-1,0);;
                        
                        vit->data().springF += (dir*0.5 + ofVec3f(0,0,ofRandom(-0.1,0.1)))*0.1;
                    }
                }];
                
            }];
        }
        
        
        //
        //Calculate angular stiffness force
        //
        float angleStiffnesForce = PropF(@"angleStiffnesForce");
        if(angleStiffnesForce > 0){
            [self addPhysicsBlock:@"AngularStiffness" block:^(PolyArrangement *arrangement) {
                
                
                [ arrangement enumerateFaceEdges:^(Arrangement_2::Ccb_halfedge_circulator hc, Arrangement_2::Face_iterator fit) {
                    ofVec2f dir;
                    float angle = edgeAngleToNext(hc, &dir);
                    float optimalAngle = hc->data().crumbleOptimalAngle;
                    
                    int minus = (angle*optimalAngle < 0) ? -1 : 1;
                    
                    float diff = minus*(fabs(angle)-fabs(optimalAngle));
                    
                    hc->target()->data().springF +=  dir*diff*angleStiffnesForce*0.0001;
                    
                }];
            }];
        }
        
        
        //
        //Calculate the vertex to vertex spring force
        //
        float f = PropF(@"ZzeroForce");
        if(f > 0){
            
            [self addPhysicsBlock:@"ZzeroForce" block:^(PolyArrangement *arrangement) {
                
                [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
                    vit->data().springF += ofVec3f(0,0,f*(vit->data().bornZ-vit->data().pos.z));
                }];
            }];
        }
        
        
        //
        //Calculate the hull Stiffness
        //
        f = PropF(@"hullStiffness");
        if(f > 0){
            [self addPhysicsBlock:@"hullStiffness" block:^(PolyArrangement *arrangement) {
                vector< vector<Arrangement_2::Halfedge_const_handle> > boundaryHandles = [arrangement boundaryHandles];
                
                for(int i=0;i<boundaryHandles.size();i++){
                    for(int u=1;u<boundaryHandles[i].size();u++){
                        Halfedge_handle h1 = [arrangement arrData]->non_const_handle(boundaryHandles[i][u-1]);
                        Halfedge_handle h2 = [arrangement arrData]->non_const_handle(boundaryHandles[i][u]);
                        
                        ofVec2f dir;
                        float angle = angleBetweenEdges(h1, h2, &dir);
                        float optimalAngle = h1->target()->data().hullOptimalAngle;
                        
                        int minus = (angle*optimalAngle < 0) ? -1 : 1;                        
                        float diff = minus*(fabs(angle)-fabs(optimalAngle));
                        
                        h1->target()->data().springF +=  dir*diff*f*0.0001;
                        
                    }
                }
                
                
                
                
            }];
        }
        
        
        
        //
        //Calculate the hull Stiffness
        //
        //        f = PropF(@"hullStiffness");
        //        if(f > 0){
        //            [self addPhysicsBlock:@"hullStiffness" block:^(PolyArrangement *arrangement) {
        //                vector< vector<Arrangement_2::Halfedge_const_handle> > boundaryHandles = [arrangement boundaryHandles];
        //                
        //                for(int i=0;i<boundaryHandles.size();i++){
        //                    for(int u=0;u<boundaryHandles[i].size();u++){
        //                        Halfedge_handle h = [arrangement arrData]->non_const_handle(boundaryHandles[i][u]);
        //                        
        //                        ofVec3f v1 =  h->source()->data().springF;
        //                        ofVec3f v2 =  h->target()->data().springF;
        //
        //                        h->source()->data().springF -= v1*(f);
        //                        h->target()->data().springF -= v2*(f);
        //                        
        //                        h->source()->data().springF += v2 * f;
        //                        h->target()->data().springF += v1 * f;
        //                    }
        //                }
        //                
        //              }];
        //        }
        
        
        f = PropF(@"FlatNormalForce");
        float minAngle = PropF(@"FlatNormalForceAngle");
        if(f > 0){
            [self addPhysicsBlock:@"FlatNormalForce" block:^(PolyArrangement *arrangement) {
                //
                //Calculate the vertex to vertex spring force
                //
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
                    
                    //                Vector_3 normal 
                    ofVec3f normal = u.cross(v);
                    normal.normalize();
                    
                    ofVec3f goal = -ofVec3f(0,0,1);
                    
                    ofVec3f middle = (v1 + v2 + v3)/3.0;
                    
                    ofQuaternion q;
                    q.makeRotate(normal, goal);
                    
                    float angle;
                    ofVec3f rotVec;
                    q.getRotate(angle, rotVec);
                    
                    if(angle > minAngle){
                        
                        ofVec3f vv1 = v1-middle;
                        ofVec3f vv2 = v2-middle;
                        ofVec3f vv3 = v3-middle;
                        
                        
                        vv1.rotate(angle-minAngle, rotVec);
                        vv2.rotate(angle-minAngle, rotVec);
                        vv3.rotate(angle-minAngle, rotVec);
                        
                        ofVec3f v1goal = middle+vv1;
                        ofVec3f v2goal = middle+vv2;
                        ofVec3f v3goal = middle+vv3;
                        
                        h1->data().springFNoItt += (v1goal-v1)*f;
                        h2->data().springFNoItt += (v2goal-v2)*f;
                        h3->data().springFNoItt += (v3goal-v3)*f;
                    }
                }];
            }];
        }
    } //End physics
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for(int i=0;i<PropI(@"iterations"); i++){
        //Reset forces
        [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
            vit->data().springF = ofVec3f();
            vit->data().springFNoItt = ofVec3f();
        }];
        
        
        //Run physics
        [blockPhysics enumerateKeysAndObjectsUsingBlock:^(id blockkey, id obj, BOOL *stop) {
            clock_t start = clock();
            
            //Physics block pointer
            void (^pointerToBlock)(PolyArrangement * arr) = obj;    
            pointerToBlock([engine arrangement]); //Run the block
            
            //Calculate duration
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
        }];
        
        
        
        
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!!!!! Force iterator !!!!!!!!
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        
        CachePropF(forceIterationsRatio);
        CachePropI(forceIterations);
        CachePropF(forceIterationsRatioZ);
        CachePropF(forceIterationsRatioDir);

        for(int i=0;i<forceIterations;i++){
            [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
                ofVec3f * source = &eit->source()->data().springF;
                ofVec3f * target = &eit->target()->data().springF;
                
                float dist = edgeLength(eit);
                //    cout<<dist<<endl;
                dist = fabs(1.0-dist);
                //    cout<<dist<<endl;
                ofVec3f vSource = *source * (forceIterationsRatio)*dist;
                ofVec3f vTarget = *target * (forceIterationsRatio)*dist;
                

                if(forceIterationsRatioDir > 0){
                    ofVec3f dir = handleToVec3(eit->target()) - handleToVec3(eit->source());
                    vSource = vSource * dir * forceIterationsRatioDir  + vSource * (1-forceIterationsRatioDir);
                    vTarget = vTarget * dir * forceIterationsRatioDir  + vTarget * (1-forceIterationsRatioDir);
                }
                
                vSource.z *= forceIterationsRatioZ;
                vTarget.z *= forceIterationsRatioZ;                    
                
                
                *source += vTarget;                    
                *source -= vSource;
                
                *target += vSource;
                *target -= vTarget;
            }];
        } 
        
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!! Vertex position update !!!!
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        CachePropF(minForce);
        CachePropF(floorFriction);
        
        [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
            
            vit->data().springF += vit->data().springFNoItt;
            
            if( vit->data().springF.length() > minForce){
                vit->data().accumF += vit->data().springF;                    
                vit->data().springV = vit->data().springF * 0.01 * (1.0-vit->data().physicsLock);
                
                //Friction
                vit->data().springV *= ofVec3f(1.0-floorFriction,1.0-floorFriction,1.0);
                
                //Update position
                setHandlePos(vit->data().springV + vit->data().pos, vit);
            } 
            
        }];
        
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
    }
    
    
    [blockPhysics removeAllObjects];
    
    
    CachePropF(deleteStrength);
    if(deleteStrength > 0){
        __block vector<Halfedge_handle> deletehandles;
        [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
            ofVec3f f1 = eit->source()->data().accumF;
            ofVec3f f2 = eit->target()->data().accumF;
            
            if((f1+f2).length() > deleteStrength){
                eit->data().deleted = true;
                eit->twin()->data().deleted = true;
            }
        }];
        
    }
    
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
    
    
    
    [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit, BOOL * stop) {
        ofVec2f v = handleToVec2(vit)   + ofVec2f(vit->data().accumF.x, vit->data().accumF.y) ;
        of2DArrow( handleToVec2(vit) ,  handleToVec2(vit) + 0.1*ofVec2f(vit->data().accumF.x, vit->data().accumF.y) , 0.01);
    }];
    
    
    
    vector< vector<Arrangement_2::Halfedge_const_handle> > boundaryHandles = [[engine arrangement] boundaryHandles];
    ofSetColor(255,255,255);
    for(int i=0;i<boundaryHandles.size();i++){
        for(int u=1;u<boundaryHandles[i].size();u++){
            Halfedge_handle h1 = [[engine arrangement] arrData]->non_const_handle(boundaryHandles[i][u-1]);
            Halfedge_handle h2 = [[engine arrangement] arrData]->non_const_handle(boundaryHandles[i][u]);
            
            ofVec2f dir;
            float angle = angleBetweenEdges(h1, h2, &dir);
            float optimalAngle = h1->target()->data().hullOptimalAngle;
            
            int minus = (angle*optimalAngle < 0) ? -1 : 1;                        
            
            of2DArrow( handleToVec2(h1->target()) ,  handleToVec2(h1->target()) + 0.1*dir , 0.01);
            
        }
    }
    
}

@end
