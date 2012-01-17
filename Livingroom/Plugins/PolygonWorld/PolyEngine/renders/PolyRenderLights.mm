#import "PolyRenderLights.h"
#import "colorramp.h"
//#import "CGALEnumerator.h"

@implementation PolyRenderLights

-(id)init{
    if(self = [super init]){
        [self addPropF:@"zScale"];
        
        //[[self addPropF:@"drawMode"] setMaxValue:2];
        
        [self addPropF:@"dirLightX"];
        [self addPropF:@"dirLightY"];
        [self addPropF:@"dirLightZ"];
        [[self addPropF:@"dirLightTemp"] setMinValue:1000 maxValue:10000];
        [self addPropF:@"dirLightIntensity"];
        
        [self addPropF:@"pointLightX"];
        [self addPropF:@"pointLightY"];
        [self addPropF:@"pointLightZ"];
        [self addPropF:@"pointLightIntensity"];
        [[self addPropF:@"pointLightTemp"]setMinValue:1000 maxValue:10000];
    }
    return self;
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    
}

-(void)draw:(NSDictionary *)drawingInformation{
    ofEnableAlphaBlending();
    ofVec3f light1 = ofVec3f(PropF(@"dirLightX"), PropF(@"dirLightY"), PropF(@"dirLightZ")).normalized();
    ofVec3f light1Color = colorTemp(PropI(@"dirLightTemp"), PropF(@"dirLightIntensity"));
    
    ofVec3f light2 = ofVec3f(PropF(@"pointLightX"), PropF(@"pointLightY"), PropF(@"pointLightZ"));
    ofVec3f light2Color = colorTemp(PropI(@"pointLightTemp"), PropF(@"pointLightIntensity"));
    
    
    float zScale = PropF(@"zScale");
    ApplyPerspective();{
        ofSetColor(0,255,0);
        //Depth test
        glEnable(GL_DEPTH_TEST);
        glClearDepth(1.0);
        
        Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();  
        
        glBegin(GL_TRIANGLES);
        for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
            ofVec3f color;
            
            
            ofVec3f n = -calculateFaceNormal(fit);
            
            if(n.length() > 0){
                ofVec3f mid = calculateFaceMid(fit);
                
                //Dir light
                {
                    float angle = light1.angle(n);
                    if(angle < 90){
//                        ofVec3f l1 = n*light1;
//                        color += light1Color*l1.length();
                        color += light1Color*(90-angle)/90.0;
                    }
                }
                
                //Point light
                {
                    ofVec3f light2Dir = (mid-light2);
                    float angle = light2Dir.angle(n);
                    if(angle < 90){
                        
                        float dist = light2Dir.length();
//                        light2Dir /= dist;
                        
                        float intensity = 1.0/(4*PI*dist*dist);
                        color += intensity*light2Color*(90-angle)/90.0;
                      
//                        color += intensity*light2Color*(n*light2Dir).length();
                    }
                }
                
                glColor3f(color.x,color.y,color.z);
                
                
                
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
                
            }
            
            //        
            
            
        } 
        glEnd();  
        glDisable(GL_DEPTH_TEST);
        
    } PopPerspective();
}

@end
