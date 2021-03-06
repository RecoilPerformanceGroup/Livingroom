//
//  PolyInputSimpleMouseDraw.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "PolyInputSimpleMouseDraw.h"
#import "Mask.h"
#import "PolyInputTracker.h"

@implementation PolyInputSimpleMouseDraw


-(id)init{
    if(self = [super init]){
        [[self addPropF:@"split"] setMaxValue:1];        
        [[self addPropF:@"lockTriangle"] setMaxValue:1];        
        [[self addPropF:@"nelsonSplit"] setMaxValue:1];        
        
    }
    
    return self;
}


-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    //    [[engine data] arrData]->insert_in_face_interior(Point_2(x,y), [[engine data] arrData]->unbounded_face());
    
    pointsBuffer.push_back(Point_2(x,y));
    
    
    //    //Create meshes
    //    for(int i=0;i<delauneys.size();i++){
    //        Mesher mesher(delauneys[i]);
    //        mesher.refine_mesh();
    //    }
    //
    //    
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    ofSetColor(100,100,100);
    
    /*glPointSize(10);
     glBegin(GL_POINTS);
     for(int i=0;i<pointsBuffer.size();i++){
     glVertex2f(pointsBuffer[i].x(), pointsBuffer[i].y());
     }
     glEnd();
     glPointSize(1);*/
    
    //    
    //    vector<Point_2> hull;
    //    CGAL::ch_graham_andrew( pointsBuffer.begin(), pointsBuffer.end(), back_inserter(hull) ); //SMart med back_inserter
    //    
    
    if(PropB(@"split")){
        glLineWidth(2);
        ofSetColor(255,0,0);
        glBegin(GL_LINE_STRIP);
        for(int i=0;i<pointsBuffer.size();i++){
            glVertex2f(CGAL::to_double(pointsBuffer[i].x()), CGAL::to_double(pointsBuffer[i].y()));
        }
        glEnd();
        
        glLineWidth(1);
        
    } else {
        glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);
        glLineWidth(2);
        ofSetColor(0,0,255);
        glBegin(GL_POLYGON);
        for(int i=0;i<pointsBuffer.size();i++){
            glVertex2f(CGAL::to_double(pointsBuffer[i].x()), CGAL::to_double(pointsBuffer[i].y()));
        }
        glEnd();
        
        glLineWidth(1);
    }
    
    ofSetLineWidth(2.0);
    for(int i=0;i<debugSegments.size();i++){
        ofVec2f p1 = ofVec2f(CGAL::to_double(debugSegments[i].source().x()), CGAL::to_double(debugSegments[i].source().y()));
        ofVec2f p2 = ofVec2f(CGAL::to_double(debugSegments[i].target().x()), CGAL::to_double(debugSegments[i].target().y()));
        
        ofSetColor(0,255,255);
        ofLine(p1.x, p1.y, p2.x, p2.y);
    }
    
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);
    
    glBegin(GL_POLYGON);
    
    for(int i=0;i<debugPolygon.size();i++){
        ofSetColor(255,100,0);
        glVertex2f(debugPolygon[i].x, debugPolygon[i].y);
    }
    glEnd();
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
    
    
    
    
    ofSetLineWidth(1.0);
    /*  
     ofSetColor(100,20,20);
     
     for(int i=0;i<delauneys.size();i++){
     Delaunay::Edge_iterator eit =delauneys[i].edges_begin();    
     glBegin(GL_LINES);
     
     for ( ; eit !=delauneys[i].edges_end(); ++eit) {
     glVertex2d(CGAL::to_double(delauneys[i].segment(eit).source().x()) , CGAL::to_double(delauneys[i].segment(eit).source().y()));
     glVertex2d(CGAL::to_double(delauneys[i].segment(eit).target().x()) , CGAL::to_double(delauneys[i].segment(eit).target().y()));
     }      
     
     glEnd();
     }
     */
    
    /*
     
     //Draw delaunay hulls
     ofSetColor(20,20,200);
     for(int u=0;u<delauneys.size();u++){
     glBegin(GL_POLYGON);        
     Delaunay::Finite_faces_iterator vit = delauneys[u].finite_faces_begin();
     for( ; vit != delauneys[u].finite_faces_end(); ++vit){     
     for(int i=0;i<3;i++){
     glVertex2f(CGAL::to_double(vit->vertex(i)->point().x()), CGAL::to_double(vit->vertex(i)->point().y()));                
     }
     }
     glEnd();
     }
     
     
     ofSetColor(20,100,20);
     
     //Draw convex hulls
     for(int u=0;u<convexPolygons.size();u++){
     glBegin(GL_POLYGON);
     
     PartPolygon_2::Vertex_iterator vit = convexPolygons[u].vertices_begin();
     for( ; vit != convexPolygons[u].vertices_end(); ++vit){
     glVertex2f(CGAL::to_double(vit->x()), CGAL::to_double(vit->y()));
     }
     glEnd();
     }
     
     
     glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
     
     ofEnableAlphaBlending();
     ofSetColor(255,255,0,100);
     
     for(int i=0;i<subtractedPolygons.size();i++){
     glBegin(GL_POLYGON);
     Polygon_2::Vertex_iterator vit = subtractedPolygons[i].outer_boundary().vertices_begin();
     for( ; vit != subtractedPolygons[i].outer_boundary().vertices_end(); ++vit){
     glVertex2f(CGAL::to_double(vit->x()), CGAL::to_double(vit->y()));
     }
     glEnd();
     }   
     */
}



