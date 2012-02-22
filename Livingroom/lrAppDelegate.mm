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
#import "Tracker.h"
#import "Prolog.h"
#import "Mask.h"
#import "LEDGrid.h"

@implementation lrAppDelegate
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ocp = [[ofxCocoaPlugins alloc] initWithAppDelegate:self];
 //   [ocp setNumberOutputviews:0];
    
    [ocp addHeader:@"Setup"];
    
    [ocp addPlugin:[[Keystoner alloc] initWithSurfaces:[NSArray arrayWithObjects:@"Floor", @"Triangle", nil]] midiChannel:1];
    [ocp addPlugin:[[Cameras alloc] initWithNumberCameras:1] midiChannel:1];
    [ocp addPlugin:[[CameraCalibration alloc] init] midiChannel:1];
    [ocp addPlugin:[[BlobTracker2d alloc] init] midiChannel:1];

    [ocp addPlugin:[[Perspective alloc] init] midiChannel:2];
    [ocp addPlugin:[[OSCControl alloc] init] midiChannel:2];
    [ocp addPlugin:[[Midi alloc] init] midiChannel:2];
    [ocp addPlugin:[[OpenDMX alloc] init] midiChannel:2];

    [ocp addHeader:@"Scenes"];
   // [ocp addPlugin:[[AshParticles alloc] init] midiChannel:4];
    [ocp addPlugin:[[PolygonWorld alloc] init] midiChannel:10];
    [ocp addPlugin:[[Prolog alloc] init] midiChannel:5];
    [ocp addPlugin:[[Mask alloc] init] midiChannel:6];
    
    [ocp addPlugin:[[Tracker alloc] init] midiChannel:1];
    [ocp addPlugin:[[LEDGrid alloc] init] midiChannel:7];

  //  [ocp addHeader:@"MyPlugins"];
//    [ocp addPlugin:[[ExamplePlugin alloc] init]];
    
    [ocp loadPlugins];
}

@end
