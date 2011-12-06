#pragma once

#import <ofxCocoaPlugins/Plugin.h>
#import "MGScopeBarDelegateProtocol.h"

@class PolyEngine;

@interface PolygonWorld : ofPlugin  <MGScopeBarDelegate> {
    
    int cW,cH;
    float cMouseX,cMouseY;
    
    PolyEngine * polyEngine;
    NSOutlineView *modulesOutlineview;
    IBOutlet MGScopeBar *scopeBar;
	NSMutableArray *groups;
}

@property (readonly) PolyEngine * polyEngine;
@property (assign) IBOutlet NSOutlineView *modulesOutlineview;

- (IBAction)saveArrangement:(id)sender;
- (IBAction)loadArrangement:(id)sender;

@property(retain) NSMutableArray *groups;

@end
