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
//    [[engine data] arr]->insert_in_face_interior(Point_2(x,y), [[engine data] arr]->unbounded_face());
        
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
    
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);
    glLineWidth(2);
    glBegin(GL_POLYGON);
    for(int i=0;i<pointsBuffer.size();i++){
        glVertex2f(CGAL::to_double(pointsBuffer[i].x()), CGAL::to_double(pointsBuffer[i].y()));
    }
    glEnd();
    
    glLineWidth(1);
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

- (void) controlKeyPressed:(int)key modifier:(int)modifier{
    NSLog(@"Key %i",key);
    
    if(key == 36){
        //If 3 or more points, we can form a polygon
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
            CGAL::insert(*[[engine arrangement] arr],  convexPolygons[u].edges_begin(), convexPolygons[u].edges_end());
        }*/
        for(int u=0;u<delauneys.size();u++){
            Delaunay::Finite_faces_iterator vit = delauneys[u].finite_faces_begin();
            for( ; vit != delauneys[u].finite_faces_end(); ++vit){     
                for(int i=0;i<3;i++){
/*                    Segment_2 seg = Segment_2(vit->vertex(i)->point(), 
                                              vit->vertex(i + ((i==2)? -2 : +1))->point);
                    Segment_2 seg = Segment_2(Point_2(0,0), 
                                              Point_2(1,1));

  */                  
                    CGAL::insert(*[[engine arrangement] arr],  delauneys[u].segment(vit, i));

//                    [[engine arrangement] arr]->insert_in_face_interior(delauneys[u].segment(vit, i), [[engine arrangement] arr]->unbounded_face());

                }
            }
            
        }
        
        //  
    }
    pointsBuffer.clear();
    subtractedPolygons.clear();
    delauneys.clear();
    convexPolygons.clear();
}

@end

