//
//  PolyModule.m
//  Livingroom
//
//  Created by Livingroom on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyModule.h"

@implementation PolyModule
@synthesize properties;


-(id) initWithEngine:(PolyEngine*)_engine{
    if(self = [self init]){
        engine = _engine;
    
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
    [p setMaxValue:1];
    [properties setObject:p forKey:name];
    return p;
}

-(void) encodeWithCoder:(NSCoder *)coder{
	[super encodeWithCoder:coder];
	[coder encodeObject:properties forKey:@"properties"];
}

-(id) initWithCoder:(NSCoder *)coder{
	[super initWithCoder:coder];
	
	properties = [coder decodeObjectForKey:@"properties"];
	
	return self;
	
}

@end