- (void) split:(vector<Point_2>)points{
    float offsetVal = 0.003;
    debugSegments.clear();
    debugPolygon.clear();
    
    //Lines generation
    vector<Segment_2> lines;
    for(int i=1;i<points.size();i++){
        cout<<"points.push_back(Point_2("<<points[i].x()<<", "<<points[i].y()<<"));"<<endl;
        
        lines.push_back(Segment_2(points[i-1], points[i]));
    }
    
    vector<Polygon_2> hulls = [[engine arrangement] hulls];
    
    //Offset to the right
    vector<Segment_2> linesModified;                
    Point_2 p1 = points[0];
    for(int i=1;i<points.size();i++){
        ofVec2f offset = ofVec2f(offsetVal,0);
        ofVec2f dir = point2ToVec2(points[i]) - point2ToVec2(points[i-1]);
        if(i != points.size() -1){
            dir = point2ToVec2(points[i+1]) - point2ToVec2(points[i-1]);
        }
        offset.rotate(-dir.angle(ofVec2f(0,1)));
        
        
        Point_2 p2 = Point_2(points[i].x()+offset.x, points[i].y()+offset.y);
        
        if(i == points.size()-1){
            linesModified.push_back(Segment_2(p1,points[i]));                        
        } else {
            linesModified.push_back(Segment_2(p1,p2));
        }
        p1 = p2;
    }
    
    //Insert the lines in arrangement 
    for(int i=0;i<lines.size();i++){
        CGAL::insert(*[[engine arrangement] arrData],  lines[i]);
    }
    
    //Insert offset
    for(int i=0;i<linesModified.size();i++){                    
        CGAL::insert(*[[engine arrangement] arrData],  linesModified[i]);
    }
    
    
    //Polygon
    vector<ofPoint> polygon;
    for(int i=0;i<lines.size();i++){
        if(i==0)
            polygon.push_back(point2ToVec2(lines[i].source()));
        polygon.push_back(point2ToVec2(lines[i].target()));
    }
    
    for(int i=linesModified.size()-1;i>=0;i--){
        polygon.push_back(point2ToVec2(linesModified[i].source()));
    }
    
    for(int i=0;i<polygon.size();i++){
        debugPolygon.push_back(polygon[i]);
    }
    
    /*{
     ofVec2f offset = ofVec2f(offsetVal,0);
     ofVec2f dir = point2ToVec2(pointsBuffer[1]) - point2ToVec2(pointsBuffer[0]);
     offset.rotate(dir.angle(ofVec2f(0,1)));
     polygon.push_back(ofPoint(CGAL::to_double(pointsBuffer[0].x())+offset.x,CGAL::to_double(pointsBuffer[0].y())+offset.y,0));
     }
     
     for(int i=1;i<pointsBuffer.size();i++){
     polygon.push_back(ofPoint(CGAL::to_double(pointsBuffer[i].x()),CGAL::to_double(pointsBuffer[i].y()),0));
     }
     for(int i=pointsBuffer.size()-2;i>=0;i--){
     ofVec2f offset = ofVec2f(offsetVal,0);
     ofVec2f dir = point2ToVec2(pointsBuffer[i]) - point2ToVec2(pointsBuffer[i-1]);
     offset.rotate(dir.angle(ofVec2f(0,1)));
     
     polygon.push_back(ofPoint(CGAL::to_double(pointsBuffer[i].x())+offset.x, CGAL::to_double(pointsBuffer[i].y())+offset.y,0));
     }
     */
    
    
    
    
    
    
    
    
    //    __block int u=0;
    __block vector<Halfedge_handle> deleteHandles;
    [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
        eit->data().crumbleOptimalLength = -1;
        eit->data().crumbleOptimalAngle = -1;
        eit->source()->data().hullOptimalAngle = -1;
        eit->target()->data().hullOptimalAngle = -1;
        
        
        ofVec2f p1 = handleToVec2(eit->source());
        ofVec2f p2 = handleToVec2(eit->target());
        ofVec2f p3 = p2+(p1-p2)*0.5;
        Segment_2 arrSegment = Segment_2(eit->source()->point(), eit->target()->point());
        
        // if(ofInsidePoly(p1.x, p1.y, polygon) || ofInsidePoly(p2.x, p2.y, polygon) || ofInsidePoly(p3.x, p3.y, polygon))){
        if(ofInsidePoly(p3.x, p3.y, polygon)){
            bool intersection = NO;
            
            for(int i=0;i<lines.size();i++){                        
                if(CGAL::do_intersect(arrSegment, lines[i])){
                    if(lines[i].has_on(arrSegment.source()) && lines[i].has_on(arrSegment.target())){
                        intersection = YES;
                        //                                    debugSegments.push_back(arrSegment);
                    }
                }
            }
            for(int i=0;i<linesModified.size();i++){                        
                if(CGAL::do_intersect(arrSegment, linesModified[i])){
                    if(linesModified[i].has_on(arrSegment.source()) && linesModified[i].has_on(arrSegment.target())){
                        intersection = YES;
                        //                                    debugSegments.push_back(arrSegment);
                    }
                }
            }
            
            
            if(!intersection){
                //                            cout<<"!Intersection "<<u++<<endl;
                eit->face()->data().hole = YES;
                eit->twin()->face()->data().hole = YES;
                
                debugSegments.push_back(arrSegment);
                deleteHandles.push_back(eit);
            } else {  
                bool cont = true;
                switch(CGAL::bounded_side_2(hulls[0].vertices_begin(), hulls[0].vertices_end(),Point_2(p1.x,p1.y), Kernel())) {
                    case CGAL::ON_BOUNDED_SIDE :
                        //    cout << " is inside the polygon.\n";
                        break;
                    case CGAL::ON_BOUNDARY:
                        //   cout << " is on the polygon boundary.\n";
                        break;
                    case CGAL::ON_UNBOUNDED_SIDE:
                        cout << " is outside the polygon.\n";
                        deleteHandles.push_back(eit);
                        cont = false;
                        break;
                }
                if(cont){
                    switch(CGAL::bounded_side_2(hulls[0].vertices_begin(), hulls[0].vertices_end(),Point_2(p2.x,p2.y), Kernel())) {
                        case CGAL::ON_BOUNDED_SIDE :
                            //    cout << " is inside the polygon.\n";
                            break;
                        case CGAL::ON_BOUNDARY:
                            //   cout << " is on the polygon boundary.\n";
                            break;
                        case CGAL::ON_UNBOUNDED_SIDE:
                            cout << " is outside the polygon.\n";
                            deleteHandles.push_back(eit);
                            break;
                    }
                }
            }
            /*else {
             
             ofVec3f pos = handleToVec3(eit->target());
             setHandlePos(pos*ofVec3f(1,1,0), eit->target());
             
             pos = handleToVec3(eit->source());
             setHandlePos(pos*ofVec3f(1,1,0), eit->source());
             
             }
             */
        }
        
        
        
    }];
    
    
    
    [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
        if(eit->target()->degree() <= 1 || eit->source()->degree() <= 1){
            deleteHandles.push_back(eit);
        }
    }];
    
    for(int i=0;i<deleteHandles.size();i++){
        [[engine arrangement] arrData]->remove_edge(deleteHandles[i]);
    }
    
    
    
    //                ofVec2f p = point2ToVec2(pointsBuffer[0]) + offset*0.5;
    //                Point_2 p2 = Point_2(p.x, p.y);
    //                CGAL::Object obj = [[engine arrangement] cgalObjectAtPoint:p2];
    //                
    //                Arrangement_2::Face_const_handle      faceConst;
    //                
    //                if (CGAL::assign (faceConst, obj)) {
    //                    cout<<"Face"<<endl;
    //                    Arrangement_2::Face_handle face = [[engine arrangement] arrData]->non_const_handle(faceConst);
    //                    face->data().hole = YES;
    //                }
    //                
    [[engine arrangement] updateHoles];
    
}


