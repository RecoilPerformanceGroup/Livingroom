//
//  PolyAnimatorCracks.h
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyAnimator.h"

@interface PolyAnimatorPhysics : PolyAnimator{
    NSMutableDictionary * blockPhysics;
    NSMutableDictionary * blockTiming;
    
    NSString * debugText;
    
    long long lastDebugUpdate;
    
    float movementActivity;
    float movementPan;
    bool noteOnSend;
    
    float movementActivitySmooth;
    float movementPanSmooth;
}
@property (readwrite, copy) NSString * debugText;
@property (readwrite) float movementActivity;
@property (readwrite) float movementPan;
-(void) addPhysicsBlock:(NSString *)name block:(void(^)(PolyArrangement * arrangement))block;
                         

@end
