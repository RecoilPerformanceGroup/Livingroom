//
//  PolyModule.h
//  Livingroom
//
//  Created by Livingroom on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "PolyEngine.h"

#import <Foundation/Foundation.h>

@interface PolyModule : NSObject


- (id) initWithEngine:(PolyEngine*)engine;

- (void) controlDraw:(NSDictionary *)drawingInformation;
- (void) update:(NSDictionary *)drawingInformation;
- (void) controlMousePressed:(float) x y:(float)y button:(int)button;
- (void) controlMouseReleased:(float) x y:(float)y;
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button;

- (void) controlKeyPressed:(int)key modifier:(int)modifier;

@end