-(void)update:(NSDictionary *)drawingInformation{
    if(PropB(@"lockTriangle")){
        [Prop(@"lockTriangle") setBoolValue:NO];
        
        pointsBuffer.clear();
        
        ofVec2f _p1 = [GetPlugin(Mask) triangleFloorCoordinate:0];
        ofVec2f _p2 = [GetPlugin(Mask) triangleFloorCoordinate:1];
        float lineLength = _p1.distance(_p2);
        
        pointsBuffer.push_back(vec2ToPoint2(_p1));
        pointsBuffer.push_back(vec2ToPoint2(_p2));        
        
        if(pointsBuffer.size() > 1){        
            debugSegments.clear();
            debugPolygon.clear();
            
            //Lines generation
            vector<Segment_2> lines;
            for(int i=1;i<pointsBuffer.size();i++){              
                lines.push_back(Segment_2(pointsBuffer[i-1], pointsBuffer[i]));
            }
            
            //Insert the lines in arrangement 
            for(int i=0;i<lines.size();i++){
                CGAL::insert(*[[engine arrangement] arrData],  lines[i]);
            }
            
            __block vector<Halfedge_handle> deleteHandles;
            [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
                eit->data().crumbleOptimalLength = -1;
                eit->data().crumbleOptimalAngle = -1;
                eit->source()->data().hullOptimalAngle = -1;
                eit->target()->data().hullOptimalAngle = -1;
                
                
                ofVec2f p1 = handleToVec2(eit->source());
                ofVec2f p2 = handleToVec2(eit->target());
                ofVec2f p3 = p2+(p1-p2)*0.5;
                Segment_2 arrSegment = Segment_2(eit->source()->point(), eit->target()->point());
                
                
                bool intersection = NO;
                
                for(int i=0;i<lines.size();i++){                        
                    if(CGAL::do_intersect(arrSegment, lines[i])){
                        if(lines[i].has_on(arrSegment.source()) && lines[i].has_on(arrSegment.target())){
                            intersection = YES;
                        }
                    }
                }
                
                
                if(intersection){
                    eit->source()->data().physicsLock = YES;
                    eit->target()->data().physicsLock = YES;
                    debugSegments.push_back(arrSegment);
                } 
                
                float dist1 = distanceVecToLine(p1, _p1, _p2);
                float dist2 = distanceVecToLine(p2, _p1, _p2);                
                ofVec2f theP = p1;
                
                float dist = dist1;
                if(dist2 < dist){
                    dist = dist2;
                    theP = p2;
                }
                
                float maxDist = 0.15;
                float minDist = 0.08;
                
                if(dist < maxDist ){
                    float __dist1 = theP.distance(_p1);
                    float __dist2 = theP.distance(_p2);
                    
                    if(__dist1 < lineLength + maxDist && __dist2 < lineLength + maxDist){
                        if(dist < minDist){
                            eit->source()->data().physicsLock = YES;
                            eit->target()->data().physicsLock = YES;
                        } else {
                            float f = ((maxDist-minDist) - (dist-minDist))/maxDist;
                            if(eit->source()->data().physicsLock == 0){
                                eit->source()->data().physicsLock = f;
                            }
                            if(eit->target()->data().physicsLock == 0){
                                eit->target()->data().physicsLock = f;
                            }
                        }
                    }
                }
                
            }];     
        }      
    }
    
    if(PropB(@"nelsonSplit")){
        if([GetTracker() getTrackerCoordinatesCentroids].size() > 0){
            ofVec2f triangle1 = [GetPlugin(Mask) triangleFloorCoordinate:0];
            ofVec2f triangle2 = [GetPlugin(Mask) triangleFloorCoordinate:1];
            
            ofVec2f tracker = [GetTracker() getTrackerCoordinatesCentroids][0];
            ofVec2f __dir = tracker - triangle1;
            ofVec2f norm = ofVec2f(-__dir.y,__dir.x);
            
            [Prop(@"nelsonSplit") setBoolValue:NO];
            
            ofVec2f secondLast = ofVec2f(0.393145, 0.65035);
            
            vector<Point_2> points;
            points.push_back( vec2ToPoint2(triangle2 + ofVec2f(0,0.1)));
            points.push_back( vec2ToPoint2(triangle1));
            points.push_back( vec2ToPoint2(triangle1+__dir*0.5+ofVec2f(0.05,0)));
            points.push_back( vec2ToPoint2(triangle1+__dir));
            points.push_back( vec2ToPoint2(triangle1+__dir*2+ofVec2f(-0.1,0)));            
            [self split:points];
        }
    }
}


