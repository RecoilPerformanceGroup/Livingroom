#import "PolyRenderLights.h"
#import "colorramp.h"
//#import "CGALEnumerator.h"
#import "Tracker.h"

@implementation PolyRenderLights

-(id)init{
    if(self = [super init]){
        [self addPropF:@"zScale"];
        
        //[[self addPropF:@"drawMode"] setMaxValue:2];
        [[self addPropF:@"minLight"] setMidiSmoothing:0.1];;
        
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
        [[self addPropF:@"pointLightIntensity"] setMidiSmoothing:0.8];
        [[self addPropF:@"pointLightTemp"]setMinValue:1000 maxValue:10000];
        
        [[self addPropF:@"triangleLight"]setMinValue:0 maxValue:1];
        [[self addPropF:@"triangleMinLight"]setMinValue:0 maxValue:1];
        [[self addPropF:@"triangleTemp"]setMinValue:0 maxValue:1];

        
        [self addPropF:@"backside"];
        [self addPropF:@"fog"];
        
        [[self addPropF:@"pointLightTracking"] setMaxValue:0.02];
        [[self addPropF:@"pointLightOffsetX"] setMidiSmoothing:0.9];
        [[self addPropF:@"pointLightOffsetY"] setMidiSmoothing:0.9];
        
        [Prop(@"pointLightTemp") setMidiSmoothing:0.7];
        [Prop(@"dirLightTemp") setMidiSmoothing:0.1];
    }
    return self;
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    
}

-(void)update:(NSDictionary *)drawingInformation{
    CachePropF(pointLightTracking);
    if(PropB(@"pointLightTracking")){
        vector<ofVec2f> centroids = [GetPlugin(Tracker) trackerFeetVector];
        ofVec2f p = ofVec2f(PropF(@"pointLightX"), PropF(@"pointLightY"));
        if(centroids.size() > 0){
            ofVec2f t = ofVec2f(centroids[0].x+ PropF(@"pointLightOffsetX"), centroids[0].y+ PropF(@"pointLightOffsetY"));
            p = p * (1-pointLightTracking) + t * pointLightTracking;

            [Prop(@"pointLightX") setFloatValue:p.x];
            [Prop(@"pointLightY") setFloatValue:p.y];
        }        
    }
}

-(void)draw:(NSDictionary *)drawingInformation{
    ofEnableAlphaBlending();
    ofVec3f light1[2];
    light1[0] = ofVec3f(PropF(@"dirLightX"), PropF(@"dirLightY"), PropF(@"dirLightZ")).normalized();
    light1[1] = ofVec3f(PropF(@"dirLight2X"), PropF(@"dirLight2Y"), PropF(@"dirLight2Z")).normalized();
    
    ofVec3f light1Color[3];
    light1Color[0] = colorTemp(PropI(@"dirLightTemp"), PropF(@"dirLightIntensity"));
    light1Color[1] = colorTemp(PropI(@"dirLight2Temp"), PropF(@"dirLight2Intensity"));

    
    ofVec3f light2 = ofVec3f(PropF(@"pointLightX"), PropF(@"pointLightY"), PropF(@"pointLightZ"));
    ofVec3f light2Color = colorTemp(PropI(@"pointLightTemp"), PropF(@"pointLightIntensity"));
    
    ofVec3f triangleLightVec = ofVec3f(PropF(@"dirLightX"), PropF(@"dirLightY"), PropF(@"dirLightZ")).normalized();
    ofVec3f triangleTemp = colorTemp(PropI(@"triangleTemp"), PropF(@"triangleLight"));

    
    if(PropF(@"fog") > 0){
        GLuint filter;                      // Which Filter To Use
        GLuint fogMode[]= { GL_EXP, GL_EXP2, GL_LINEAR };   // Storage For Three Types Of Fog
        GLuint fogfilter= 0;                    // Which Fog To Use
        GLfloat fogColor[4]= {0.0f, 0.0f, 0.0f, 1.0f};      // Fog Color
        
        glFogi(GL_FOG_MODE, fogMode[fogfilter]);        // Fog Mode
        glFogfv(GL_FOG_COLOR, fogColor);            // Set Fog Color
        glFogf(GL_FOG_DENSITY, PropF(@"fog"));              // How Dense Will The Fog Be
        glHint(GL_FOG_HINT, GL_DONT_CARE);          // Fog Hint Value
        glFogf(GL_FOG_START, 0);             // Fog Start Depth
        glFogf(GL_FOG_END, 1);               // Fog End Depth
        glEnable(GL_FOG);                   // Enables GL_FOG
        
        
    }
    
    float zScale = PropF(@"zScale");
    CachePropF(minLight);
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
                
                //Min light
                { 
                    if(color.length() < minLight){
                        color.normalize();
                        color *= minLight;
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
    
    glDisable(GL_FOG);  
    
//    ApplySurface(@"Floor");
//    ofFill();
//    ofSetColor(0,0,0,255);
//    ofRect(-1,-1,1,3);
//    ofRect(1,-1,1,3);
//    
//    ofRect(-1,-1,3,1);
//    ofRect(-1,1,3,1);
//    
//    PopSurface();
/*
    CachePropF(triangleLight);
    CachePropF(triangleMinLight);
    ApplySurface(@"Triangle");{
        Arrangement_2::Face_iterator fit = [[engine arrangement] triangleArrData]->faces_begin();  
        
        for ( ; fit !=[[engine arrangement] triangleArrData]->faces_end(); ++fit) {
            ofVec3f color;
            
            
            ofVec3f n = -calculateFaceNormal(fit);
            
            if(n.length() > 0){
                ofVec3f mid = calculateFaceMid(fit);
                
                //Dir light
                for(int i=0;i<2;i++)
                {
                    float angle = triangleLightVec.angle(n);
                    if(angle < 90 || PropB(@"backside")){
                        //                        ofVec3f l1 = n*light1;
                        //                        color += light1Color*l1.length();
                        color += triangleTemp[i]*fabs(90-angle)/90.0;
                    }
                }
                
                //Min light
                { 
                    if(color.length() < triangleMinLight){
                        color.normalize();
                        color *= triangleMinLight;
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
                                if(p.z == 0){
                                    setHandlePos(p + ofVec3f(0,0,ofRandom(-1,1)), hc->source());
                                }
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
        }
    } PopSurface();*/
    
}

@end
