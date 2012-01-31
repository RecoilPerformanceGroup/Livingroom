//
//  PolyInputSimpleMouseDraw.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "PolyInputSimpleMouseDraw.h"


@implementation PolyInputSimpleMouseDraw


-(id)init{
    if(self = [super init]){
        [[self addPropF:@"split"] setMaxValue:1];        
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

- (void) controlKeyPressed:(int)_key modifier:(int)modifier{
    NSLog(@"Key %i",_key);
    
    if(_key == 36){
        //If 3 or more points, we can form a polygon
        if(PropB(@"split")){
            if(pointsBuffer.size() > 1){        
                //Lines generation
                vector<Segment_2> lines;
                for(int i=1;i<pointsBuffer.size();i++){
                    lines.push_back(Segment_2(pointsBuffer[i-1], pointsBuffer[i]));
                }
                
                //Insert the lines in arrangement 
                for(int i=0;i<lines.size();i++){
                    CGAL::insert(*[[engine arrangement] arrData],  lines[i]);
                }
                
                //Offset to the right
                vector<Segment_2> linesModified;
                ofVec2f offset = ofVec2f(0.01,0);
                for(int i=1;i<pointsBuffer.size();i++){
                    Point_2 p1 = Point_2(pointsBuffer[i-1].x()+offset.x, pointsBuffer[i-1].y()+offset.y);
                    Point_2 p2 = Point_2(pointsBuffer[i].x()+offset.x, pointsBuffer[i].y()+offset.y);
                    
                    if(i == pointsBuffer.size()-1){
                        linesModified.push_back(Segment_2(p1,pointsBuffer[i]));                        
                    } else {
                        linesModified.push_back(Segment_2(p1,p2));
                    }
                }
                
                //Insert offset
                for(int i=0;i<linesModified.size();i++){                    
                    CGAL::insert(*[[engine arrangement] arrData],  linesModified[i]);
                }
                
                
                vector<ofPoint> polygon;
                for(int i=0;i<pointsBuffer.size();i++){
                    polygon.push_back(ofPoint(CGAL::to_double(pointsBuffer[i].x()),CGAL::to_double(pointsBuffer[i].y()),0));
                }
                for(int i=pointsBuffer.size()-2;i>=0;i--){
                    polygon.push_back(ofPoint(CGAL::to_double(pointsBuffer[i].x())+offset.x, CGAL::to_double(pointsBuffer[i].y())+offset.y,0));
                }
                
                /*      debugSegments.clear();
                 for(int i=1;i<polygon.size();i++){
                 debugSegments.push_back(Segment_2(Point_2(polygon[i-1].x, polygon[i-1].y), Point_2(polygon[i].x, polygon[i].y)));
                 }
                 */
                
                // ofInsidePoly(<#float x#>, <#float y#>, <#const vector<ofPoint> &poly#>)
                
                //Now find what we need to delete
                //Find intersections
                /*      __block int u=0;
                 debugSegments.clear();
                 [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
                 for(int i=0;i<lines.size();i++){
                 Segment_2 arrSegment = Segment_2(eit->source()->point(), eit->target()->point());
                 
                 if(CGAL::do_intersect(arrSegment, lines[i])){
                 if(lines[i].has_on(arrSegment.source()) && lines[i].has_on(arrSegment.target())){
                 cout<<"Intersection "<<u++<<endl;
                 debugSegments.push_back(arrSegment);
                 }
                 }
                 }
                 }];*/
                
                __block int u=0;
                debugSegments.clear();
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
                            cout<<"!Intersection "<<u++<<endl;
                            debugSegments.push_back(arrSegment);
                            deleteHandles.push_back(eit);
                        }
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
                
                /*
                vector< vector<Arrangement_2::Halfedge_const_handle> > boundaryHandles = [[engine arrangement] boundaryHandles];
                
                for(int i=0;i<boundaryHandles.size();i++){
                    for(int u=1;u<boundaryHandles[i].size();u++){
                        Halfedge_handle h1 = [[engine arrangement] arrData]->non_const_handle(boundaryHandles[i][u-1]);
                        Halfedge_handle h2 = [[engine arrangement] arrData]->non_const_handle(boundaryHandles[i][u]);
                        h1->target()->data().hullOptimalAngle = -1;
                        h2->target()->data().hullOptimalAngle = -1;
                    }
                }*/

               /* 
                
                Arrangement_2 * newArr = new Arrangement_2();
                [[engine arrangement] enumerateEdges:^(Arrangement_2::Edge_iterator eit) {
                    bool doDelete = NO;
                    for(int i=0;i<deleteHandles.size();i++){
                        if(deleteHandles[i] == eit)
                            doDelete = YES;
                    }
                    if(!doDelete){
                        Segment_2 arrSegment = Segment_2(eit->source()->point(), eit->target()->point());
                        CGAL::insert(*newArr,  arrSegment);
                    }
                }];
                
                [[engine arrangement] setArrData:newArr];*/
                
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

