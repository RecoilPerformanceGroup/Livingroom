
#import "AshParticles.h"
#import "Tracker.h"
#import <ofxCocoaPlugins/Keystoner.h>
#import <ofxCocoaPlugins/CustomGraphics.h>

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
    
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"wind"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"windTurb"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"windSpeed"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"windForce"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"windForceRadius"];
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"reset"];
    
    
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"resetBurn"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"burn"];
    [self addProperty:[NumberProperty sliderPropertyWithDefaultvalue:0.0 minValue:0.0 maxValue:1.0] named:@"particleOverlap"];
    
    
    
    
}

//
//----------------
//


-(void)setup{
    
    
    NSBundle *framework=[NSBundle bundleForClass:[self class]];
    
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
            pos[NUM_PARTICLES*u+i] = ofPoint(x,y,0);
            color[NUM_PARTICLES*u+i] = ofVec4f(0.0,0.0,0.0,1.0);
        }        
    }
    
    grid.allocate(GRID_SIZE, GRID_SIZE);
    grid.set(0);
    
    diff.allocate(GRID_SIZE, GRID_SIZE);
    diff.set(0);
    
    timeDiff.allocate(GRID_SIZE, GRID_SIZE);
    timeDiff.set(0);
    
    fade.allocate(GRID_SIZE, GRID_SIZE);
    fade.set(10);
    
    
    distanceImage.allocate(GRID_SIZE, GRID_SIZE);
    distanceImage.set(0);
    
    //   NSBundle *framework=[NSBundle bundleForClass:[self class]];
    NSString * path = [framework pathForResource:@"ash8x8" ofType:@"jpg"];
    ashTexture = new ofImage();
    bool imageLoaded = ashTexture->loadImage([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if(!imageLoaded){
        NSLog(@"Ash image not found in cameraCalibration!!");
    }
    
    
    
    glewInit();
    glGenBuffersARB(2, &particleVBO[0]);
    
    // color
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, particleVBO[0]);
    glBufferDataARB(GL_ARRAY_BUFFER_ARB, (NUMP)*sizeof(ofVec4f), &color[0].x, GL_STREAM_DRAW_ARB);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // vertices
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, particleVBO[1]);
    glBufferDataARB(GL_ARRAY_BUFFER_ARB, (NUMP)*sizeof(ofVec3f), &pos[0].x, GL_STREAM_DRAW_ARB);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    
    
    perlinX = new Perlin(4, 8, 1, 0);
    perlinY = new Perlin(4, 8, 1, 1);
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
    CachePropF(alpha);
    CachePropF(windForce);    
    CachePropF(windForceRadius);    
    float d = PropF(@"particleOverlap")*0.01;
    
    //---------------- RESET ------------------
    
    if(PropB(@"reset")){
        [Prop(@"reset") setBoolValue:NO];
        [Prop(@"burn") setBoolValue:NO];
        
        for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
            for(int i = 0; i < NUM_PARTICLES; i++) {
                float x = ofRandom(0, 1.0);
                float y = ofRandom(0, 1.0);
                particles[u][i].x = x;
                particles[u][i].y = y;
                particles[u][i].xv = 0;
                particles[u][i].yv = 0;
                particles[u][i].dead = true;
                particles[u][i].alive = false;
                particles[u][i].livingUp = false;
                particles[u][i].dying = false;
                particles[u][i].alpha = 0;
            }
        }
    }
    
    if(PropB(@"resetBurn")){
        [Prop(@"resetBurn") setBoolValue:NO];
        [Prop(@"burn") setBoolValue:NO];
        
        
        int i=0,u=0;
        for(float x=0;x<1;x+=1.0/400.0){
            for(float y=0;y<1;y+=1.0/400.0){
                particles[u][i].x = x;
                particles[u][i].y = y;
                particles[u][i].xv = 0;
                particles[u][i].yv = 0;
                particles[u][i].dead = false;
                particles[u][i].alive = true;
                particles[u][i].livingUp = false;
                particles[u][i].dying = false;
                particles[u][i].alpha = 1.;
                
                i++;
                if(i==NUM_PARTICLES){
                    i = 0;
                    u++;
                }
            }
        }
    }
    
    
    //---------------- TRACKER ------------------
    
    ofxCvGrayscaleImage tracker = [GetPlugin(Tracker) trackerImageWithResolution:GRID_SIZE];
    //  grid += tracker;
    
    /*  diff = tracker;
     diff -= grid;
     diff.threshold(254);*/
    
    diff = tracker;
    diff -= timeDiff;
    
    //  diff.absDiff(tracker, grid);
    
    grid -= fade;
    grid += diff;
    
    
    contourFinder.findContours(grid, 0, GRID_SIZE*GRID_SIZE, 10, NO);
    
    timeDiff = tracker;
    
    /*    cvDistTransform(tracker.getCvImage(), distanceImage.getCvImage());
     distanceImage.flagImageChanged();*/
    
    
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
        int diffNum = numberParticles*NUMP - (livingUp+alive)*NUMP;
        for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
            Particle * particle =  &particles[u][0];
            for(int i = 0; i < NUM_PARTICLES; i++) {
                if(diffNum > 0 && particle->dead && !particle->livingUp){
                    particle->livingUp = true;
                    diffNum--;
                    if(diffNum == 0) break;
                }
                particle++;
                
            }
            if(diffNum == 0) break;
        }
    }
    
    if(PropB(@"die")){
        if(numberParticles < (alive)){
            int diffNum = (alive)*NUMP- (numberParticles)*NUMP;
            for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
                Particle * particle =  &particles[u][0];
                for(int i = 0; i < NUM_PARTICLES; i++) {
                    if(diffNum > 0 && particle->alive && !particle->dying){
                        particle->dying = true;
                        diffNum--;
                        if(diffNum == 0) break;
                    }
                    particle++;
                    
                }
                if(diffNum == 0) break;
            }
        }
    }
    
    // vector <ofVec2f> trackers = [GetPlugin(Tracker) trackerCentroidVector];
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
                    
                    
                    int diffNum = 100.0*trackerSpawner;
                    
                    for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
                        Particle * particle =  &particles[u][0];
                        for(int i = 0; i < NUM_PARTICLES; i++) {
                            if(diffNum > 0 && particle->dead && !particle->livingUp){
                                
                                ofVec2f p = trackersPoints[t][0]+ofVec2f(ofRandom(-0.2,0.2),ofRandom(-0.2,0.2));
                                int w=0;
                                bool ok = NO;
                                while(!ofInsidePoly(p.x, p.y, vector) && w++<20){
                                    p = trackersPoints[t][0]+ofVec2f(ofRandom(-0.1,0.1),ofRandom(-0.1,0.1));
                                    ok = YES;
                                }
                                if(ok){
                                    particle->x = p.x;
                                    particle->y = p.y;
                                    particle->livingUp = true;
                                    
                                    diffNum--;
                                    if(diffNum == 0) break;
                                }
                            }
                            particle++;
                        }
                        if(diffNum == 0) break;
                    }
                }
            }
            
        }
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
        [queue addOperationWithBlock:^{
            Particle * particle =  &particles[u][0];
            
            int rand[10];
            for(int j=0;j<10;j++){
                rand[j] = ofRandom(0,NUM_PARTICLES);   
            }
            for(int i = 0; i < NUM_PARTICLES; i++) {
                if(particle->alive || particle->livingUp || particle->dying){
                    particle->resetForce();
                    ofVec2f p = ofVec2f(particle->x, particle->y);
                    
                    
                    int gridIndex = (int)(int(GRID_SIZE*particle->y)*GRID_SIZE + int(GRID_SIZE*particle->x));
                    if(gridIndex >=0  && gridIndex < grid.width*grid.height){
                        unsigned char pixel = grid.getPixels()[gridIndex];
                        if(gridIndex >= 0 && gridIndex < GRID_SIZE*GRID_SIZE &&  pixel > 0){
                            //----------- Inside blob -----------
                            
                            if(contourFinder.blobs.size() > 0){
                                float bestDist = -1;
                                ofVec2f tracker;
                                
                                
                                ofVec2f pScaled = p * ofVec2f(GRID_SIZE,GRID_SIZE);
                                for(int ii=0;ii<contourFinder.blobs.size();ii++){
                                    for(int uu=0;uu<contourFinder.blobs[ii].nPts;uu+=15){                            
                                        float _dist = contourFinder.blobs[ii].pts[uu].distanceSquared(pScaled);
                                        if(bestDist == -1 || bestDist > _dist){
                                            bestDist = _dist;
                                            tracker = contourFinder.blobs[ii].pts[uu];
                                        }
                                    }
                                }
                                
                                tracker /= ofVec2f(GRID_SIZE,GRID_SIZE);
                                
                                if(trackerRepulsionForce){
                                    ofVec2f f = (tracker-p);
                                    f *= trackerRepulsionForce * (pixel/255.0);
                                    particle->xf += f.x;
                                    particle->yf += f.y;
                                }
                            }
                        }
                    }
                    
                    
                    //----------- Wind -----------
                    int numWinds = wind.size();
                    if(windForce > 0){
                        for(int w=0;w<numWinds;w++){
                            ofVec2f * wP = &wind[w].p;
                            if(wP->x > particle->x - windForceRadius 
                               && wP->x < particle->x + windForceRadius 
                               && wP->y > particle->y - windForceRadius 
                               && wP->y < particle->y + windForceRadius){
                                
                                float dist = wP->distance(p);
                                if(dist < windForceRadius){
                                    
                                    ofVec2f f = wind[w].v;
                                    f *= 1.0-(dist/windForceRadius);
                                    f *= windForce*0.1;
                                    particle->xf += f.x;
                                    particle->yf += f.y;
                                    
                                }
                            }
                        }
                    }
                    
                    /*for(int t=trackers.size()-1;t>=0;t--){
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
                     }*/
                    
                    if(d > 0){
                        for(int iii=0;iii<10;iii++){
                            // Particle * otherParticle = &particles[int(ofRandom(0,NUM_PARTICLE_SYSTEMS-1))][int(ofRandom(0,NUM_PARTICLES-1))];
                            if(u != NUM_PARTICLE_SYSTEMS-1){
                                Particle * otherParticle = particle+rand[iii];
                                if(otherParticle->alive && fabs(particle->x - otherParticle->x) < d &&  fabs(particle->y - otherParticle->y)){
                                    ofVec2f v = ofVec2f(d,0).rotate(ofRandom(0,360));
                                    /*                            particle->x += v.x;
                                     particle->y += v.y;*/
                                    particle->xf += v.x;
                                    particle->yf += v.y;
                                    
                                    
                                    //    particle->dying = true;
                                    //    particle->alive = false;
                                }
                            }
                        }
                    }
                    
                    particle->bounceOffWalls(0, 0, 1,1);
                    particle->addDampingForce(0.5*globalDampingForce);
                    particle->updatePosition(1.0);
                    
                    pos[NUM_PARTICLES*u+i] = ofPoint(particle->x,particle->y,0);
                }
                
                particle++;
            }
        }];
    }
    
    
    
    [queue waitUntilAllOperationsAreFinished];
    
    //-------------- COLOR ------------------
    
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, particleVBO[0]);
    int first = -1;
    int num = 0;
    
    for(int u=0;u<NUM_PARTICLE_SYSTEMS;u++){
        Particle * particle =  &particles[u][0];
        for(int i = 0; i < NUM_PARTICLES; i++) {
            int j = NUM_PARTICLES*u+i;
            if(color[j].x != alpha*particle->alpha){
                color[j] = ofVec4f(alpha*particle->alpha,alpha*particle->alpha,alpha*particle->alpha,1.0);
                
                if(first == -1){
                    first = j;
                    num = 0;
                }
                num++;
                
            }
            else if(first != -1){
                glBufferSubData(GL_ARRAY_BUFFER, first*sizeof(ofVec4f), (num)*sizeof(ofVec4f), &color[first].x);
                first = -1;
            }
            particle++;
        }
    }
    
    if(first != -1){
        glBufferSubData(GL_ARRAY_BUFFER, first*sizeof(ofVec4f), (num)*sizeof(ofVec4f), &color[first].x);
    }
    //  glBufferSubData(GL_ARRAY_BUFFER, 0, (NUMP)*sizeof(ofVec4f), &color[0].x);
    
    glBindBufferARB(GL_ARRAY_BUFFER, 0);
    
    //--------------  POSITION ------------------    
    
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, particleVBO[1]);
    glBufferSubData(GL_ARRAY_BUFFER, 0, ((alive+livingUp)*NUMP)*sizeof(ofPoint), &pos[0].x);
    glBindBufferARB(GL_ARRAY_BUFFER, 0);
    
    
    //-------------- WIND ------------------------
    float windAmm = PropF(@"wind");
    if(windAmm > 0){
        for(int i=0;i<windAmm*10;i++){
            WindObject obj;
            obj.p = ofVec2f(0.5,0.5);
            obj.v = ofVec2f(ofRandom(-1,1), ofRandom(-1,1)).normalized();
            wind.push_back(obj);
        }
    }
    
    CachePropF(windTurb);
    CachePropF(windSpeed);
    for(int i=0;i<wind.size();i++){
        wind[i].v += windTurb*ofVec2f(perlinX->Get( wind[i].p.x, wind[i].p.y), perlinY->Get( wind[i].p.x, wind[i].p.y));
        wind[i].v.normalize();
        
        wind[i].p +=  wind[i].v * 0.1*windSpeed;
        
        if(wind[i].p.x > 1 || wind[i].p.x < 0 || wind[i].p.y > 1 || wind[i].p.y < 0){
            wind.erase(wind.begin()+i);
        }
    }
    
    //--------------------------------------------
    
    
    
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    
    ApplySurfaceForProjector(@"Floor",0); {
        
        ofSetColor(255, 255, 255);
        ofFill();
        ofRect(0,0,1,1);
        
        glEnable (GL_BLEND);
        glBlendFunc (GL_ZERO, GL_ONE_MINUS_SRC_COLOR);
        
        
        //Points
        
        glPointSize(PropF(@"renderSize"));
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glBindBufferARB(GL_ARRAY_BUFFER_ARB, particleVBO[1]);
        glVertexPointer(3, GL_FLOAT, sizeof(ofVec3f), 0);
        
        glEnableClientState(GL_COLOR_ARRAY);
        glBindBufferARB(GL_ARRAY_BUFFER_ARB, particleVBO[0]);
        glColorPointer(4, GL_FLOAT, sizeof(ofVec4f), 0);
        
        glDrawArrays(GL_POINTS, 0, ((alive+livingUp+dying)*NUMP));
        
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
        
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
    
    ofSetColor(255,255,255);
    grid.draw(0,40,ofGetWidth(), ofGetHeight()-40);
    
    contourFinder.draw(0,40,ofGetWidth(), ofGetHeight()-40);
    
    for(float x=0;x<1;x+= 0.025){
        for(float y=0;y<1;y+= 0.025){
            ofVec2f p = ofVec2f(x*ofGetWidth(), y*(ofGetHeight()-40)+40);
            of2DArrow(p, p + 10*ofVec2f(perlinX->Get(x, y), perlinY->Get(x,y)), 2);
        }
    }
    
    ofSetColor(255,255,0);
    for(int i=0;i<wind.size();i++){
        ofVec2f p = ofVec2f(wind[i].p.x*ofGetWidth(), wind[i].p.y*(ofGetHeight()-40)+40);
        of2DArrow(p, p + 10*wind[i].v, 2);
        
    }
    
    
}

@end
