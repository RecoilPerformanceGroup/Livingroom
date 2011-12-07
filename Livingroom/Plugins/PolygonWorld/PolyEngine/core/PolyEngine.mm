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
#import "PolyRenderCracks.h"

#import "PolyInputSimpleMouse.h"

#import "PolyAnimatorSimplePushPop.h"
#import "PolyAnimatorSprings.h"
#import "PolyAnimatorCracks.h"

@implementation PolyEngine
@synthesize arrangement;

-(id)init {
    if(self = [super init]){
        [self willChangeValueForKey:@"allModules"];
        
        arrangement = [[PolyArrangement alloc] init];
        
        renders = [NSMutableDictionary dictionary];
        [renders setObject:[[PolyRenderSimpleWireframe alloc] initWithEngine:self] forKey:@"simpleWire"];
    //    [renders setObject:[[PolyRenderCracks alloc] initWithEngine:self] forKey:@"cracks"];

        inputs = [NSMutableDictionary dictionary];
        [inputs setObject:[[PolyInputSimpleMouse alloc] initWithEngine:self] forKey:@"polyInputSimpleMouse"];

        animators = [NSMutableDictionary dictionary];
//        [animators setObject:[[PolyAnimatorSimplePushPop alloc] initWithEngine:self] forKey:@"polyAnimatorSimplePushPop"];
        [animators setObject:[[PolyAnimatorCracks alloc] initWithEngine:self] forKey:@"polyAnimatorCracks"];
     //   [animators setObject:[[PolyAnimatorSprings alloc] initWithEngine:self] forKey:@"polyAnimatorSprings"];
        
        [self didChangeValueForKey:@"allModules"];

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

-(NSMutableArray *)allModules{
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Inputs",@"name", nil];
    NSMutableArray * children = [NSMutableArray array];
    for(PolyModule * module in inputs){
        NSMutableDictionary * child = [NSMutableDictionary dictionary];
        [child setObject:[inputs objectForKey:module] forKey:@"module"];
        [child setObject:module  forKey:@"name"];
        [children addObject: child];
    }
    [dict setObject:children forKey:@"children"];
    [arr addObject:dict];

    
    dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Animators",@"name", nil];
    children = [NSMutableArray array];
    for(PolyModule * module in animators){
        NSMutableDictionary * child = [NSMutableDictionary dictionary];
        [child setObject:[animators objectForKey:module] forKey:@"module"];
        [child setObject:module  forKey:@"name"];
        [children addObject: child];
    }
    [dict setObject:children forKey:@"children"];
    [arr addObject:dict];

    
    dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Renders",@"name", nil];
    children = [NSMutableArray array];
    for(PolyModule * module in renders){
        NSMutableDictionary * child = [NSMutableDictionary dictionary];
        [child setObject:[renders objectForKey:module] forKey:@"module"];
        [child setObject:module  forKey:@"name"];
        [children addObject: child];
    }
    [dict setObject:children forKey:@"children"];
    [arr addObject:dict];

    
    
    return arr;
        
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
    
    for(NSString* p in animators){
        [[animators objectForKey:p] draw:drawingInformation];
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

- (void) controlMouseMoved:(float) x y:(float)y {
    for(NSString* p in inputs){
        [[inputs objectForKey:p] controlMouseMoved:x y:y];
    }   
    for(NSString* p in animators){
        [[animators objectForKey:p] controlMouseMoved:x y:y];
    }   
}

- (void) controlMousePressed:(float) x y:(float)y button:(int)button{
    for(NSString* p in inputs){
        [[inputs objectForKey:p] controlMousePressed:x y:y button:button];
    }   
    for(NSString* p in animators){
        [[animators objectForKey:p] controlMousePressed:x y:y button:button];
    }   
}

- (void) controlMouseReleased:(float) x y:(float)y{
    for(NSString* p in inputs){
        [[inputs objectForKey:p] controlMouseReleased:x y:y];
    }   
    for(NSString* p in animators){
        [[animators objectForKey:p] controlMouseReleased:x y:y];
    }    
}
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button{
    for(NSString* p in animators){
        [[animators objectForKey:p] controlMouseDragged:x y:y button:button];
    }   
}
//- (void) controlMouseScrolled:(NSEvent *)theEvent;

- (void) controlKeyPressed:(int)key modifier:(int)modifier{
    for(NSString* p in inputs){
        [[inputs objectForKey:p] controlKeyPressed:key modifier:modifier];
    }
}

//- (void) controlKeyReleased:(int)key modifier:(int)modifier;

@end
