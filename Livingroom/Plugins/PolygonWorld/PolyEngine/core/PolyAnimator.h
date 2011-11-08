//
//  PolyAnimator.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <ofxCocoaPlugins/Plugin.h>
#import <Foundation/Foundation.h>

@class PolyEngine;
@interface PolyAnimator : NSObject{
    PolyEngine * engine;
}

-(id) initWithEngine:(PolyEngine*)engine;
-(void)controlDraw:(NSDictionary *)drawingInformation;

@end
