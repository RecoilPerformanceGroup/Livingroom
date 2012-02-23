//
//  PolyRenderCracks.h
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyRender.h"
#define NUM_GRADIENTS 100
#import "LEDGrid.h"


@interface PolyRenderCrackLines : PolyRender {
    ofImage * gradient;
    
    gradientVals gradients[NUM_GRADIENTS];
    
}

-(gradientVals*) gradients;

@end
