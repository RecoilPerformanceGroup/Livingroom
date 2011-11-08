//
//  PolyInput.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <ofxCocoaPlugins/Plugin.h>
#import <Foundation/Foundation.h>

@class PolyEngine;
@interface PolyInput : NSObject{
    PolyEngine * engine;
}


-(id) initWithEngine:(PolyEngine*)engine;

-(void)controlDraw:(NSDictionary *)drawingInformation;

- (void) controlMousePressed:(float) x y:(float)y button:(int)button;

@end

