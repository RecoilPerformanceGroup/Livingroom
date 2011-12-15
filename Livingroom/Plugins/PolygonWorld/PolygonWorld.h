#pragma once

#import <ofxCocoaPlugins/Plugin.h>
#import "MGScopeBarDelegateProtocol.h"

@class PolyEngine, PolyModule;

@interface PolygonWorld : ofPlugin  <MGScopeBarDelegate, NSTableViewDelegate> {
    
    int cW,cH;
    float cMouseX,cMouseY;
    
    PolyEngine * polyEngine;
    NSOutlineView *modulesOutlineview;
    NSTreeController *modulesTreeController;
    NSDictionaryController *propertiesDictController;
	NSMutableArray *groups;
    
    NSMutableSet * selectedTokens;
    
    int mouseMode;
    NSView *moduleView;
    
    IBOutlet MGScopeBar *scopeBar;
}

@property (readonly) PolyEngine * polyEngine;
@property (assign) IBOutlet NSOutlineView *modulesOutlineview;
@property (assign) IBOutlet NSTreeController *modulesTreeController;
@property (assign) IBOutlet NSDictionaryController *propertiesDictController;
@property (readonly) NSArray * propertiesSortDescriptor;
@property (readwrite) int mouseMode;
@property (assign) IBOutlet NSView *moduleView;

- (IBAction)saveArrangement:(id)sender;
- (IBAction)loadArrangement:(id)sender;
- (IBAction)clearArrangement:(id)sender;
- (IBAction)setSceneTokens:(id)sender;

- (PolyModule*) selectedModule;
- (PolyModule*) moduleForMouseMode;

@property(retain) NSMutableArray *groups;

@end
