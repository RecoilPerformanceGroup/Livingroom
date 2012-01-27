#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#include "ParticleSystem.h"
#import "ofxShader.h"

#define NUM_PARTICLE_SYSTEMS 8

@interface AshParticles : ofPlugin {
   	int kParticles;
	ParticleSystem particleSystem[NUM_PARTICLE_SYSTEMS];
    
    ofImage * ashTexture;
    
    ofxShader * shader;

}

@end
