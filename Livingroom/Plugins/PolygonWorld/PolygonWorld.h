#pragma once

#import <ofxCocoaPlugins/Plugin.h>
#import "MGScopeBarDelegateProtocol.h"

@class PolyEngine;

@interface PolygonWorld : ofPlugin  <MGScopeBarDelegate> {
    
    int cW,cH;
    float cMouseX,cMouseY;
    
    PolyEngine * polyEngine;
    
    IBOutlet MGScopeBar *scopeBar;
	NSMutableArray *groups;

}
- (IBAction)saveArrangement:(id)sender;
- (IBAction)loadArrangement:(id)sender;

@property(retain) NSMutableArray *groups;

@end
