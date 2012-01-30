#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#include "ParticleSystem.h"
#import "ofxShader.h"

#define NUM_PARTICLE_SYSTEMS 8
#define NUM_K_PARTICLES 30
//#define NUM_PARTICLES NUM_K_PARTICLES*1024
#define NUM_PARTICLES 1024*NUM_K_PARTICLES
#define NUMP NUM_PARTICLE_SYSTEMS*NUM_PARTICLES

#define GRID_SIZE 1024

@interface AshParticles : ofPlugin {
   	int kParticles;
    Particle particles[NUM_PARTICLE_SYSTEMS][NUM_PARTICLES];
    
    ofImage * ashTexture;
    
    ofxShader * shader;
    
    float dead;
    float alive;
    float livingUp;
    float dying;
    
    float grid[GRID_SIZE][GRID_SIZE];
    
    GLuint particleVBO[3];
    ofPoint  pos[NUMP]; 
    ofVec4f color[NUMP];
//    NSThread * threads[NUM_PARTICLE_SYSTEMS]

}

@end
