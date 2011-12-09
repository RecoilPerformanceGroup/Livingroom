//
//  PolyInput.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyInput.h"

@implementation PolyInput
-(id)init{
    if(self = [super init]){
        type = PolyTypeInput;
    } 
    return self;
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

- (void) controlKeyPressed:(int)key modifier:(int)modifier{
}

- (BOOL) isInput{return YES;};

@end
