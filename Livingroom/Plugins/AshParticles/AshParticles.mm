#import "AshParticles.h"
#import "Tracker.h"
#import <ofxCocoaPlugins/Keystoner.h>

@implementation AshParticles

- (id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void)initPlugin{
    [self addPropF:@"numberParticles"];
    [self addPropB:@"die"];
    [self addPropF:@"trackerSpawner"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"trackerRepulsionForce"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"trackerRepulsionForceRadius"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"trackerMagneticForce"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"trackerMagneticForceRadius"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.2 minValue:0.0 maxValue:1.0] named:@"trackerMagneticForceRadiusBig"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"globalDampingForce"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"renderSize"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"alpha"];
    
}

//
//----------------
//


-(void)setup{
    //    shader = new ofxShader();
    //    
    //    NSBundle *framework=[NSBundle bundleForClass:[self class]];
    //
    //    NSString * vert = [framework pathForResource:@"particles" ofType:@"vs"];
    //    NSString * frag = [framework pathForResource:@"particles" ofType:@"fs"];
    //    ashTexture = new ofImage();
    //    shader->loadShader([vert cStringUsingEncoding:NSUTF8StringEncoding], [frag cStringUsingEncoding:NSUTF8StringEncoding]);
    
    
	float padding = 0.0;
	float maxVelocity = .05;
    
    for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
        for(int i = 0; i < NUM_PARTICLES; i++) {
            float x = ofRandom(padding, 1.0 - padding);
            float y = ofRandom(padding, 1.0 - padding);
            float xv = 0;//ofRandom(-maxVelocity, maxVelocity);
            float yv = 0;//ofRandom(-maxVelocity, maxVelocity);
            particles[u][i] = Particle(x, y, xv, yv);
            particles[u][i].size = ofRandom(0.5,1);
        }        
    }
    
    
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
    
    float globalDampingForce = PropF(@"globalDampingForce");
    float trackerRepulsionForce = PropF(@"trackerRepulsionForce");
    float trackerRepulsionForceRadius = PropF(@"trackerRepulsionForceRadius");    
    CachePropF(trackerMagneticForce);
    CachePropF(trackerMagneticForceRadius);    
    CachePropF(trackerMagneticForceRadiusBig);    
    
    
    //--------------------------------------------
    
    
    dead = 0;
    alive = 0;
    livingUp = 0;
    dying = 0;
    
    for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
        Particle * particle =  &particles[u][0];
        for(int i = 0; i < NUM_PARTICLES; i++) {
            if(particle->dead && !particle->livingUp)
                dead++;
            if(particle->alive && !particle->dying)
                alive++;
            if(particle->livingUp)
                livingUp++;
            if(particle->dying)
                dying++;
            particle++;
        }
    }
    dead /= (float)NUMP;
    alive /= (float)NUMP;
    livingUp /= (float)NUMP;
    dying /= (float)NUMP;
    
    //--------------------------------------------
    
    float numberParticles = PropF(@"numberParticles");
    if(numberParticles > (alive+livingUp)){
        int diff = numberParticles*NUMP - (livingUp+alive)*NUMP;
        for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
            Particle * particle =  &particles[u][0];
            for(int i = 0; i < NUM_PARTICLES; i++) {
                if(diff > 0 && particle->dead && !particle->livingUp){
                    particle->livingUp = true;
                    diff--;
                    if(diff == 0) break;
                }
                particle++;
                
            }
            if(diff == 0) break;
        }
    }
    
    if(PropB(@"die")){
        if(numberParticles < 1-(alive)){
            int diff = (alive)*NUMP- (numberParticles)*NUMP;
            for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
                Particle * particle =  &particles[u][0];
                for(int i = 0; i < NUM_PARTICLES; i++) {
                    if(diff > 0 && particle->alive && !particle->dying){
                        particle->dying = true;
                        diff--;
                        if(diff == 0) break;
                    }
                    particle++;
                    
                }
                if(diff == 0) break;
            }
        }
    }
    
    vector <ofVec2f> trackers = [GetPlugin(Tracker) trackerCentroidVector];
    vector < vector<ofVec2f> > trackersPoints = [GetPlugin(Tracker) trackerBlobVector];
    
    CachePropF(trackerSpawner);
    if(trackerSpawner){
        if(alive < 1){
            for(int t=0;t<trackersPoints.size();t++){
                if(trackersPoints[t].size() > 0){
                    vector<ofPoint> vector;
                    for(int j=0;j<trackersPoints[t].size();j++){
                        vector.push_back(ofPoint(trackersPoints[t][j].x, trackersPoints[t][j].y, 0));
                    }
                    
                    
                    int diff = 100.0*trackerSpawner;
                    
                    for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
                        Particle * particle =  &particles[u][0];
                        for(int i = 0; i < NUM_PARTICLES; i++) {
                            if(diff > 0 && particle->dead && !particle->livingUp){
                                particle->livingUp = true;
                                
                                ofVec2f p = trackersPoints[t][0]+ofVec2f(ofRandom(-0.2,0.2),ofRandom(-0.2,0.2));
                                while(!ofInsidePoly(p.x, p.y, vector)){
                                    p = trackersPoints[t][0]+ofVec2f(ofRandom(-0.2,0.2),ofRandom(-0.2,0.2));
                                }
                                
                                particle->x = p.x;
                                particle->y = p.y;
                                diff--;
                                if(diff == 0) break;
                            }
                            particle++;
                        }
                        if(diff == 0) break;
                    }
                }
            }
            
        }
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
        [queue addOperationWithBlock:^{
            Particle * particle =  &particles[u][0];
            for(int i = 0; i < NUM_PARTICLES; i++) {
                particle->resetForce();
                
                for(int t=trackers.size()-1;t>=0;t--){
                    const ofVec2f * tracker = &trackers[t];
                    
                    if(trackerRepulsionForce){
                        
                        if(tracker->x > particle->x - trackerRepulsionForceRadius 
                           && tracker->x < particle->x + trackerRepulsionForceRadius 
                           &&tracker->y > particle->y - trackerRepulsionForceRadius 
                           && tracker->y < particle->y + trackerRepulsionForceRadius){
                            
                            ofVec2f p = ofVec2f(particle->x, particle->y);
                            float dist = p.distance(*tracker);
                            if(dist < trackerRepulsionForceRadius){
                                ofVec2f f = (p - *tracker) / dist;
                                f *= 1.0-(dist/trackerRepulsionForceRadius);
                                f *= trackerRepulsionForce;
                                particle->xf += f.x;
                                particle->yf += f.y;
                            }
                        } 
                    }
                    
                    if(trackerMagneticForce){
                        if(tracker->x > particle->x - trackerMagneticForceRadiusBig 
                           && tracker->x < particle->x + trackerMagneticForceRadiusBig 
                           &&tracker->y > particle->y - trackerMagneticForceRadiusBig 
                           && tracker->y < particle->y + trackerMagneticForceRadiusBig){
                            
                            ofVec2f p = ofVec2f(particle->x, particle->y);
                            float dist = p.distance(*tracker);
                            if(dist < trackerMagneticForceRadiusBig && dist > trackerMagneticForceRadius){
                                ofVec2f f = (p - *tracker) / dist;
                                f *= 1.0-(dist/trackerMagneticForceRadiusBig);
                                f *= trackerMagneticForce;
                                particle->xf -= f.x;
                                particle->yf -= f.y;
                            }                        
                        }                         
                    }                   
                }
                
                particle->bounceOffWalls(0, 0, 1,1);
                particle->addDampingForce(0.5*globalDampingForce);
                particle->updatePosition(1.0);
                
                particle++;
            }
        }];
    }
    
    
    
    [queue waitUntilAllOperationsAreFinished];
    
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    
    ApplySurfaceForProjector(@"Floor",0); {
        
        ofSetColor(255, 255, 255);
        ofFill();
        ofRect(0,0,1,1);
        
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
        /*
         
         ofVec2f dirs[4];
         dirs[0] = ofVec2f(-1,-1);
         dirs[1] = ofVec2f(1,-1);
         dirs[2] = ofVec2f(1,1);
         dirs[3] = ofVec2f(-1,1);
         
         int texW = 8;
         int texH = 8;
         
         ashTexture->getTextureReference().bind();
         glBegin(GL_QUADS);
         
         for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
         Particle * particle =  &particles[u][0];
         for(int i = 0; i < NUM_PARTICLES; i++) {
         ofVec2f p = ofVec2f(particle->x, particle->y); 
         float _size = size*particle->size*0.01;
         glTexCoord2f (0.0, 0.0);
         glVertex2f((p-dirs[0]*_size).x, (p-dirs[0]*_size).y);
         
         glTexCoord2f (texW, 0.0);
         glVertex2f((p-dirs[1]*_size).x, (p-dirs[1]*_size).y);
         
         glTexCoord2f (texW, texH);
         glVertex2f((p-dirs[2]*_size).x, (p-dirs[2]*_size).y);
         
         glTexCoord2f (0.0, texH);
         glVertex2f((p-dirs[3]*_size).x, (p-dirs[3]*_size).y);
         
         particle++;
         
         }
         
         }
         glEnd();
         ashTexture->getTextureReference().unbind();*/
        
        CachePropF(alpha);
        glPointSize(PropF(@"renderSize"));
        glBegin(GL_POINTS);
        
        for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
            Particle * particle =  &particles[u][0];
            for(int i = 0; i < NUM_PARTICLES; i++) {
                if(particle->alpha > 0){
                    glColor4f(alpha*particle->alpha,alpha*particle->alpha,alpha*particle->alpha,1.0);
                    particle->draw();
                }
                particle++;
            }
        }
        glEnd();
        ofEnableAlphaBlending();
    } PopSurfaceForProjector();
    
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
    
    float x = 0;    
    
    ofSetColor(255,0,0);    
    ofRect(x,0,dead*ofGetWidth(),30);
    x += dead*ofGetWidth();
    
    ofSetColor(255,180,180);    
    ofRect(x,0,dying*ofGetWidth(),30);
    x += dying*ofGetWidth();
    
    ofSetColor(180,255,180);    
    ofRect(x,0,livingUp*ofGetWidth(),30);
    x += livingUp*ofGetWidth();
    
    
    ofSetColor(0,255,0);
    ofRect(x,0,alive*ofGetWidth(),30);
    x += alive*ofGetWidth();
    
}

@end
