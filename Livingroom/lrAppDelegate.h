//
//  lrAppDelegate.h
//  Livingroom
//
//  Created by Livingroom on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyInclude.h"

#import <ofxCocoaPlugins/ofxCocoaPlugins.h>
#import <Cocoa/Cocoa.h>

@interface lrAppDelegate : NSObject <NSApplicationDelegate>{
    ofxCocoaPlugins *ocp;
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
