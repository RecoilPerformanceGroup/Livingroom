//
//  PolyAnimator.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyEngine.h"

#import <ofxCocoaPlugins/Plugin.h>
#import <Foundation/Foundation.h>

@interface PolyAnimator : NSObject{
    PolyEngine * engine;
}

-(id) initWithEngine:(PolyEngine*)engine;
-(void)controlDraw:(NSDictionary *)drawingInformation;
-(void)draw:(NSDictionary *)drawingInformation;
- (void)update:(NSDictionary *)drawingInformation;
- (void) controlMousePressed:(float) x y:(float)y button:(int)button;
- (void) controlMouseReleased:(float) x y:(float)y;
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button;

@end
