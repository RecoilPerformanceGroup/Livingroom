#pragma once
#import <ofxCocoaPlugins/Plugin.h>
#include "ParticleSystem.h"


@interface AshParticles : ofPlugin {
   	int kParticles;
	ParticleSystem particleSystem;
    
    ofImage * ashTexture;

}

@end
