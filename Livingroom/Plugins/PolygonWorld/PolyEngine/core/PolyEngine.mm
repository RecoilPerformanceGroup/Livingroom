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
#import "PolyRenderCrackLines.h"
#import "PolyRenderLights.h"

#import "PolyInputSimpleMouseDraw.h"
#import "PolyInputTracker.h"
#import "PolyInputRandomGenerator.h"

#import "PolyAnimatorSimplePushPop.h"
#import "PolyAnimatorSprings.h"
#import "PolyAnimatorCracks.h"
#import "PolyAnimatorCrumble.h"
#import "PolyAnimatorPhysics.h"

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
        [self addModule:@"PolyInputRandomGenerator"];
        
        //
        //Animators
        //   
        [self addModule:@"PolyAnimatorCracks"];
        //   [self addModule:@"PolyAnimatorSprings"];
        [self addModule:@"PolyAnimatorCrumble"];
        [self addModule:@"PolyAnimatorPhysics"];
        [self addModule:@"PolyAnimatorGravity"];
        
        //
        //Renders
        //
        [self addModule:@"PolyRenderSimpleWireframe"];
        [self addModule:@"PolyRenderCrackLines"];
        [self addModule:@"PolyRenderLights"];

        
        [self didChangeValueForKey:@"allModulesTree"];
        
    }
    return self;
}

-(PolyModule*) addModule:(NSString*)module{
    NSString * name = [module stringByReplacingOccurrencesOfString:@"PolyInput" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"PolyAnimator" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"PolyRender" withString:@""];

    PolyModule * m = [[NSClassFromString(module) alloc] initWithEngine:self forKey:name];
    NSAssert1(m != nil, @"No class named %@",module);
//    [m setKey:name];    
    [modules setObject:m forKey:name];    
    
    return m;
}

-(PolyModule*) getModule:(NSString*)module{
    return [[self modules] objectForKey:module];
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
        [child setObject:[[module properties] objectForKey:@"active"]  forKey:@"active"];
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
        [child setObject:[[module properties] objectForKey:@"active"]  forKey:@"active"];
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
        [child setObject:[[module properties] objectForKey:@"active"]  forKey:@"active"];
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
        [module reset];
    }        
}
- (void) draw:(NSDictionary*)drawingInformation{
   ApplySurface(@"Floor"); {
        
        for(PolyModule * module in [modules allValues]){
            if([module active]){
                [module draw:drawingInformation];
            }
        }        
   } PopSurface();
}
- (void) update:(NSDictionary*)drawingInformation{
    for(PolyModule * module in [modules allValues]){
        for(PolyNumberProperty * prop in [[module properties] allValues]){
           // [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                [prop update];
            //}];
        }
        if([module active]){
            if([[[module properties] valueForKey:@"reset"] boolValue]){
                [[[module properties] valueForKey:@"reset"] setBoolValue:0];
                [module reset];
            }
            [module update:drawingInformation];
        }
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
