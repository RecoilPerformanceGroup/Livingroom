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
@synthesize arrangement, modules;

-(id)init {
    if(self = [super init]){
        [self willChangeValueForKey:@"allModulesTree"];
        
        arrangement = [[PolyArrangement alloc] init];
        
        modules = [NSMutableDictionary dictionary];
        [modules setObject:[[PolyRenderSimpleWireframe alloc] initWithEngine:self] forKey:@"simpleWire"];
        //    [renders setObject:[[PolyRenderCracks alloc] initWithEngine:self] forKey:@"cracks"];
        
        PolyInputSimpleMouse * m = [[PolyInputSimpleMouse alloc] initWithEngine:self];
        [modules setObject:m forKey:@"simpleMouse"];
        
        animators = [NSMutableDictionary dictionary];
//        [animators setObject:[[PolyAnimatorSimplePushPop alloc] initWithEngine:self] forKey:@"polyAnimatorSimplePushPop"];
        [animators setObject:[[PolyAnimatorCracks alloc] initWithEngine:self] forKey:@"polyAnimatorCracks"];
     //   [animators setObject:[[PolyAnimatorSprings alloc] initWithEngine:self] forKey:@"polyAnimatorSprings"];
        
        [self didChangeValueForKey:@"allModulesTree"];
        
    }
    return self;
}

/*
 -(PolyRender*) getRenderer:(NSString*)renderer{
 return [renders objectForKey:renderer];
 }
 
 -(PolyInput*) getInput:(NSString*)renderer{
 return [inputs objectForKey:renderer];
 }
 
 -(PolyAnimator*) getAnimator:(NSString*)renderer{
 return [animators objectForKey:renderer];    
 }*/

-(NSArray*) allInputModules {
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"type = %i",PolyTypeInput];
    NSArray *arr = [[modules allValues] filteredArrayUsingPredicate:bPredicate];
    return arr;
}

-(NSArray*) allAnimatorModules {
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"type = %i",PolyTypeAnimator];
    NSArray *arr = [[modules allValues] filteredArrayUsingPredicate:bPredicate];
    return arr;
}

-(NSArray*) allRenderModules {
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"type = %i",PolyTypeRender];
    NSArray *arr = [[modules allValues] filteredArrayUsingPredicate:bPredicate];
    return arr;
}

-(NSArray *)allModulesTree{
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"Inputs",@"name",
                                  [NSDictionary dictionary], @"properties", nil];
    NSMutableArray * children = [NSMutableArray array];
    for(PolyModule * module in [self allInputModules] ){
        NSMutableDictionary * child = [NSMutableDictionary dictionary];
        [child setObject:module forKey:@"module"];
        [child setObject:NSStringFromClass([module class])  forKey:@"name"];
        [children addObject: child];
        
        //NSLog(@"%@", [[inputs objectForKey:module] properties]);
    }
    [dict setObject:children forKey:@"children"];
    [arr addObject:dict];
    
    
    dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            @"Animators",@"name",
            [NSDictionary dictionary], @"properties", nil];
    children = [NSMutableArray array];
    for(PolyModule * module in [self allAnimatorModules]){
        NSMutableDictionary * child = [NSMutableDictionary dictionary];
        [child setObject:module forKey:@"module"];
        [child setObject:NSStringFromClass([module class])  forKey:@"name"];
        [children addObject: child];
    }
    [dict setObject:children forKey:@"children"];
    [arr addObject:dict];
    
    
    dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            @"Renders",@"name",
            [NSDictionary dictionary], @"properties", nil];
    children = [NSMutableArray array];
    for(PolyModule * module in [self allRenderModules]){
        NSMutableDictionary * child = [NSMutableDictionary dictionary];
        [child setObject:module forKey:@"module"];
        [child setObject:NSStringFromClass([module class])  forKey:@"name"];
        [children addObject: child];
    }
    [dict setObject:children forKey:@"children"];
    [arr addObject:dict];
    
    
    
    return arr;
    
}

-(NSArray*) allSceneTokens {
    NSMutableArray * tokens = [NSMutableArray array];
    for(PolyModule * module in [modules allValues]){
        for(PolyNumberProperty * prop in [[module valueForKey:@"properties"] allValues]){
            for(NSString * tok in [prop sceneTokens]){
                if(![tokens containsObject:tok ]){
                    [tokens addObject:tok];
                }                    
            }
        }
    }
    return tokens;
}



#pragma mark --



- (void) setup{
    for(PolyModule * module in [modules allValues]){
        [module setup];
    }        
}
- (void) draw:(NSDictionary*)drawingInformation{
    for(PolyModule * module in [modules allValues]){
        [module draw:drawingInformation];
    }        
}
- (void) update:(NSDictionary*)drawingInformation{
    for(PolyModule * module in [modules allValues]){
        [module update:drawingInformation];
    }        
}

- (void) controlDraw:(NSDictionary*)drawingInformation{
    for(PolyModule * module in [modules allValues]){
        [module controlDraw:drawingInformation];
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
    for(PolyModule * module in [modules allValues]){
        [module  controlMousePressed:x y:y button:button];
    }   
}

- (void) controlMouseReleased:(float) x y:(float)y{
    for(PolyModule * module in [modules allValues]){
        [module controlMouseReleased:x y:y];
        
    }   
}
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button{
    for(PolyModule * module in [modules allValues]){
        [module controlMouseDragged:x y:y button:button];
        
    }   
}
//- (void) controlMouseScrolled:(NSEvent *)theEvent;

- (void) controlKeyPressed:(int)key modifier:(int)modifier{
    for(PolyModule * module in [modules allValues]){
        [module controlKeyPressed:key modifier:modifier];       
    }   
}

//- (void) controlKeyReleased:(int)key modifier:(int)modifier;

@end
