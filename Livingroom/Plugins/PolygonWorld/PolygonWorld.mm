#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Polygon_2.h>

//#include <CGAL/Projection_traits_xy_3.h>
#include <CGAL/Constrained_Delaunay_triangulation_2.h>
#include <CGAL/Delaunay_mesher_2.h>
#include <CGAL/Delaunay_mesh_face_base_2.h>
#include <CGAL/Delaunay_mesh_size_criteria_2.h>

#import "PolygonWorld.h"
#import <ofxCocoaPlugins/Keystoner.h>

typedef CGAL::Exact_predicates_inexact_constructions_kernel K;
typedef CGAL::Triangulation_vertex_base_2<K> Vb;
typedef CGAL::Delaunay_mesh_face_base_2<K> Fb;
typedef CGAL::Triangulation_data_structure_2<Vb, Fb> Tds;
typedef CGAL::Constrained_Delaunay_triangulation_2<K, Tds> CDT;
typedef CGAL::Delaunay_mesh_size_criteria_2<CDT> Criteria;
typedef CGAL::Delaunay_mesher_2<CDT, Criteria> Mesher;

typedef CDT::Edge_iterator          Edge_iterator;
typedef CDT::Finite_faces_iterator  Finite_faces_iterator;

typedef CDT::Vertex_handle Vertex_handle;
typedef CDT::Point Point2;

CDT cdt;
Mesher * mesher;

@implementation PolygonWorld

- (id)init{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
    mode = 0;
    
    Vertex_handle va = cdt.insert(Point2(0,0));
    Vertex_handle vb = cdt.insert(Point2(1,0));
    Vertex_handle vc = cdt.insert(Point2(1,1));
    Vertex_handle vd = cdt.insert(Point2(0,1));
    cdt.insert(Point2(0.5, 0.6));
    
    cdt.insert_constraint(va, vb);
    cdt.insert_constraint(vb, vc);
    cdt.insert_constraint(vc, vd);
    cdt.insert_constraint(vd, va);
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
}

//
//----------------
//


-(void)draw:(NSDictionary *)drawingInformation{
    
    
    ofBackground(0, 0, 0);
    ofEnableAlphaBlending();
    
//    ApplySurface(@"Bla");

    ofFill();
    
//    ofColor(255,255,255);
    
//    ofRect(0,0,Aspect(@"Bla",0),1);
    
    Finite_faces_iterator fit = cdt.faces_begin();

    int i = 0;

//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    for ( ; fit !=cdt.faces_end(); ++fit) {

        glBegin(GL_POLYGON);

        glColor4f(1,1,(0.8+(sinf(i*33.451)*(0.02-cdt.triangle(fit).area()))), 
                  0.1+(cdt.triangle(fit).area()*50)
                  );
        
        glVertex2d(cdt.triangle(fit).vertex(0).x() , cdt.triangle(fit).vertex(0).y());
        glVertex2d(cdt.triangle(fit).vertex(1).x() , cdt.triangle(fit).vertex(1).y());
        glVertex2d(cdt.triangle(fit).vertex(2).x() , cdt.triangle(fit).vertex(2).y());
        glVertex2d(cdt.triangle(fit).vertex(0).x() , cdt.triangle(fit).vertex(0).y());
    
        i++;

        glEnd();

    }
 
//    glPolygonMode(GL_FRONT_AND_BACK, GL_POLYGON);
    
    ofColor(255,0,0,255);
    
    ofCircle(cMouseX, cMouseY, 0.01);
    
//    PopSurface();
    
}
//
//----------------
//



-(void)controlDraw:(NSDictionary *)drawingInformation{    
    
    cW = ofGetWidth();
    cH = ofGetHeight();
    
    ofBackground(0, 0, 0);
    glScaled(ofGetWidth(), ofGetHeight(),1);
    
    /*if(mode == 0){
        glColor3f(255,255,255);
        
        glBegin(GL_LINE_STRIP);
        
        for(int i=0;i<pgn.size();i++){
            glVertex2d(pgn[i].x() , pgn[i].y());
        }
        
        glEnd();
    }
    
    if(mode == 1){
    */    
    
    glColor3f(255,0,255);

    Edge_iterator eit =cdt.edges_begin();
        
        glBegin(GL_LINES);

        for ( ; eit !=cdt.edges_end(); ++eit) {
            glVertex2d(cdt.segment(eit).source().x() , cdt.segment(eit).source().y());
            glVertex2d(cdt.segment(eit).target().x() , cdt.segment(eit).target().y());
        }      
        
        glEnd();
   /* }*/
    
}

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    x /= cW;
    y /= cH;
    
    cdt.push_back(Point2(x,y));
    //    cdt.insert_constraint(Point2(0.5,0.5),Point2(x,y));
}

-(void)controlMouseMoved:(float)x y:(float)y {
    x /= cW;
    y /= cH;
    
    cMouseX = x;
    cMouseY = y;
    
    cout << x << ", " << y << endl;
}

- (IBAction)delaunay:(id)sender {
    mode = 1;
    
  /*dt.clear();

    
    dt.insert(pgn.vertices_begin(), pgn.vertices_end());

    
    cout<<"Delunæ: "<<dt.is_valid()<<endl;*/
    
    mesher = new Mesher(cdt);
    mesher->refine_mesh();

}

- (IBAction)clear:(id)sender {
    mode = 0;
    cdt.clear();
}
@end
