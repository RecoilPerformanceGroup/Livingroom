//
//  PolyModule.m
//  Livingroom
//
//  Created by Livingroom on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyModule.h"

@implementation PolyModule
@synthesize properties, type, key;


-(id) initWithEngine:(PolyEngine*)_engine{
    if(self = [self init]){
        engine = _engine;
        propertyCounter = 0;    
    } 
    return self;

}

-(id) init{
    if(self = [super init]){
        properties = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(PolyNumberProperty*) addPropF:(NSString*)name {
    PolyNumberProperty * p = [[PolyNumberProperty alloc] init];
    [p setFloatValue:0];
    [p setName:name];
    [p setMinValue:0];
    [p setMaxValue:1.0];
    [p setSortNumber:propertyCounter++];
    [properties setObject:p forKey:name];
    return p;
}

-(void) encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:properties forKey:@"properties"];
}

-(id) initWithCoder:(NSCoder *)coder{
	properties = [coder decodeObjectForKey:@"properties"];
	
	return self;
	
}


#pragma mark Empty Accesors

- (void) setup{}
- (void) draw:(NSDictionary *)drawingInformation{}
- (void) controlDraw:(NSDictionary *)drawingInformation{}
- (void) update:(NSDictionary *)drawingInformation{}
- (void) controlMousePressed:(float) x y:(float)y button:(int)button{}
- (void) controlMouseReleased:(float) x y:(float)y{}
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button{}
- (void) controlMouseMoved:(float) x y:(float)y{}
- (void) controlKeyPressed:(int)key modifier:(int)modifier{}

@end
