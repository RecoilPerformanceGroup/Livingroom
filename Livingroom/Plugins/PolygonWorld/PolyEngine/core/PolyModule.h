//
//  PolyModule.h
//  Livingroom
//
//  Created by Livingroom on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "PolyEngine.h"

#import <Foundation/Foundation.h>
#import "PolyNumberProperty.h"

// Selection modes for the buttons within a group.
typedef enum _PolyModuleType {
    PolyTypeInput,
    PolyTypeRender,
    PolyTypeAnimator
} PolyModuleType;


@interface PolyModule : NSObject  <NSCoding>  {
    NSMutableDictionary * properties;
    
    PolyEngine * engine;
    
    PolyModuleType type;
    
    NSString * key;
    
}

@property (readonly) NSMutableDictionary * properties;
@property (readonly) PolyModuleType type;
@property (readwrite, retain)     NSString * key;


- (id) initWithEngine:(PolyEngine*)engine;

- (void) setup;
- (void) draw:(NSDictionary *)drawingInformation;
- (void) controlDraw:(NSDictionary *)drawingInformation;
- (void) update:(NSDictionary *)drawingInformation;
- (void) controlMousePressed:(float) x y:(float)y button:(int)button;
- (void) controlMouseReleased:(float) x y:(float)y;
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button;

- (void) controlKeyPressed:(int)key modifier:(int)modifier;


-(PolyNumberProperty*) addPropF:(NSString*)name;

@end


