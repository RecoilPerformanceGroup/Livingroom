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
    
    
    
    
    if(pointsBuffer.size() > 3){
        //Lav en polygon, så vi kan lave nogle check på den
        PartPolygon_2 pgn(pointsBuffer.begin(), pointsBuffer.end());
        
        if(pgn.is_simple()){
            
            //Hvis den vender forkert, vender vi den selv
            if(pgn.orientation() == CGAL::CLOCKWISE){
                pgn.reverse_orientation();
            }
            
            if(pgn.orientation() == CGAL::COUNTERCLOCKWISE){                
                //Lav convexe polygoner
                convexPolygons.clear();
                CGAL::optimal_convex_partition_2(pgn.vertices_begin(),
                                                 pgn.vertices_end(),
                                                 std::back_inserter(convexPolygons));
                
                delauneys.clear();
                
                for(int i=0;i<convexPolygons.size();i++){
                    Delaunay dt;
                    dt.insert(convexPolygons[i].vertices_begin(), convexPolygons[i].vertices_end());
                    delauneys.push_back(dt);
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
        glVertex2f(pointsBuffer[i].x(), pointsBuffer[i].y());
    }
    glEnd();
    
    glLineWidth(1);
    
    ofSetColor(100,20,20);
    
    for(int i=0;i<delauneys.size();i++){
        Delaunay::Edge_iterator eit =delauneys[i].edges_begin();    
        glBegin(GL_LINES);
        
        for ( ; eit !=delauneys[i].edges_end(); ++eit) {
            glVertex2d(delauneys[i].segment(eit).source().x() , delauneys[i].segment(eit).source().y());
            glVertex2d(delauneys[i].segment(eit).target().x() , delauneys[i].segment(eit).target().y());
        }      
        
        glEnd();
    }
    
    
    ofSetColor(20,100,20);
    
    //Draw convex hulls
    for(int u=0;u<convexPolygons.size();u++){
        glBegin(GL_POLYGON);
        
        PartPolygon_2::Vertex_iterator vit = convexPolygons[u].vertices_begin();
        for( ; vit != convexPolygons[u].vertices_end(); ++vit){
            glVertex2f(vit->x(), vit->y());
        }
        glEnd();
    }
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_POLYGON);
    
}

@end

