#import "PolygonWorld.h"

using namespace OpenMesh;

@implementation PolygonWorld

- (id)init{
    self = [super init];
    if (self) {
        
        // generate vertices
        
        
        vhandle[0] = mesh.add_vertex(MyMesh::Point(10, 10,  0));
        vhandle[1] = mesh.add_vertex(MyMesh::Point(100, 30,  0));
        vhandle[2] = mesh.add_vertex(MyMesh::Point( 150,  100,  0));
        vhandle[3] = mesh.add_vertex(MyMesh::Point(50,  150,  0));
        
        verticeIt = 3;
        
        
        // generate (quadrilateral) faces
        
        std::vector<MyMesh::VertexHandle>  face_vhandles;
        
        face_vhandles.clear();
        face_vhandles.push_back(vhandle[0]);
        face_vhandles.push_back(vhandle[1]);
        face_vhandles.push_back(vhandle[2]);
        face_vhandles.push_back(vhandle[3]);
        
        face = mesh.add_face(face_vhandles);
        
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
    ofBackground(0);
    
    
    
    
    MyMesh::ConstFaceIter    fIt(mesh.faces_begin()), fEnd(mesh.faces_end());
    
    
    MyMesh::ConstFaceVertexIter fvIt;
    
    ofEnableAlphaBlending();
    
    
    
    ofSetColor(255, 255, 255);
    
    
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glBegin(GL_TRIANGLES);
    for (; fIt!=fEnd; ++fIt)
    {
        fvIt = mesh.cfv_iter(fIt.handle()); 
        glVertex3fv( &mesh.point(fvIt)[0] );
        //    cout<<mesh.point(fvIt)[0]<<"  "<<mesh.point(fvIt)[1]<<endl;
        ++fvIt;
        glVertex3fv( &mesh.point(fvIt)[0] );
        //     cout<<mesh.point(fvIt)[0]<<"  "<<mesh.point(fvIt)[1]<<endl;
        ++fvIt;
        glVertex3fv( &mesh.point(fvIt)[0] );
        //  cout<<mesh.point(fvIt)[0]<<"  "<<mesh.point(fvIt)[1]<<endl;
        //    cout<<" ---- "<<endl;
    }
    // cout<<"-- end --"<<endl;
    glEnd();
    
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    
    
    ofSetColor(255,0,0);
    ofCircle(p1.x,p1.y, 10);
    
    ofSetColor(0,255,0);
    ofCircle(p2.x,p2.y, 10);
    ofCircle(p3.x,p3.y, 10);
    
    
    
    
}

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    MyMesh::ConstVertexIter    vIt(mesh.vertices_begin()), vEnd(mesh.vertices_end());
    
    MyMesh::Point * closestPoint;
    MyMesh::VertexHandle closestVertex;
    BOOL found = NO;
    float l = 0;
    
    for (; vIt!=vEnd; ++vIt){
        if(!found || (mesh.point(vIt) - MyMesh::Point(x,y,0)).length() < l){
            l =  (mesh.point(vIt) -  MyMesh::Point(x,y,0)).length();
            closestPoint = &mesh.point(vIt);
            cout<<"New "<<l<<endl;
            cout<<mesh.point(vIt)[0]<<"  "<<mesh.point(vIt)[1]<<endl;
            found = YES;
            closestVertex = vIt;
            
            p1 = ofVec2f((*closestPoint)[0],(*closestPoint)[1]);
        }
    }
    
    /*
     
     //Edge split
     if(found){
     
     MyMesh::HalfedgeHandle heh, heh2, heh_init, hehL, hehR;
     heh = heh2 = heh_init = mesh.halfedge_handle(closestVertex);
     
     
     MyMesh::EdgeHandle edge= mesh.edge_handle(heh);
     
     mesh.split(edge, MyMesh::Point(x,y,0));
     
     }
     
     */
    
    
    /*
     //Vertex Split
     if(found){
     
     // Get some vertex handle
     MyMesh::HalfedgeHandle heh, heh2, heh_init, hehL, hehR;
     heh = heh2 = heh_init = mesh.halfedge_handle(closestVertex);
     
     hehL = heh_init;//mesh.next_halfedge_handle(heh);
     hehR = mesh.prev_halfedge_handle(mesh.prev_halfedge_handle(heh2));
     
     cout<<mesh.is_boundary(heh_init)<<endl;
     
     MyMesh::VertexHandle vl = mesh.to_vertex_handle(hehL);
     MyMesh::VertexHandle vr = mesh.to_vertex_handle(hehR);
     
     p2 = ofVec2f(mesh.point(vl)[0],mesh.point(vl)[1]);
     p3 = ofVec2f(mesh.point(vr)[0],mesh.point(vr)[1]);
     
     mesh.vertex_split(MyMesh::Point(x,y,0), closestVertex, vl, vr);
     }*/
    
    //Face add
    if(found){
        // Get some vertex handle
        MyMesh::HalfedgeHandle heh, heh2, heh_init, hehL, hehR;
        heh = heh2 = heh_init = mesh.halfedge_handle(closestVertex);
        
        hehL = heh_init;//mesh.next_halfedge_handle(heh);
        hehR = mesh.prev_halfedge_handle(mesh.prev_halfedge_handle(heh2));
        
        MyMesh::VertexHandle vl = mesh.to_vertex_handle(hehL);
        MyMesh::VertexHandle vr = mesh.to_vertex_handle(hehR);
        
        p2 = ofVec2f(mesh.point(vl)[0],mesh.point(vl)[1]);
        p3 = ofVec2f(mesh.point(vr)[0],mesh.point(vr)[1]);
        
        MyMesh::VertexHandle newV = mesh.add_vertex(MyMesh::Point( x,  y,  0));
        
        if((ofVec2f(x,y)-p2).length() > (ofVec2f(x,y)-p3).length()){
            
            std::vector<MyMesh::VertexHandle>  face_vhandles;        
            face_vhandles.clear();
            face_vhandles.push_back(vr);
            face_vhandles.push_back(closestVertex);
            face_vhandles.push_back(newV);        
            face = mesh.add_face(face_vhandles);
        } else {    
            std::vector<MyMesh::VertexHandle>  face_vhandles;        
            face_vhandles.clear();
            face_vhandles.push_back(closestVertex);
            face_vhandles.push_back(vl);
            face_vhandles.push_back(newV);        
            face = mesh.add_face(face_vhandles);
        }
        
        mesh.triangulate();
    }
    
    
    
    /*    
     vhandle[++verticeIt] = mesh.add_vertex(MyMesh::Point(x, y,  0));
     
     
     std::vector<MyMesh::VertexHandle>  face_vhandles;
     
     face_vhandles.clear();
     for(int i=0 ; i<=verticeIt ; i++){
     face_vhandles.push_back(vhandle[i]);
     }
     face.reset();
     //mesh.clear();
     face = mesh.add_face(face_vhandles);*/
    
}

@end
