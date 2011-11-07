#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Polygon_2.h>

//#include <CGAL/Projection_traits_xy_3.h>
#include <CGAL/Constrained_Delaunay_triangulation_2.h>


#import "PolygonWorld.h"

typedef CGAL::Exact_predicates_inexact_constructions_kernel K;
typedef K::Point_2 Point2;
typedef CGAL::Polygon_2<K> Polygon_2;

//typedef CGAL::Projection_traits_xy_3<K>  Gt;
typedef CGAL::Constrained_Delaunay_triangulation_2<K> Delaunay;

typedef Delaunay::Edge_iterator  Edge_iterator;


Polygon_2 pgn;
Delaunay dt;


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
    
    pgn = Polygon_2();
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
    
}
//
//----------------
//



-(void)controlDraw:(NSDictionary *)drawingInformation{    
    
    cW = ofGetWidth();
    cH = ofGetHeight();
    
    ofBackground(0, 0, 0);
    glScaled(ofGetWidth(), ofGetHeight(),1);
    
    
    if(mode == 0){
        glColor3f(255,255,255);
        
        glBegin(GL_LINE_STRIP);
        
        for(int i=0;i<pgn.size();i++){
            glVertex2d(pgn[i].x() , pgn[i].y());
        }
        
        glEnd();
    }
    
    if(mode == 1){
        glColor3f(255,0,255);

        Edge_iterator eit =dt.edges_begin();
        
        glBegin(GL_LINES);

        for ( ; eit !=dt.edges_end(); ++eit) {
            glVertex2d(dt.segment(eit).source().x() , dt.segment(eit).source().y());
            glVertex2d(dt.segment(eit).target().x() , dt.segment(eit).target().y());
        }      
        
        glEnd();
    }
    
}

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    x /= cW;
    y /= cH;
    
    pgn.push_back(Point2(x,y));
}

- (IBAction)delaunay:(id)sender {
    mode = 1;
    
    dt.clear();
    
/*    for(int i=0;i<pgn.size()-1;i++){
        dt.insert_constraint(pgn[i], pgn[i+1]);
    }   
  */  
    
    dt.insert(pgn.vertices_begin(), pgn.vertices_end());

    
    cout<<"Delunæ: "<<dt.is_valid()<<endl;
}

- (IBAction)clear:(id)sender {
    mode = 0;
    pgn.clear();
}
@end
