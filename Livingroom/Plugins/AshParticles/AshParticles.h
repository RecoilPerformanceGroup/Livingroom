#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#include "ParticleSystem.h"
#import "ofxShader.h"
#include "ofxCvMain.h"
#import "perlin.h"

#define NUM_PARTICLE_SYSTEMS_MAX (20*1)

#define NUM_PARTICLE_SYSTEMS (int(NUM_PARTICLE_SYSTEMS_MAX * numberParticles))
#define NUM_K_PARTICLES 5
//#define NUM_PARTICLES NUM_K_PARTICLES*1024
#define NUM_PARTICLES (1024*NUM_K_PARTICLES)
#define NUMP (NUM_PARTICLE_SYSTEMS*NUM_PARTICLES)
#define NUMPMAX (NUM_PARTICLE_SYSTEMS_MAX*NUM_PARTICLES)

#define GRID_SIZE (1024/2)
//#define GRID_SIZE 10

struct WindObject {
    ofVec2f v;
    ofVec2f p;
};

@interface AshParticles : ofPlugin {
   	int kParticles;
    Particle particles[NUM_PARTICLE_SYSTEMS_MAX][NUM_PARTICLES];
    int lastParticleSystem;
    int lastParticleNumber;
    
    ofImage * ashTexture;
    
    float dead;
    float alive;
    float livingUp;
    float dying;
    
    //float grid[GRID_SIZE][GRID_SIZE];
    ofxCvGrayscaleImage grid; 
    ofxCvGrayscaleImage diff; 
    ofxCvGrayscaleImage timeDiff; 
    ofxCvGrayscaleImage fade; 
    ofxCvContourFinder contourFinder;
    ofxCvFloatImage distanceImage;

    ofxCvGrayscaleImage blackImage; 
    ofxCvGrayscaleImage blackImageThreshold; 
   ofxCvGrayscaleImage blackImageLast; 
    ofxCvGrayscaleImage spawner; 
    int fadeOutCounter;
    
    GLuint particleVBO[3];
    ofPoint  pos[NUMPMAX]; 
    ofVec4f color[NUMPMAX];
    ofVec4f colorDebug[NUMPMAX];
    
    Perlin * perlinX;
    Perlin * perlinY;
    
    vector<WindObject> wind;

}

@end
