#import "PolygonWorld.h"

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
//    ofBackground(0);
//    
//    
//    
//    
//    MyMesh::ConstFaceIter    fIt(mesh.faces_begin()), fEnd(mesh.faces_end());
//    
//    
//    MyMesh::ConstFaceVertexIter fvIt;
//    
//    ofEnableAlphaBlending();
//    
//    
//    
//    ofSetColor(255, 255, 255);
//    
//    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
//    glBegin(GL_TRIANGLES);
//    for (; fIt!=fEnd; ++fIt)
//    {
//        fvIt = mesh.cfv_iter(fIt.handle()); 
//        glVertex3fv( &mesh.point(fvIt)[0] );
//        //    cout<<mesh.point(fvIt)[0]<<"  "<<mesh.point(fvIt)[1]<<endl;
//        ++fvIt;
//        glVertex3fv( &mesh.point(fvIt)[0] );
//        //     cout<<mesh.point(fvIt)[0]<<"  "<<mesh.point(fvIt)[1]<<endl;
//        ++fvIt;
//        glVertex3fv( &mesh.point(fvIt)[0] );
//        //  cout<<mesh.point(fvIt)[0]<<"  "<<mesh.point(fvIt)[1]<<endl;
//        //    cout<<" ---- "<<endl;
//    }
//    // cout<<"-- end --"<<endl;
//    glEnd();
//    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
//    
//    
//    ofSetColor(255,0,0);
//    ofCircle(p1.x,p1.y, 10);
//    
//    ofSetColor(0,255,0);
//    ofCircle(p2.x,p2.y, 10);
//    ofCircle(p3.x,p3.y, 10);
//    
//    
    
    
}

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
//    MyMesh::ConstVertexIter    vIt(mesh.vertices_begin()), vEnd(mesh.vertices_end());
//    
//    MyMesh::Point * closestPoint;
//    MyMesh::VertexHandle closestVertex;
//    BOOL found = NO;
//    float l = 0;
//    
//    for (; vIt!=vEnd; ++vIt){
//        if(!found || (mesh.point(vIt) - MyMesh::Point(x,y,0)).length() < l){
//            l =  (mesh.point(vIt) -  MyMesh::Point(x,y,0)).length();
//            closestPoint = &mesh.point(vIt);
//            cout<<"New "<<l<<endl;
//            cout<<mesh.point(vIt)[0]<<"  "<<mesh.point(vIt)[1]<<endl;
//            found = YES;
//            closestVertex = vIt;
//            
//            p1 = ofVec2f((*closestPoint)[0],(*closestPoint)[1]);
//        }
//    }
//    

}

@end
