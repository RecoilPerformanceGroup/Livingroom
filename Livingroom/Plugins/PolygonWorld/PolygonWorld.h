#pragma once

#import <ofxCocoaPlugins/Plugin.h>
#import "MGScopeBarDelegateProtocol.h"

@class PolyEngine;

@interface PolygonWorld : ofPlugin  <MGScopeBarDelegate, NSTableViewDelegate> {
    
    int cW,cH;
    float cMouseX,cMouseY;
    
    PolyEngine * polyEngine;
    NSOutlineView *modulesOutlineview;
    NSTreeController *modulesTreeController;
    NSDictionaryController *propertiesDictController;
    IBOutlet MGScopeBar *scopeBar;
	NSMutableArray *groups;
    
    NSMutableSet * selectedTokens;
}

@property (readonly) PolyEngine * polyEngine;
@property (assign) IBOutlet NSOutlineView *modulesOutlineview;
@property (assign) IBOutlet NSTreeController *modulesTreeController;
@property (assign) IBOutlet NSDictionaryController *propertiesDictController;

- (IBAction)saveArrangement:(id)sender;
- (IBAction)loadArrangement:(id)sender;
- (IBAction)setSceneTokens:(id)sender;

@property(retain) NSMutableArray *groups;

@end
