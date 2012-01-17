//
//  PolyRenderCracks.h
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyRender.h"
#define NUM_GRADIENTS 500

struct gradientVals {
    float x;
    float y;
    float size;
    float intensity;
    float val;
};

@interface PolyRenderCrackLines : PolyRender {
    ofImage * gradient;
    
    gradientVals gradients[NUM_GRADIENTS];
}

@end
