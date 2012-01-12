#import "PolyRenderSimpleWireframe.h"

//#import "CGALEnumerator.h"

@implementation PolyRenderSimpleWireframe
@synthesize drawFillMode, drawGridMode;

-(id)init{
    if(self = [super init]){
        [self addPropF:@"zScale"];

        [self setDrawFillMode:2];
    }
    return self;
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
    ofFill();
    
    if(drawFillMode >= 1){
        
        
        ofSetColor(0,255,0);
        Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();             
        for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
            ofSetColor(0,0,255);
            //                glEnable(GL_SMOOTH);
            
            
            if(drawFillMode == 1){
                glColor3f(0,0.3,0);
            }
            if(drawFillMode == 2){
                ofVec3f n = -calculateFaceNormal(fit) * PropF(@"zScale");
                // cout<<n.x<<"  "<<n.y<<"  "<<n.z<<endl;
                
                n *= ofVec3f(PropF(@"lightX"), PropF(@"lightY"), PropF(@"lightZ")).normalized();
                
                
                //                    cout<<n.x<<"  "<<n.y<<"  "<<n.z<<endl;
                float l = n.length();
                glColor3f(l,l,l);
            }
            
            glBegin(GL_POLYGON);
            
            
            if(!fit->is_fictitious()){
                if(fit->number_of_outer_ccbs() == 1){
                    Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                    Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                    
                    do { 
                        if(drawFillMode == 3){
                            float z = hc->source()->data().pos.z;
                            float r = z;
                            float b = -z;
                            glColor3f(r,0.2,b);
                        }
                        glVertexHandle(hc->source());
                        //  glVertex2d(CGAL::to_double(hc->source()->point().x()) , CGAL::to_double(hc->source()->point().y()));
                        ++hc; 
                    } while (hc != ccb_start); 
                }            
            }
            
            //        
            glEnd();   
            
        }      
    }
    
    if(drawGridMode > 0){
        ofSetColor(255,0,0);
        
        glPointSize(5);
        glBegin(GL_POINTS);
        
        //        CGALEnumerator * en = [CGALEnumerator vertexFromArr:[[engine arrangement] arrData]];
        
        Arrangement_2::Vertex_iterator vit = [[engine arrangement] arrData]->vertices_begin();    
        for ( ; vit !=[[engine arrangement] arrData]->vertices_end(); ++vit) {
            glVertexHandle(vit);
        }    
        glEnd();  
        
        
        ofSetColor(0,255,0);
        glBegin(GL_LINES);
        Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();    
        
        for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
            glVertexHandle(eit->source());
            glVertexHandle(eit->target());
        }      
        
        glEnd(); 
    }
    
    //TODO: HULLS is sllooowww
    
    /* 
     glPointSize(1);
     
     ofSetColor(255,0,0);
     glPolygonMode(GL_FRONT_AND_BACK , GL_LINE);
     
     vector< Polygon_2> hull = [[engine arrangement] hulls];
     
     for(int i=0;i<hull.size();i++){
     
     glBegin(GL_POLYGON);
     Polygon_2::Vertex_iterator vit = hull[i].vertices_begin();
     for( ; vit != hull[i].vertices_end(); ++vit){
     glVertex2d(CGAL::to_double(vit->x()), CGAL::to_double(vit->y()));
     }
     glEnd();
     }
     */
    
}

-(void)draw:(NSDictionary *)drawingInformation{
    ofEnableAlphaBlending();
        ApplyPerspective();{
            ofSetColor(0,255,0);
            Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();             
            for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
                ofSetColor(0,0,255);
                if(drawFillMode == 1){
                    glColor3f(0,0.3,0);
                }
                if(drawFillMode == 2){
                    glColor3f(255,255,255);
                }
                
                glBegin(GL_POLYGON);
                
                if(!fit->is_fictitious()){
                    if(fit->number_of_outer_ccbs() == 1){
                        Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                        Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                        
                        do { 
                            if(drawFillMode == 3){
                                float z = hc->source()->data().pos.z * PropF(@"zScale");
                                float r = z;
                                float b = -z;
                                glColor3f(r,0.2,b);
                            }
                            ofVec3f p = handleToVec3(hc->source());
                            glVertex3d(p.x , p.y, (p.z)*PropF(@"zScale"));
                           // cout<<p.z<<endl;
//                            cout<<p.x<<"  "<<p.y<<endl;
                            //  glVertex2d(CGAL::to_double(hc->source()->point().x()) , CGAL::to_double(hc->source()->point().y()));
                            ++hc; 
                        } while (hc != ccb_start); 
                    }            
                }
                
                //        
                glEnd();   
            } 

        } PopPerspective();
}

@end
