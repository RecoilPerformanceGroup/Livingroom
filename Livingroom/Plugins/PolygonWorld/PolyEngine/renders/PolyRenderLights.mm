#import "PolyRenderLights.h"

//#import "CGALEnumerator.h"

@implementation PolyRenderLights

-(id)init{
    if(self = [super init]){
        [self addPropF:@"zScale"];
        
        //[[self addPropF:@"drawMode"] setMaxValue:2];
        
        [self addPropF:@"lightX"];
        [self addPropF:@"lightY"];
        [self addPropF:@"lightZ"];
        
    }
    return self;
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    
}

-(void)draw:(NSDictionary *)drawingInformation{
    ofEnableAlphaBlending();
    ofVec3f light1 = ofVec3f(PropF(@"lightX"), PropF(@"lightY"), PropF(@"lightZ")).normalized();
    float zScale = PropF(@"zScale");
    ApplyPerspective();{
        ofSetColor(0,255,0);
        //Depth test
        glEnable(GL_DEPTH_TEST);
        glClearDepth(1.0);
        
        Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();  
        
        glBegin(GL_TRIANGLES);
        for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
            ofSetColor(0,0,255);
            ofVec3f n = -calculateFaceNormal(fit);
            n *= light1;
            float l = n.length();
            glColor3f(l,l,l);
            

            
            if(!fit->is_fictitious()){
                if(fit->number_of_outer_ccbs() == 1){
                    Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                    Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                    
                    do { 
                        ofVec3f p = handleToVec3(hc->source());                        
                        glVertex3d(p.x , p.y, (p.z)*zScale);
                        // cout<<p.z<<endl;
                        //                            cout<<p.x<<"  "<<p.y<<endl;
                        //  glVertex2d(CGAL::to_double(hc->source()->point().x()) , CGAL::to_double(hc->source()->point().y()));
                        ++hc; 
                    } while (hc != ccb_start); 
                }            
            }
            
            //        
            

        } 
        glEnd();  
        glDisable(GL_DEPTH_TEST);

    } PopPerspective();
}

@end
