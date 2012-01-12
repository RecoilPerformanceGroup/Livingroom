#import "Perspective.h"
#import <ofxCocoaPlugins/Keystoner.h>
#import <ofxCocoaPlugins/KeystoneSurface.h>

@implementation Perspective

- (id)init{
    self = [super init];
    if (self) {
        
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:0.01 maxValue:1.0] named:@"scale"];	
        
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-3.0 maxValue:4.0] named:@"view point x"];	
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-3.0 maxValue:4.0] named:@"view point y"];	
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-3.0 maxValue:0] named:@"view point z"];	
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:0 maxValue:2] named:@"perspective scale"];
        [self addProperty:[BoolProperty boolPropertyWithDefaultvalue:NO] named:@"show depth map"];
        
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.5 minValue:0.0 maxValue:1.0] named:@"Light X"];	
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:2 minValue:0.0 maxValue:2.0] named:@"Light Y"];
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:-1 minValue:-100.0 maxValue:0] named:@"Light Z"];  
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-20.0 maxValue:20.0] named:@"light foreshortening"];
        
        [self addProperty:[BoolProperty boolPropertyWithDefaultvalue:NO] named:@"debug"];
        
        zoom = 0.5;
        offset = ofVec2f(0,0);
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
    
    //load the squirrel model - the 3ds and the texture file need to be in the same folder
    squirrelModel.loadModel("squirrel/NewSquirrel.3ds", 0.1);
    
    //you can create as many rotations as you want
    //choose which axis you want it to effect
    //you can update these rotations later on
    squirrelModel.setRotation(0, 270, 1, 0, 0);
    squirrelModel.setRotation(1, 180, 0, 1, 0);
    squirrelModel.setScale(0.5, 0.5, 0.5);
    squirrelModel.setPosition(0.5, 0.75, -0.25);
    
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    
    light1_x = PropF(@"Light X");
    light1_y = PropF(@"Light Y");
    light1_z = (light1_z * 0.95) + (PropF(@"Light Z")* 0.05);
    
    KeystonePerspective * persp = (KeystonePerspective *)Perspective(@"Floor");
    
    [persp setViewPoint:
     ofVec3f(PropF(@"view point x"),
             PropF(@"view point y"),
             PropF(@"view point z"))
     ];
    
    [persp setScale:PropF(@"perspective scale")];
    
    squirrelModel.setScale(PropF(@"scale"), PropF(@"scale"), PropF(@"scale"));
    
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    if(PropB(@"debug")){
        ofEnableAlphaBlending();
        
        ofFill();
        
        ofSetColor(255, 255, 255,255);
        
        ApplySurfaceForProjector(@"Floor",0); {
            
            float aspect = Aspect(@"Floor", 0);
            
            glTranslated(0, 0, 0.01);
            ofRect(0,0,1*aspect,1);
            
        } PopSurfaceForProjector();
        
        glClearColor (0.0, 0.0, 0.0, 0.0);
        
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        
        GLfloat mat_specular[] = { 1.0, 1.0, 1.0, 1.0 };
        GLfloat mat_shininess[] = { 50.0 };
        
        /* lighting stuff */
        glShadeModel (GL_SMOOTH);
        
        /* specular highlights have color 'mat_specular'*/
        glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
        
        /* shininess ('N') = mat_shininess*/
        glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
        
        glEnable(GL_LIGHTING);  /* enable lighting */
        glEnable(GL_LIGHT0);    /* enable light0 */
        
        int window_width = ofGetWindowWidth();
        int window_height = ofGetWindowHeight();
        
        /* normalize all normal vectors for lighting and shading */
        
        glEnable(GL_NORMALIZE);
        
        
        [self drawScene:drawingInformation orShadows:NO];
        //  [self drawScene:drawingInformation orShadows:YES];
        
        //    ofBox(0.5, 0.2, -sin(ofGetElapsedTimef())+0.2, 0.2);
        
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_LIGHTING);
        
        if(PropB(@"show depth map")){
            
            char * buffer = new char[window_width*window_height];
            glReadPixels(0,0,window_width,window_height, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, buffer);
            glDrawPixels(window_width,window_height, GL_LUMINANCE, GL_UNSIGNED_BYTE, buffer);
            
            delete buffer;
            
        }  
    }
    
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
    float aspect = Aspect(@"Floor", 0);
    
    controlWidth = ofGetWidth();
    controlHeight = ofGetHeight();
    
    glPushMatrix();{
        glScaled(controlWidth, controlHeight,1.0);
        
        glTranslated(0.5,0, 0);
        glScaled(zoom,zoom,1);
        glTranslated(-aspect*0.5,0,0);
        glTranslated(offset.x, offset.y,0);
        
        ofFill();
        ofSetColor(100,100,100);
        ofRect(0,0,aspect, 1);
        
        ofSetColor(30,30,30);
        ofCircle(PropF(@"view point x"), PropF(@"view point y"), 0.07);
        
    } glPopMatrix();
    
}

