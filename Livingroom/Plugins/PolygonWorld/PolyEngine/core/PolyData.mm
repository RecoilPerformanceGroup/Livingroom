//
//  PolyData.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyData.h"

@implementation PolyData
@synthesize arr;

-(id)init{
    if(self = [super init]){
        arr = new Arrangement_2;
    }
    return self;
}

@end
