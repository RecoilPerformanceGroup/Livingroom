//
//  PolyAnimator.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyAnimator.h"

@implementation PolyAnimator

-(id)init{
    if(self = [super init]){
        type = PolyTypeAnimator;
    } 
    return self;
}

-(void)draw:(NSDictionary *)drawingInformation{
}

-(void)controlDraw:(NSDictionary *)drawingInformation{

}

- (void)update:(NSDictionary *)drawingInformation{
    
}

- (void) controlMousePressed:(float) x y:(float)y button:(int)button{
    
}

- (void) controlMouseReleased:(float) x y:(float)y{

}

- (void) controlMouseMoved:(float) x y:(float)y{
    
}

- (void) controlMouseDragged:(float) x y:(float)y button:(int)button{
    
}
@end
