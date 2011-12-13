#import "Perspective.h"
#import <ofxCocoaPlugins/Keystoner.h>
#import <ofxCocoaPlugins/KeystoneSurface.h>

@implementation Perspective

- (id)init{
    self = [super init];
    if (self) {
        
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:0.01 maxValue:1.0] named:@"scale"];	
        
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-5.0 maxValue:5.0] named:@"x-shear"];	
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-5.0 maxValue:5.0] named:@"y-shear"];	
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-4.0 maxValue:4.0] named:@"perspective foreshortening"];
        [self addProperty:[BoolProperty boolPropertyWithDefaultvalue:NO] named:@"show depth map"];

        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-1.0 maxValue:1] named:@"Light X"];	
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-1.0 maxValue:1] named:@"Light Y"];
        [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0 minValue:-1.0 maxValue:1] named:@"Light Z"];        
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
    
    
    glDepthFunc(GL_LEQUAL);

    
    /* ambient light in direction (10, 10, 10) */
    light1_x = 0.5;
    light1_y = -1.0;
    light1_z = 1.0;
    
    /* the shadow matrix */
    m[0]= 1; m[4]= 0; m[8] = -(light1_x/light1_z); m[12]= 0;
    m[1]= 0; m[5]= 1; m[9] = -(light1_y/light1_z); m[13]= 0;
    m[2]= 0; m[6]= 0; m[10]= 0;                    m[14]= 0;
    m[3]= 0; m[7]= 0; m[11]= 0;                    m[15]= 1;
    
    mat_specular = new float{ 1.0, 1.0, 1.0, 1.0 };
    mat_shininess = new float{ 50.0 };
        
    glEnable(GL_NORMALIZE);

    
    /* lighting stuff */
    glShadeModel (GL_SMOOTH);
    
    /* specular highlights have color 'mat_specular'*/
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
    
    /* shininess ('N') = mat_shininess*/
    glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
    
    glEnable(GL_LIGHTING);  /* enable lighting */
    glEnable(GL_LIGHT0);    /* enable light0 */
    
    /* normalize all normal vectors for lighting and shading */
	glEnable(GL_NORMALIZE);
    
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
    light1_z = PropF(@"Light Z");

    
    squirrelModel.setScale(PropF(@"scale"), PropF(@"scale"), PropF(@"scale"));
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    
    int window_width = ofGetWindowWidth();
    int window_height = ofGetWindowHeight();
    
    ofFill();

    ofSetColor(255, 255, 255,255);
    
    [self drawScene:drawingInformation orShadows:NO];
   [self drawScene:drawingInformation orShadows:YES];

    //    ofBox(0.5, 0.2, -sin(ofGetElapsedTimef())+0.2, 0.2);
    
    
    glDisable (GL_DEPTH_TEST);
    
    /** try to draw axis
     glPushMatrix();{
     
     
     
     ofVec2f center = ofVec2f(0,0); // [mySurface convertToProjection:ofVec2f(0,0)];
     
     ofVec3f xMat = ofVec3f( 
     [mySurface warp]->cv_translate_3x3->data.fl[0],
     [mySurface warp]->cv_translate_3x3->data.fl[1],
     [mySurface warp]->cv_translate_3x3->data.fl[2]
     );
     
     ofVec3f yMat = ofVec3f( 
     [mySurface warp]->cv_translate_3x3->data.fl[3],
     [mySurface warp]->cv_translate_3x3->data.fl[4],
     [mySurface warp]->cv_translate_3x3->data.fl[5]
     );
     
     ofVec3f crossMat = xMat.cross(yMat);
     
     
     
     ofVec2f translationCenter = [mySurface convertToProjection:ofVec2f(0,0)];
     
     glTranslated(translationCenter.x,translationCenter.y, 0);
     
     ofSetColor(255, 0, 0);
     ofLine(center.x, center.y, 0, 
     [mySurface warp]->cv_translate_3x3->data.fl[0], [mySurface warp]->cv_translate_3x3->data.fl[1], [mySurface warp]->cv_translate_3x3->data.fl[2]);
     ofSetColor(0, 255, 0);
     ofLine(center.x, center.y, 0, 
     [mySurface warp]->cv_translate_3x3->data.fl[3], [mySurface warp]->cv_translate_3x3->data.fl[4], [mySurface warp]->cv_translate_3x3->data.fl[5]);
     ofSetColor(0, 0, 255);
     ofLine(center.x, center.y, 0, 
     [mySurface warp]->cv_translate_3x3->data.fl[6], [mySurface warp]->cv_translate_3x3->data.fl[7], [mySurface warp]->cv_translate_3x3->data.fl[8]);
     
     
     
     } glPopMatrix();
     
     
     //**/
    
    /**
     glPushMatrix();{
     
     // Transform the camera's intrinsic parameters into an OpenGL camera matrix
     glMatrixMode(GL_PROJECTION);
     glLoadIdentity();
     
     // Camera parameters
     double f_x = 786.42938232; // Focal length in x axis
     double f_y = 786.42938232; // Focal length in y axis (usually the same?)
     double c_x = 217.01358032; // Camera primary point x
     double c_y = 311.25384521; // Camera primary point y
     
     double screen_width = window_width; // In pixels
     double screen_height = window_height; // In pixels
     
     double fovY = 1/(f_x/screen_height * 2);
     double aspectRatio = screen_width/screen_height * f_y/f_x;
     double near = .1;  // Near clipping distance
     double far = 1000;  // Far clipping distance
     double frustum_height = near * fovY;
     double frustum_width = frustum_height * aspectRatio;
     
     double offset_x = (screen_width/2 - c_x)/screen_width * frustum_width * 2;
     double offset_y = (screen_height/2 - c_y)/screen_height * frustum_height * 2;
     
     // Build and apply the projection matrix
     glFrustumf(-frustum_width - offset_x, frustum_width - offset_x, -frustum_height - offset_y, frustum_height - offset_y, near, far);
     
     
     // Decompose the Homography into translation and rotation vectors
     // Based on: https://gist.github.com/740979/97f54a63eb5f61f8f2eb578d60eb44839556ff3f
     
     Mat inverseCameraMatrix = (Mat_(3,3) << 1/cameraMatrix.at(0,0) , 0 , -cameraMatrix.at(0,2)/cameraMatrix.at(0,0) ,
     0 , 1/cameraMatrix.at(1,1) , -cameraMatrix.at(1,2)/cameraMatrix.at(1,1) ,
     0 , 0 , 1);
     // Column vectors of homography
     Mat h1 = (Mat_(3,1) << H_matrix.at(0,0) , H_matrix.at(1,0) , H_matrix.at(2,0));
     Mat h2 = (Mat_(3,1) << H_matrix.at(0,1) , H_matrix.at(1,1) , H_matrix.at(2,1));
     Mat h3 = (Mat_(3,1) << H_matrix.at(0,2) , H_matrix.at(1,2) , H_matrix.at(2,2));
     
     Mat inverseH1 = inverseCameraMatrix * h1;
     // Calculate a length, for normalizing
     double lambda = sqrt(h1.at(0,0)*h1.at(0,0) +
     h1.at(1,0)*h1.at(1,0) +
     h1.at(2,0)*h1.at(2,0));
     
     
     Mat rotationMatrix; 
     
     if(lambda != 0) {
     lambda = 1/lambda;
     // Normalize inverseCameraMatrix
     inverseCameraMatrix.at(0,0) *= lambda;
     inverseCameraMatrix.at(1,0) *= lambda;
     inverseCameraMatrix.at(2,0) *= lambda;
     inverseCameraMatrix.at(0,1) *= lambda;
     inverseCameraMatrix.at(1,1) *= lambda;
     inverseCameraMatrix.at(2,1) *= lambda;
     inverseCameraMatrix.at(0,2) *= lambda;
     inverseCameraMatrix.at(1,2) *= lambda;
     inverseCameraMatrix.at(2,2) *= lambda;
     
     // Column vectors of rotation matrix
     Mat r1 = inverseCameraMatrix * h1;
     Mat r2 = inverseCameraMatrix * h2;
     Mat r3 = r1.cross(r2);    // Orthogonal to r1 and r2
     
     // Put rotation columns into rotation matrix... with some unexplained sign changes
     rotationMatrix = (Mat_(3,3) <<  r1.at(0,0) , -r2.at(0,0) , -r3.at(0,0) ,
     -r1.at(1,0) , r2.at(1,0) , r3.at(1,0) ,
     -r1.at(2,0) , r2.at(2,0) , r3.at(2,0));
     
     // Translation vector T
     translationVector = inverseCameraMatrix * h3;
     translationVector.at(0,0) *= 1;
     translationVector.at(1,0) *= -1;
     translationVector.at(2,0) *= -1;
     
     SVD decomposed(rotationMatrix); // I don't really know what this does. But it works.
     rotationMatrix = decomposed.u * decomposed.vt;
     
     }
     else {
     printf("Lambda was 0...\n");
     }
     
     modelviewMatrix = (Mat_(4,4) << rotationMatrix.at(0,0), rotationMatrix.at(0,1), rotationMatrix.at(0,2), translationVector.at(0,0),
     rotationMatrix.at(1,0), rotationMatrix.at(1,1), rotationMatrix.at(1,2), translationVector.at(1,0),
     rotationMatrix.at(2,0), rotationMatrix.at(2,1), rotationMatrix.at(2,2), translationVector.at(2,0),
     0,0,0,1);
     
     
     } glPopMatrix();
     //**/   
    
    
    
    glDisable (GL_DEPTH_TEST);
    
    if(PropB(@"show depth map")){
        
        char * buffer = new char[window_width*window_height];
        glReadPixels(0,0,window_width,window_height, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, buffer);
        glDrawPixels(window_width,window_height, GL_LUMINANCE, GL_UNSIGNED_BYTE, buffer);
        
        delete buffer;
        
    }  
    
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
    
    
}

