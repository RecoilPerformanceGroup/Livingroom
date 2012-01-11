#import "AshParticles.h"
#import "Tracker.h"

@implementation AshParticles

- (id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void)initPlugin{
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"internalRepulsionForce"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"internalRepulsionForceRadius"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"trackerRepulsionForce"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"trackerRepulsionForceRadius"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"globalDampingForce"];

    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"renderSize"];

}

//
//----------------
//


-(void)setup{
    kParticles = 30;
	float padding = 0.1;
	float maxVelocity = .05;
	for(int i = 0; i < kParticles * 1024; i++) {
		float x = ofRandom(padding, 1.0 - padding);
		float y = ofRandom(padding, 1.0 - padding);
		float xv = 0;//ofRandom(-maxVelocity, maxVelocity);
		float yv = 0;//ofRandom(-maxVelocity, maxVelocity);
		Particle particle(x, y, xv, yv);
        particle.size = ofRandom(0.5,1);
		particleSystem.add(particle);
	}
    
	particleSystem.setTimeStep(1);
    
    
    NSBundle *framework=[NSBundle bundleForClass:[self class]];
    NSString * path = [framework pathForResource:@"ash8x8" ofType:@"jpg"];
    ashTexture = new ofImage();
    bool imageLoaded = ashTexture->loadImage([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if(!imageLoaded){
        NSLog(@"Ash image not found in cameraCalibration!!");
    }

}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    particleSystem.setupForces();
    
	// apply per-particle forces
    
    float internalRepulsionForce = PropF(@"internalRepulsionForce");
    float internalRepulsionForceRadius = PropF(@"internalRepulsionForceRadius");
    float globalDampingForce = PropF(@"globalDampingForce");
    float trackerRepulsionForce = PropF(@"trackerRepulsionForce");
    float trackerRepulsionForceRadius = PropF(@"trackerRepulsionForceRadius");    
    
	for(int i = 0; i < particleSystem.size(); i++) {
		Particle& cur = particleSystem[i];
		// global force on other particles
        if(internalRepulsionForce > 0){
            particleSystem.addRepulsionForce(cur, 0.01*internalRepulsionForceRadius, 0.1*internalRepulsionForce);
        }
        
		// forces on this particle
		cur.bounceOffWalls(0, 0, 1,1);
        
        if(globalDampingForce > 0)
            cur.addDampingForce(0.5*globalDampingForce);
	}
	// single global forces
	//particleSystem.addAttractionForce(0.5, 0.5, 0.5, 0.001);
    
    int n = [GetPlugin(Tracker) numberTrackers];
    for(int i=0; i<n;i++){
        ofVec2f centroid = [GetPlugin(Tracker) trackerCentroid:i];
        particleSystem.addRepulsionForce(centroid.x, centroid.y, 0.1*trackerRepulsionForceRadius, 0.1*trackerRepulsionForce);
    }

    
	particleSystem.update();
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    ofSetColor(255, 255, 255);
	ofFill();
    ofRect(0,0,1,1);
    
    int n = particleSystem.size();
	//glEnable(GL_POINT_SIZE);
	//glPointSize(2);
    ofSetColor(255,255,255);
    glEnable (GL_BLEND);
//    glBlendFunc (GL_ONE, GL_ONE);
        glBlendFunc (GL_ZERO, GL_ONE_MINUS_SRC_COLOR);

//    float size = PropF(@"renderSize");
//    for(int i = 0; i < n; i++){
//        glPushMatrix();
//        ofVec2f p = ofVec2f(particleSystem[i].x, particleSystem[i].y); 
//        glTranslated(p.x,p.y,0);
//        glRotated(i*2.12541, 0, 0, 1);        
////        ashTexture->draw(-size*0.5, -size*0.5, size*particleSystem[i].size,size*particleSystem[i].size);
//        glPopMatrix();
//    }

    float size = PropF(@"renderSize");
    
    ofVec2f dirs[4];
    dirs[0] = ofVec2f(-1,-1);
    dirs[1] = ofVec2f(1,-1);
    dirs[2] = ofVec2f(1,1);
    dirs[3] = ofVec2f(-1,1);
    
    int texW = 8;
    int texH = 8;
    
    ashTexture->getTextureReference().bind();
    glBegin(GL_QUADS);

    for(int i = 0; i < n; i++){
        glPushMatrix();
        ofVec2f p = ofVec2f(particleSystem[i].x, particleSystem[i].y); 
        float _size = size*particleSystem[i].size*0.01;
        glTexCoord2f (0.0, 0.0);
        glVertex2f((p-dirs[0]*_size).x, (p-dirs[0]*_size).y);

        glTexCoord2f (texW, 0.0);
        glVertex2f((p-dirs[1]*_size).x, (p-dirs[1]*_size).y);

        glTexCoord2f (texW, texH);
        glVertex2f((p-dirs[2]*_size).x, (p-dirs[2]*_size).y);

        glTexCoord2f (0.0, texH);
        glVertex2f((p-dirs[3]*_size).x, (p-dirs[3]*_size).y);
    }
    glEnd();
    ashTexture->getTextureReference().unbind();
    ofEnableAlphaBlending();
    
    
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