-(void)drawScene: (NSDictionary *)drawingInformation orShadows:(BOOL) doShadows{
    
    
    GLfloat mat_white[] = {1.0, 1.0, 1.0, 0.0};
    GLfloat mat_black[] = {0.0, 0.0, 0.0, 0.0};
    
    ApplySurfaceForProjector(@"Floor",0); {
        
        ApplyPerspective(); {
            
            float aspect = Aspect(@"Floor", 0);
            
            /* light placed at infinity in the direcion <10,10,10>*/
            GLfloat light_position[] = {light1_x, light1_y, -light1_z, 0.0}; 
            glLightfv(GL_LIGHT0, GL_POSITION, light_position); 
            
            
            if (doShadows) {
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_black);
                glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_black);
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, mat_black);
            } else {
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, mat_white);
            }
            
            squirrelModel.setPosition(0.25*aspect, 0.5, -((PropF(@"scale")*0.5)*(1.5+sin((0.33+ofGetElapsedTimef())*4)*0.5)));
            squirrelModel.draw();
            
            squirrelModel.setPosition(0.5*aspect, 0.75, -((PropF(@"scale")*0.5)*(1.5+sin(ofGetElapsedTimef()*4)*0.5)));
            squirrelModel.draw();
            
            squirrelModel.setPosition(0.75*aspect, 0.5, -((PropF(@"scale")*0.5)*(1.5+sin((0.66+ofGetElapsedTimef())*4)*0.5)));
            squirrelModel.draw();
            
            if (doShadows) {
                glPopMatrix();
            }
            
            glDisable(GL_DEPTH_TEST);
            glDisable(GL_LIGHTING);
            
            ofSetLineWidth(4);
            ofNoFill();
            
            ofSetColor(255, 0, 0,127);
            
            for (float i=0; i<=aspect; i+=0.1) {
                for (float j=0; j<=1.0; j+=0.1) {
                    ofLine(i,j,0.0,
                           i,j,-.1);
                    
                    if (fmodf(i, 0.2) < 0.05 && fmodf(j, 0.2) < 0.05) {
                        
                        ofLine(i,j,0.0,
                               i,j+.1,0.0);
                        ofLine(i,j,0.0,
                               i+.1,j,0.0);
                        
                        ofLine(i,j,-.1,
                               i,j+.1,-.1);
                        ofLine(i,j,-.1,
                               i+.1,j,-.1);
                        
                        ofLine(i+.1,j,0.0,
                               i+.1,j+.1,0.0);
                        ofLine(i,j+.1,0.0,
                               i+.1,j+.1,0.0);
                        
                        
                        ofLine(i+.1,j,-.1,
                               i+.1,j+.1,-.1);
                        ofLine(i,j+.1,-.1,
                               i+.1,j+.1,-.1);
                        
                    }
                    
                }        
            }
            
            ofSetColor(0, 127, 0,127);
            ofLine(0.25,0.5,0.0,
                   0.25,0.5,-1.0);
            ofLine(0.5,0.75,0.0,
                   0.5,0.75,-1.0);
            ofLine(0.75,0.5,0.0,
                   0.75,0.5,-1.0);
            
            
        } PopPerspective();
        
    } PopSurfaceForProjector();
    
}
@end
