#import "AshParticles.h"

@implementation AshParticles

- (id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
    kParticles = 8;
	float padding = 0.1;
	float maxVelocity = .05;
	for(int i = 0; i < kParticles * 1024; i++) {
		float x = ofRandom(padding, 1.0 - padding);
		float y = ofRandom(padding, 1.0 - padding);
		float xv = 0;//ofRandom(-maxVelocity, maxVelocity);
		float yv = 0;//ofRandom(-maxVelocity, maxVelocity);
		Particle particle(x, y, xv, yv);
		particleSystem.add(particle);
	}
    
	particleSystem.setTimeStep(1);
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    particleSystem.setupForces();
    
	// apply per-particle forces
	for(int i = 0; i < particleSystem.size(); i++) {
		Particle& cur = particleSystem[i];
		// global force on other particles
		particleSystem.addRepulsionForce(cur, 0.001, 0.01);
		// forces on this particle
		cur.bounceOffWalls(0, 0, 1,1);
		cur.addDampingForce(0.1);
	}
	// single global forces
//&	particleSystem.addAttractionForce(ofGetWidth() / 2, ofGetHeight() / 2, 1500, 0.01);
	//particleSystem.addRepulsionForce(0.5, 0.5, 100, 2);
	particleSystem.update();
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    ofSetColor(255, 255, 255);
	ofFill();
	particleSystem.draw();
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
