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
}
@property (readwrite, copy) NSString * debugText;
-(void) addPhysicsBlock:(NSString *)name block:(void(^)(PolyArrangement * arrangement))block;
                         

@end
