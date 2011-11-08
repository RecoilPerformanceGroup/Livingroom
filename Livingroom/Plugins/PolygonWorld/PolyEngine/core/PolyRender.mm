//
//  PolyRender.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyRender.h"

@implementation PolyRender

-(id) initWithEngine:(PolyEngine*)_engine{
    if(self = [self init]){
        engine = _engine;
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
