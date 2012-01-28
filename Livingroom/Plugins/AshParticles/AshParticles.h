#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#include "ParticleSystem.h"
#import "ofxShader.h"

#define NUM_PARTICLE_SYSTEMS 200
#define NUM_K_PARTICLES 1
//#define NUM_PARTICLES NUM_K_PARTICLES*1024
#define NUM_PARTICLES 1024*NUM_K_PARTICLES

@interface AshParticles : ofPlugin {
   	int kParticles;
    Particle particles[NUM_PARTICLE_SYSTEMS][NUM_PARTICLES];
    
    ofImage * ashTexture;
    
    ofxShader * shader;
    
//    NSThread * threads[NUM_PARTICLE_SYSTEMS]

}

@end
