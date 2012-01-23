//
//  PolyNumberProperty.m
//  Livingroom
//
//  Created by Livingroom on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyNumberProperty.h"

@implementation PolyNumberProperty
@synthesize sceneTokens, sortNumber;

-(id) init{
    if(self = [super init]){
        sceneTokens = [[NSMutableArray alloc] init]; 

    }
    return self;
}


-(void) encodeWithCoder:(NSCoder *)coder{
	[super encodeWithCoder:coder];
	[coder encodeObject:sceneTokens forKey:@"sceneTokens"];
	
}

-(id) initWithCoder:(NSCoder *)coder{
	[super initWithCoder:coder];
	
	sceneTokens = [coder decodeObjectForKey:@"sceneTokens"];
	
	return self;
	
}


@end