-(void)drawScene: (NSDictionary *)drawingInformation orShadows:(BOOL) shadows{

    KeystoneSurface * mySurface = (KeystoneSurface*)Surface(@"Floor",0);
    
    float * glMatrix = [mySurface warp]->gl_matrix_4x4;
    
    float * multMatrix = new float[16];
    
    multMatrix[0]  = 1.0f;
    multMatrix[1]  = 0.0f;
    multMatrix[2]  = 0.0f;
    multMatrix[3]  = 0.0f;
    multMatrix[4]  = 0.0f;
    multMatrix[5]  = 1.0f;
    multMatrix[6]  = 0.0f;
    multMatrix[7]  = 0.0f;
    multMatrix[8]  = PropF(@"x-shear"); // z-axis x shear
    multMatrix[9]  = PropF(@"y-shear");; // z-axis y shear
    multMatrix[10] = 1.0f;
    multMatrix[11] = PropF(@"perspective foreshortening");; // perspective foreshortening
    multMatrix[12] = 0.0f;
    multMatrix[13] = 0.0f;
    multMatrix[14] = 0.0f;
    multMatrix[15] = 1.0f;
    
    GLfloat mat_white[] = {1.0, 1.0, 1.0, 0.0};
    GLfloat mat_black[] = {0.0, 0.0, 0.0, 0.0};
    
    /* specular highlights have color 'mat_specular'*/
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
    
    /* shininess ('N') = mat_shininess*/
    glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);


    ApplySurfaceForProjector(@"Floor",0); {
        

        /* light placed at infinity in the direcion <10,10,10>*/
        GLfloat light_position[] = {light1_x, light1_y, light1_z, 0.0}; 
        glLightfv(GL_LIGHT0, GL_POSITION, light_position); 
        
        glPushMatrix();{


            glMultMatrixf(multMatrix);

            /* this will be your shadow matrix.  You need to specify what this contains.
             * OpenGL has a funky ordering for rows and columns
             * use this ordering for rows and columns.  The identity matrix with Mr,c = M3,3 = 0;
             */
            m[0]= 1; m[4]= 0; m[8] = -(light1_x/light1_z); m[12]= 0;
            m[1]= 0; m[5]= 1; m[9] = -(light1_y/light1_z); m[13]= 0;
            m[2]= 0; m[6]= 0; m[10]= 0;                    m[14]= 0;
            m[3]= 0; m[7]= 0; m[11]= 0;                    m[15]= 1;
            
            
            if (shadows) {
                glPushMatrix();
                glMultMatrixf(m); /* apply shading matrix */
            }
            else {
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, mat_white);
                }
                        
            ofRect(0,0,1,1);
            
            glDisable (GL_DEPTH_TEST);
            
            glTranslatef(PropF(@"x-shear")*PropF(@"scale")*0.5,PropF(@"y-shear")*PropF(@"scale")*0.5,0);
            
            /**
            float size;
            
            ofSetColor(0, 0, 0, 255/((3)*(1.5+sin((0.33+ofGetElapsedTimef())*4)*0.5)));
            size = (PropF(@"scale")*0.1)+((PropF(@"scale")*(1.5+sin((0.33+ofGetElapsedTimef())*4)*0.25)));
            ofEllipse(0.25, 0.5, size, size);
            
            
            ofSetColor(0, 0, 0, 255/((3)*(1.5+sin((ofGetElapsedTimef())*4)*0.5)));
            size = (PropF(@"scale")*0.1)+(PropF(@"scale")*(1.5+sin((ofGetElapsedTimef())*4)*0.25));
            ofEllipse(0.5, 0.75, size, size);
            
            
            ofSetColor(0, 0, 0, 255/((3)*(1.5+sin((0.66+ofGetElapsedTimef())*4)*0.5)));
            size = (PropF(@"scale")*0.1)+(PropF(@"scale")*(1.5+sin((0.66+ofGetElapsedTimef())*4)*0.25));
            ofEllipse(0.75, 0.5, size, size);
            **/
            
            glEnable (GL_DEPTH_TEST);

            if (shadows) {
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_black);
                glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_black);
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, mat_black);
            } else {
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, mat_white);
            }
            squirrelModel.setPosition(0.25, 0.5, -((PropF(@"scale")*0.5)*(1.5+sin((0.33+ofGetElapsedTimef())*4)*0.5)));
            squirrelModel.draw();
            
            squirrelModel.setPosition(0.5, 0.75, -((PropF(@"scale")*0.5)*(1.5+sin(ofGetElapsedTimef()*4)*0.5)));
            squirrelModel.draw();
            
            squirrelModel.setPosition(0.75, 0.5, -((PropF(@"scale")*0.5)*(1.5+sin((0.66+ofGetElapsedTimef())*4)*0.5)));
            squirrelModel.draw();
            
            if (shadows) {
                glPopMatrix();
            }
            
        } glPopMatrix();
        
    } PopSurfaceForProjector();

}
@end
