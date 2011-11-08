//
//  PolyInputSimpleMouse.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyInputSimpleMouse.h"

@implementation PolyInputSimpleMouse

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    NSLog(@"%f %f",x,y);
}

@end
