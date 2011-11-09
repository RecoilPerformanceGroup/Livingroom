//
//  PolyInputSimpleMouse.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "PolyInputSimpleMouse.h"



@implementation PolyInputSimpleMouse

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    NSLog(@"%f %f",x,y);
    
    //    [[engine data] arr]->insert_in_face_interior(Point_2(x,y), [[engine data] arr]->unbounded_face());
    
    pointsBuffer.push_back(Point_2(x,y));
    
    
    
    
    
    
    if(pointsBuffer.size() > 2){
        
        subtractedPolygons.clear();
        delauneys.clear();
        convexPolygons.clear();
        intR.clear();
        
        //Create hull polygon
        Polygon_2 subtractedPolygon = Polygon_2(pointsBuffer.begin(), pointsBuffer.end());
        
        if(subtractedPolygon.is_simple()){
            cout<<"Is simple"<<endl;
            vector< Polygon_2> hull = [[engine arrangement] hulls];
            for(int i=0; i<hull.size();i++){
                if(CGAL::do_intersect(hull[i],subtractedPolygon)){ 
                    CGAL::intersection (subtractedPolygon,hull[i], std::back_inserter(intR));
                    
                    cout<<"Intersection size: "<<intR.size()<<endl;
                    
                    for(int u=0;u<intR.size();u++){
                        cout<<"Is bounded: "<<!intR[u].is_unbounded()<<"Number holes: "<<intR[u].number_of_holes()<<endl;;
                        cout<<" Vertices: "<<intR[u].outer_boundary().size()<<endl;
                    }
                    
                    Pwh_list_2  intR2;
                    for(int u=0;u<intR.size();u++){
                        //cout<<u<<": is_valid: "<<intR[u].outer_boundary().is_valid()<<endl;
                        
                        CGAL::symmetric_difference (intR[u].outer_boundary(), subtractedPolygon, std::back_inserter(subtractedPolygons));
                    }
                    
                    cout<<"subtractedPolygons size: "<<subtractedPolygons.size()<<endl;
                    
                } else {
                    subtractedPolygons.push_back(Polygon_with_holes_2(subtractedPolygon));
                }
            }
            if(hull.size() == 0){
                subtractedPolygons.push_back(Polygon_with_holes_2(subtractedPolygon));
            }
            
            for(int j=0;j<subtractedPolygons.size();j++){
                Polygon_2 pgn = Polygon_2(subtractedPolygons[j].outer_boundary().vertices_begin(), subtractedPolygons[j].outer_boundary().vertices_end());
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
                        
                        
                        for(int i=0;i<convexPolygons.size();i++){
                            Delaunay dt;
                            dt.insert(convexPolygons[i].vertices_begin(), convexPolygons[i].vertices_end());
                            delauneys.push_back(dt);
                        }
                    }
                }
            }
        }
    }
    
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
    
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);
    glLineWidth(2);
    glBegin(GL_POLYGON);
    for(int i=0;i<pointsBuffer.size();i++){
        glVertex2f(CGAL::to_double(pointsBuffer[i].x()), CGAL::to_double(pointsBuffer[i].y()));
    }
    glEnd();
    
    glLineWidth(1);
    
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
    
    
}

- (void) controlKeyPressed:(int)key modifier:(int)modifier{
    NSLog(@"Key %i",key);
    
    
    
    
    if(key == 36){
        for(int u=0;u<convexPolygons.size();u++){
            CGAL::insert(*[[engine arrangement] arr],  convexPolygons[u].edges_begin(), convexPolygons[u].edges_end());
        }
        //  
    }
    pointsBuffer.clear();
        subtractedPolygons.clear();
    delauneys.clear();
    convexPolygons.clear();
    intR.clear();
}

@end

