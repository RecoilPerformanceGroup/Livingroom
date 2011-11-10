//
//  PolyEngine.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyEngine.h"

#import "PolyArrangement.h"

#import "PolyRenderSimpleWireframe.h"

#import "PolyInputSimpleMouse.h"

@implementation PolyEngine
@synthesize arrangement;

-(id)init {
    if(self = [super init]){
        arrangement = [[PolyArrangement alloc] init];
        
        renders = [NSMutableDictionary dictionary];
        [renders setObject:[[PolyRenderSimpleWireframe alloc] initWithEngine:self] forKey:@"simpleWire"];

        inputs = [NSMutableDictionary dictionary];
        [inputs setObject:[[PolyInputSimpleMouse alloc] initWithEngine:self] forKey:@"polyInputSimpleMouse"];

        animators = [NSMutableDictionary dictionary];

    }
    return self;
}


-(PolyRender*) getRenderer:(NSString*)renderer{
    return [renders objectForKey:renderer];
}

-(PolyInput*) getInput:(NSString*)renderer{
    return [inputs objectForKey:renderer];
}

-(PolyAnimator*) getAnimator:(NSString*)renderer{
    return [animators objectForKey:renderer];    
}



#pragma mark --



- (void) setup{
    for(NSString* p in renders){
        [[renders objectForKey:p] setup];
    }        
    for(NSString* p in inputs){
        [[inputs objectForKey:p] setup];
    }        
    for(NSString* p in animators){
        [[animators objectForKey:p] setup];
    }        
}
- (void) draw:(NSDictionary*)drawingInformation{
    for(NSString* p in renders){
        [[renders objectForKey:p] draw:drawingInformation];
    }        
}
- (void) update:(NSDictionary*)drawingInformation{
    for(NSString* p in renders){
        [[renders objectForKey:p] update:drawingInformation];
    }        
    for(NSString* p in inputs){
        [[inputs objectForKey:p] update:drawingInformation];
    }        
    for(NSString* p in animators){
        [[animators objectForKey:p] update:drawingInformation];
    }      
}

- (void) controlDraw:(NSDictionary*)drawingInformation{
    for(NSString* p in renders){
        [[renders objectForKey:p] controlDraw:drawingInformation];
    }        
    for(NSString* p in inputs){
        [[inputs objectForKey:p] controlDraw:drawingInformation];
    }        
    for(NSString* p in animators){
        [[animators objectForKey:p] controlDraw:drawingInformation];
    }      
}

//- (void) controlMouseMoved:(float) x y:(float)y;
- (void) controlMousePressed:(float) x y:(float)y button:(int)button{
    for(NSString* p in inputs){
        [[inputs objectForKey:p] controlMousePressed:x y:y button:button];
    }   
}

//- (void) controlMouseReleased:(float) x y:(float)y;
//- (void) controlMouseDragged:(float) x y:(float)y button:(int)button;
//- (void) controlMouseScrolled:(NSEvent *)theEvent;

- (void) controlKeyPressed:(int)key modifier:(int)modifier{
    for(NSString* p in inputs){
        [[inputs objectForKey:p] controlKeyPressed:key modifier:modifier];
    }
}

//- (void) controlKeyReleased:(int)key modifier:(int)modifier;

@end
