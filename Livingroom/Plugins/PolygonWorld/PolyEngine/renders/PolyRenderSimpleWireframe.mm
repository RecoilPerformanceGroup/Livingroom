//
//  PolyRenderSimpleWireframe.m
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyRenderSimpleWireframe.h"
@implementation PolyRenderSimpleWireframe

-(void)controlDraw:(NSDictionary *)drawingInformation{
    ofSetColor(255,255,255);
    ofRect(0,0,1,1);
}

@end
