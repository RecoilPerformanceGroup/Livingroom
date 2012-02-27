//
//  PolyAnimatorCracks.h
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyAnimator.h"

@interface PolyAnimatorCrumble : PolyAnimator{
    float crumbleSum;
    
    float lastMidiInput;
}
@property (readwrite) float crumbleSum;
-(void) addCrumbleSum:(float)sum;
@end
