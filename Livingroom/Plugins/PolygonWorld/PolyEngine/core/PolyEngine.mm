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

#import "PolyInputSimpleMouseDraw.h"
#import "PolyInputTracker.h"

#import "PolyAnimatorSimplePushPop.h"
#import "PolyAnimatorSprings.h"
#import "PolyAnimatorCracks.h"
#import "PolyAnimatorCrumble.h"

@implementation PolyEngine
@synthesize arrangement, modules;

-(id)init {
    if(self = [super init]){
        [self willChangeValueForKey:@"allModulesTree"];
        
        arrangement = [[PolyArrangement alloc] init];
        
        modules = [NSMutableDictionary dictionary];

        //
        //Inputs
        //
        [self addModule:@"PolyInputSimpleMouseDraw"];
        [self addModule:@"PolyInputTracker"];

        //
        //Animators
        //   
        [self addModule:@"PolyAnimatorCracks"];
     //   [self addModule:@"PolyAnimatorSprings"];
        [self addModule:@"PolyAnimatorCrumble"];

        //
        //Renders
        //
        [self addModule:@"PolyRenderSimpleWireframe"];
        
        

        [self didChangeValueForKey:@"allModulesTree"];
        
    }
    return self;
}

-(PolyModule*) addModule:(NSString*)module{
    PolyModule * m = [[NSClassFromString(module) alloc] initWithEngine:self];
    NSAssert1(m != nil, @"No class named %@",module);
    NSString * name = [module stringByReplacingOccurrencesOfString:@"PolyInput" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"PolyAnimator" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"PolyRender" withString:@""];
    [m setKey:name];    
    [modules setObject:m forKey:name];    
 
    return m;
}


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
        [child setObject:[module key]  forKey:@"name"];
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
        [child setObject:[module key]  forKey:@"name"];
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
        [child setObject:[module key]  forKey:@"name"];
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
   /* for(PolyModule * module in [modules allValues]){
        [module controlDraw:drawingInformation];
    }*/   
}

- (void) controlMouseMoved:(float) x y:(float)y {
   /* for(PolyModule * module in [modules allValues]){
        [module controlMouseMoved:x y:y];
    }  */ 
}

- (void) controlMousePressed:(float) x y:(float)y button:(int)button{
/*    for(PolyModule * module in [modules allValues]){
        [module  controlMousePressed:x y:y button:button];
    }   */
}

- (void) controlMouseReleased:(float) x y:(float)y{
/*    for(PolyModule * module in [modules allValues]){
        [module controlMouseReleased:x y:y];
        
    }   */
}
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button{
/*    for(PolyModule * module in [modules allValues]){
        [module controlMouseDragged:x y:y button:button];
        
    }   */
}

- (void) controlMouseScrolled:(NSEvent *)theEvent{}

- (void) controlKeyPressed:(int)key modifier:(int)modifier{
/*    for(PolyModule * module in [modules allValues]){
        [module controlKeyPressed:key modifier:modifier];       
    }   */
}

- (void) controlKeyReleased:(int)key modifier:(int)modifier{}

@end
