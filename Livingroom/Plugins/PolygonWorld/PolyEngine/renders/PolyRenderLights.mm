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
    ApplyPerspective();{
        ofSetColor(0,255,0);
        Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();             
        for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
            ofSetColor(0,0,255);
            ofVec3f n = -calculateFaceNormal(fit);
            n *= ofVec3f(PropF(@"lightX"), PropF(@"lightY"), PropF(@"lightZ")).normalized();
            float l = n.length();
            glColor3f(l,l,l);
            
            glBegin(GL_POLYGON);
            
            if(!fit->is_fictitious()){
                if(fit->number_of_outer_ccbs() == 1){
                    Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                    Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                    
                    do { 
                        ofVec3f n = -calculateFaceNormal(fit);
                        n *= ofVec3f(PropF(@"lightX"), PropF(@"lightY"), PropF(@"lightZ")).normalized();
                        
                        float l = n.length();
                        glColor3f(l,l,l);
                        
                        
                        
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
