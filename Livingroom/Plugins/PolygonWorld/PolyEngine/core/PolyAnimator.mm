//
//  PolyAnimator.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyAnimator.h"

@implementation PolyAnimator

-(id) initWithEngine:(PolyEngine*)_engine{
    if(self = [self init]){
        engine = _engine;
    } 
    return self;
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
}
- (void)update:(NSDictionary *)drawingInformation{
    
}
@end
