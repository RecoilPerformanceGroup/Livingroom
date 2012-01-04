//
//  lrAppDelegate.m
//  Livingroom
//
//  Created by Livingroom on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "lrAppDelegate.h"

#import "PolygonWorld.h"
#import "Perspective.h"
#import "OSCControl.h"
#import "AshParticles.h"

@implementation lrAppDelegate
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ocp = [[ofxCocoaPlugins alloc] initWithAppDelegate:self];
    [ocp addHeader:@"Setup"];
    
    [ocp addPlugin:[[Keystoner alloc] initWithSurfaces:[NSArray arrayWithObjects:@"Floor", @"Triangle", nil]]];
    [ocp addPlugin:[[Perspective alloc] init]];
    [ocp addPlugin:[[OSCControl alloc] init]];
    [ocp addPlugin:[[Cameras alloc] initWithNumberCameras:2]];
    [ocp addHeader:@"Scenes"];
    [ocp addPlugin:[[PolygonWorld alloc] init]];
    [ocp addPlugin:[[AshParticles alloc] init]];
  //  [ocp addHeader:@"MyPlugins"];
//    [ocp addPlugin:[[ExamplePlugin alloc] init]];
    
    [ocp loadPlugins];
}

@end
