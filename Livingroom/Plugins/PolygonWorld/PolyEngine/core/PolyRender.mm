//
//  PolyRender.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyRender.h"

@implementation PolyRender

-(id)init{
    if(self = [super init]){
        type = PolyTypeRender;
    } 
    return self;
}

-(void)draw:(NSDictionary *)drawingInformation{
    
}
-(void)controlDraw:(NSDictionary *)drawingInformation{
}

-(void)update:(NSDictionary *)drawingInformation{
}

@end
