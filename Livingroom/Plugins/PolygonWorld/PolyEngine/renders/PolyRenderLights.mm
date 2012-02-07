#import "PolyRenderLights.h"
#import "colorramp.h"
//#import "CGALEnumerator.h"

@implementation PolyRenderLights

-(id)init{
    if(self = [super init]){
        [self addPropF:@"zScale"];
        
        //[[self addPropF:@"drawMode"] setMaxValue:2];
        
        [[self addPropF:@"dirLightX"] setMidiSmoothing:0.1];;
        [[self addPropF:@"dirLightY"] setMidiSmoothing:0.1];;
        [[self addPropF:@"dirLightZ"] setMidiSmoothing:0.1];;
        [[self addPropF:@"dirLightTemp"] setMinValue:1000 maxValue:10000];
        [[self addPropF:@"dirLightIntensity"] setMidiSmoothing:0.9];
        
        [[self addPropF:@"dirLight2X"] setMidiSmoothing:0.1];;
        [[self addPropF:@"dirLight2Y"] setMidiSmoothing:0.1];;
        [[self addPropF:@"dirLight2Z"] setMidiSmoothing:0.1];;
        [[self addPropF:@"dirLight2Temp"] setMinValue:1000 maxValue:10000];
        [[self addPropF:@"dirLight2Intensity"] setMidiSmoothing:0.9];
        
        [self addPropF:@"pointLightX"];
        [self addPropF:@"pointLightY"];
        [self addPropF:@"pointLightZ"];
        [[self addPropF:@"pointLightIntensity"] setMidiSmoothing:0.9];
        [[self addPropF:@"pointLightTemp"]setMinValue:1000 maxValue:10000];
       
        [self addPropF:@"backside"];

        [Prop(@"pointLightTemp") setMidiSmoothing:0.1];
        [Prop(@"dirLightTemp") setMidiSmoothing:0.1];
    }
    return self;
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    
}

-(void)draw:(NSDictionary *)drawingInformation{
    ofEnableAlphaBlending();
    ofVec3f light1[2];
    light1[0] = ofVec3f(PropF(@"dirLightX"), PropF(@"dirLightY"), PropF(@"dirLightZ")).normalized();
    light1[1] = ofVec3f(PropF(@"dirLight2X"), PropF(@"dirLight2Y"), PropF(@"dirLight2Z")).normalized();

    ofVec3f light1Color[2];
    light1Color[0] = colorTemp(PropI(@"dirLightTemp"), PropF(@"dirLightIntensity"));
    light1Color[1] = colorTemp(PropI(@"dirLight2Temp"), PropF(@"dirLight2Intensity"));
    
    
    
    ofVec3f light2 = ofVec3f(PropF(@"pointLightX"), PropF(@"pointLightY"), PropF(@"pointLightZ"));
    ofVec3f light2Color = colorTemp(PropI(@"pointLightTemp"), PropF(@"pointLightIntensity"));
    
    
    float zScale = PropF(@"zScale");
    ApplyPerspective();{
        ofSetColor(0,255,0);
        //Depth test
        glEnable(GL_DEPTH_TEST);
        glClearDepth(1.0);
        
        Arrangement_2::Face_iterator fit = [[engine arrangement] arrData]->faces_begin();  
        
        for ( ; fit !=[[engine arrangement] arrData]->faces_end(); ++fit) {
            ofVec3f color;
            
            
            ofVec3f n = -calculateFaceNormal(fit);
            
            if(n.length() > 0){
                ofVec3f mid = calculateFaceMid(fit);
                
                //Dir light
                for(int i=0;i<2;i++)
                {
                    float angle = light1[i].angle(n);
                    if(angle < 90 || PropB(@"backside")){
//                        ofVec3f l1 = n*light1;
//                        color += light1Color*l1.length();
                        color += light1Color[i]*fabs(90-angle)/90.0;
                    }
                }
                
                //Point light
                {
                    ofVec3f light2Dir = (mid-light2);
                    float angle = light2Dir.angle(n);
                    if(angle < 90 || PropB(@"backside")){
                        
                        float dist = light2Dir.length();
//                        light2Dir /= dist;
                        
                        float intensity = 1.0/(4*PI*dist*dist);
                        color += intensity*light2Color*fabs(90-angle)/90.0;
                      
//                        color += intensity*light2Color*(n*light2Dir).length();
                    }
                }
                glColor4f(color.x,color.y,color.z,1);

                if(!fit->data().hole){
                
                
                
                if(!fit->is_fictitious()){
                    if(fit->number_of_outer_ccbs() == 1){
                        glBegin(GL_POLYGON);

                        Arrangement_2::Ccb_halfedge_circulator ccb_start = fit->outer_ccb();
                        Arrangement_2::Ccb_halfedge_circulator hc = ccb_start; 
                        
                        do { 
                    //        ofVec2f v2 = point2ToVec2(hc->source()->point());

                            ofVec3f p = handleToVec3(hc->source());                        
                            glVertex3d(p.x , p.y, (p.z)*zScale);
                            // cout<<p.z<<endl;
                            //                            cout<<p.x<<"  "<<p.y<<endl;
                            //  glVertex2d(CGAL::to_double(hc->source()->point().x()) , CGAL::to_double(hc->source()->point().y()));
                            ++hc; 
                        } while (hc != ccb_start); 
                        glEnd();  

                    }            
                }
                }
                
            }
            
            //        
            
            
        } 
        glDisable(GL_DEPTH_TEST);
        
    } PopPerspective();
}

@end