- (void) controlKeyPressed:(int)_key modifier:(int)modifier{
    NSLog(@"Key %i",_key);
    
    if(_key == 36){
        //If 3 or more points, we can form a polygon
        if(PropB(@"split")){
            if(pointsBuffer.size() > 1){        
                [self split:pointsBuffer];
            }                
        } else {
            if(pointsBuffer.size() > 2){        
                subtractedPolygons.clear();
                delauneys.clear();
                convexPolygons.clear();
                meshes.clear();
                
                
                //Create some work polygons
                Polygon_2 subtractedPolygon = Polygon_2(pointsBuffer.begin(), pointsBuffer.end());
                subtractedPolygons.push_back(Polygon_with_holes_2(subtractedPolygon));
                
                //Must be simple (not self-intersecting)
                if(subtractedPolygon.is_simple()){
                    //Get the hull from arrangements
                    vector< Polygon_2> hull = [[engine arrangement] hulls];
                    
                    //For each hull, check the intersection
                    for(int i=0; i<hull.size();i++){
                        if(CGAL::do_intersect(hull[i],subtractedPolygon)){ 
                            //Create the intersection
                            Pwh_list_2 intR;
                            CGAL::intersection (subtractedPolygon,
                                                hull[i], 
                                                back_inserter(intR));
                            
                            //Find the difference between the intersection, and the input
                            Pwh_list_2  intR2;
                            for(int u=0;u<intR.size();u++){
                                vector<Polygon_with_holes_2> copy = subtractedPolygons;
                                subtractedPolygons.clear();
                                
                                for(int j=0;j<copy.size();j++){
                                    CGAL::symmetric_difference(intR[u].outer_boundary(), 
                                                               copy[j], 
                                                               std::back_inserter(subtractedPolygons));
                                }
                            }
                        }
                    }
                    
                    //Partitionate the subtracted polygon
                    for(int j=0;j<subtractedPolygons.size();j++){
                        Polygon_2 pgn = Polygon_2(subtractedPolygons[j].outer_boundary().vertices_begin(), 
                                                  subtractedPolygons[j].outer_boundary().vertices_end());
                        if(pgn.is_simple()){                    
                            //Hvis den vender forkert, vender vi den selv
                            if(pgn.orientation() == CGAL::CLOCKWISE){
                                pgn.reverse_orientation();
                            }                    
                            if(pgn.orientation() == CGAL::COUNTERCLOCKWISE){                
                                //Lav convexe polygoner
                                CGAL::optimal_convex_partition_2(pgn.vertices_begin(),
                                                                 pgn.vertices_end(),
                                                                 std::back_inserter(convexPolygons));
                                
                                
                                //Create delaunay polygon
                                for(int i=0;i<convexPolygons.size();i++){
                                    Delaunay dt;
                                    dt.insert(convexPolygons[i].vertices_begin(), 
                                              convexPolygons[i].vertices_end());
                                    delauneys.push_back(dt);
                                }
                                
                            }
                        }
                    }
                }
            }
            
            
            
            /*     for(int u=0;u<convexPolygons.size();u++){
             CGAL::insert(*[[engine arrangement] arrData],  convexPolygons[u].edges_begin(), convexPolygons[u].edges_end());
             }*/
            for(int u=0;u<delauneys.size();u++){
                //            cout<<endl<<endl<<endl;
                //            cout<<"Delaunay #"<<u<<endl;
                //            cout<<"Initial #pts "<<delauneys[u].number_of_vertices()<<endl;
                //            CGAL::make_conforming_Delaunay_2(delauneys[u]);
                //            cout<<"Conformning delaynay 2 #pts "<<delauneys[u].number_of_vertices()<<endl;
                //            
                //            CGAL::make_conforming_Gabriel_2(delauneys[u]);
                //            cout<<"Conformning gabriel 2 #pts "<<delauneys[u].number_of_vertices()<<endl;
                //
                //            
                Delaunay::Finite_faces_iterator vit = delauneys[u].finite_faces_begin();
                for( ; vit != delauneys[u].finite_faces_end(); ++vit){     
                    for(int i=0;i<3;i++){
                        /*                    Segment_2 seg = Segment_2(vit->vertex(i)->point(), 
                         vit->vertex(i + ((i==2)? -2 : +1))->point);
                         Segment_2 seg = Segment_2(Point_2(0,0), 
                         Point_2(1,1));
                         
                         */                    
                        //   @synchronized([engine arrangement]){
                        CGAL::insert(*[[engine arrangement] arrData],  delauneys[u].segment(vit, i));
                        
                        
                        // }
                        
                        //                    [[engine arrangement] arrData]->insert_in_face_interior(delauneys[u].segment(vit, i), [[engine arrangement] arrData]->unbounded_face());
                        
                    }
                }
                
            }
            
            __block int i=0;
            [[engine arrangement] enumerateFaces:^(Arrangement_2::Face_iterator fit) {
                if(fit->is_unbounded()){
                    cout<<"Face #"<<++i<<" is unbounded "<<endl;
                } else {
                    cout<<"Face #"<<++i<<" Number outer ccbs: "<<fit->number_of_outer_ccbs()<<"  "<<endl;
                    
                    int vertices = 0;
                    Arrangement_2::Ccb_halfedge_circulator circ;
                    Arrangement_2::Ccb_halfedge_circulator curr = circ = fit->outer_ccb();
                    do {
                        vertices ++;
                    } while (++curr != circ);
                    cout<<"Number vertices: "<<vertices<<endl;
                    
                    if(vertices > 3){
                        Delaunay dl;
                        curr = circ = fit->outer_ccb();
                        do {
                            dl.push_back(curr->source()->point());
                        } while (++curr != circ);
                        
                        cout<<"Delaunay vertices: "<<dl.number_of_vertices()<<endl;
                        
                        Delaunay::Finite_faces_iterator vit = dl.finite_faces_begin();
                        for( ; vit != dl.finite_faces_end(); ++vit){     
                            for(int i=0;i<3;i++){
                                CGAL::insert(*[[engine arrangement] arrData],  dl.segment(vit, i));
                            }
                        }
                    }
                }
                
                
            }];
            
            
            
            //  
        }
    }
    pointsBuffer.clear();
    subtractedPolygons.clear();
    delauneys.clear();
    convexPolygons.clear();
}

@end

