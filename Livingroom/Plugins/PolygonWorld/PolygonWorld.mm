#import "PolyEngine.h"
#import "PolyModule.h"
#import "PolygonWorld.h"
#import <ofxCocoaPlugins/Keystoner.h>


#import "MGScopeBar.h"

// Keys for our sample data.
#define GROUP_LABEL				@"Label"			// string
#define GROUP_SEPARATOR			@"HasSeparator"		// BOOL as NSNumber
#define GROUP_SELECTION_MODE	@"SelectionMode"	// MGScopeBarGroupSelectionMode (int) as NSNumber
#define GROUP_ITEMS				@"Items"			// array of dictionaries, each containing the following keys:
#define ITEM_IDENTIFIER			@"Identifier"		// string
#define ITEM_NAME				@"Name"				// string


@implementation PolygonWorld
@synthesize polyEngine;
@synthesize modulesOutlineview;
@synthesize modulesTreeController;
@synthesize propertiesDictController;
@synthesize mouseMode;

- (void)awakeFromNib
{
    
    //[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints];
	// In this method we basically just set up some sample data for the scope bar, 
	// so that we can respond to the MGScopeBarDelegate methods easily.
	
	self.groups = [NSMutableArray arrayWithCapacity:0];
	scopeBar.delegate = self;
	
    
	// Add third group of items.
	/*items = [NSArray arrayWithObjects:
     [NSDictionary dictionaryWithObjectsAndKeys:
     @"AllFilesItem", ITEM_IDENTIFIER, 
     @"All Files", ITEM_NAME, 
     nil], 
     [NSDictionary dictionaryWithObjectsAndKeys:
     @"ImagesOnlyItem", ITEM_IDENTIFIER, 
     @"Images Only", ITEM_NAME, 
     nil], 
     nil];
     
     [self.groups addObject:[NSDictionary dictionaryWithObjectsAndKeys:
     @"Kind:", GROUP_LABEL, 
     [NSNumber numberWithBool:YES], GROUP_SEPARATOR, 
     [NSNumber numberWithInt:MGRadioSelectionMode], GROUP_SELECTION_MODE, // single selection group.
     items, GROUP_ITEMS, 
     nil]];
     */
	// Tell the scope bar to ask us for data (since we're the scope-bar's delegate).
	[scopeBar reloadData];
	
	// Since our first group is a radio-mode group, the scope bar will automatically select its first item.
	// The scope bar will take care of deselecting other items when you select a new item in a radio-mode group.
	
	// We'll also select the first item in our second group, which is a multiple-selection group.
	// You can (and must) use this method to programmatically select/deselect items in the bar.
    //	[scopeBar setSelected:YES forItem:@"ContentsItem" inGroup:1]; // remember that group-numbers are zero-based.
    
    
    
    //Outline view
    [modulesOutlineview expandItem:nil expandChildren:YES];
    
    //Tree controller
    [modulesTreeController addObserver:self forKeyPath:@"selection" options:nil context:nil];
    
	
    //  [propertiesDictController addObserver:self forKeyPath:@"arrangedObjects.value.sceneTokens" options:nil context:nil];
}




- (id)init{
    self = [super init];
    if (self) {
        polyEngine = [[PolyEngine alloc] init];
        selectedTokens = [NSMutableSet set];
    }
    
    return self;
}

-(void)draw:(NSDictionary *)drawingInformation{
    ofBackground(0, 0, 0);
    [polyEngine draw:drawingInformation];
    
    ofColor(255,0,0,255);
    ofCircle(cMouseX, cMouseY, 0.01);
    
}

-(void)update:(NSDictionary *)drawingInformation{
    [polyEngine update:drawingInformation];
    
}

-(void)controlDraw:(NSDictionary *)drawingInformation{    
    ofBackground(0, 0, 0);
    ofSetColor(0,0,0);
    glPushMatrix(); {        
        
        cW = ofGetWidth();
        cH = ofGetHeight();
        glScaled(cW, cH,1);

        [[[polyEngine modules] objectForKey:@"SimpleWireframe"] controlDraw:drawingInformation];
        [[self selectedModule] controlDraw:drawingInformation];
        [polyEngine controlDraw:drawingInformation];
        
        [[self moduleForMouseMode]  controlDraw:drawingInformation];

        
    } glPopMatrix();
    
}

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    [polyEngine controlMousePressed:x/cW y:y/cH button:button];
    
    if(![[self selectedModule] isInput]){
        [[self selectedModule] controlMousePressed:x/cW y:y/cH button:button];
    }
    
    [[self moduleForMouseMode]controlMousePressed:x/cW y:y/cH button:button];
    
}
-(void)controlMouseReleased:(float)x y:(float)y{
    [polyEngine controlMouseReleased:x/cW y:y/cH];
    
    if(![[self selectedModule] isInput]){
        [[self selectedModule] controlMouseReleased:x/cW y:y/cH];
    }
    
   [[self moduleForMouseMode] controlMouseReleased:x/cW y:y/cH];

}

-(void)controlKeyPressed:(int)key modifier:(int)modifier{
    [polyEngine controlKeyPressed:key modifier:modifier];
    if(![[self selectedModule] isInput]){
        [[self selectedModule] controlKeyPressed:key modifier:modifier];
    }
    
    [[self moduleForMouseMode] controlKeyPressed:key modifier:modifier];
}

-(void)controlMouseMoved:(float)x y:(float)y {
    
    [polyEngine controlMouseMoved:x/cW y:y/cH];
    if(![[self selectedModule] isInput]){
        [[self selectedModule] controlMouseMoved:x/cW y:y/cH];
    }
    
    [[self moduleForMouseMode] controlMouseMoved:x/cW y:y/cH];
    
    
    x /= cW;
    y /= cH;
    
    cMouseX = x;
    cMouseY = y;
    
}

-(void)controlMouseDragged:(float)x y:(float)y button:(int)button {
    
    [polyEngine controlMouseDragged:x/cW y:y/cH button:button];
    if(![[self selectedModule] isInput]){
        [[self selectedModule] controlMouseDragged:x/cW y:y/cH button:button];
    }
    
    [[self moduleForMouseMode] controlMouseDragged:x/cW y:y/cH button:button];
    
    x /= cW;
    y /= cH;
    
    cMouseX = x;
    cMouseY = y;
}

- (PolyModule*) moduleForMouseMode{
    if(mouseMode == 0){
       return [[polyEngine modules] objectForKey:@"Tracker"];
    }
    if(mouseMode == 1){
       return [[polyEngine modules] objectForKey:@"SimpleMouseDraw"];
    }
    return nil;
}

-(NSMutableDictionary *)customProperties{
    NSMutableDictionary * props = customProperties;
    NSMutableArray * arr = [NSMutableArray array];
    [props setValue:arr forKey:@"modules"];
    //	[customProperties setObject:[polyEngine allModules] forKey:@"modules"];
    //    	[customProperties setObject:[polyEngine allModules] forKey:@"modules"];
    
    for(NSString * moduleName in [[polyEngine modules] allKeys]){
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setValue:moduleName forKey:@"key"];
        [dict setValue:[[[polyEngine modules] objectForKey:moduleName] properties] forKey:@"properties"];
        
        [arr addObject:dict];
    }
    
    return props;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([(NSString*)context isEqualToString:@"customProperties"]){
		NSArray * modulesArray = [customProperties objectForKey:@"modules"];
        if(modulesArray != nil){
            for(NSDictionary * moduleDict in modulesArray){
                PolyModule * module = [[polyEngine modules]objectForKey:[moduleDict valueForKey:@"key"]];
                if(module != nil){
                    for(NSString * propKey in [[moduleDict objectForKey:@"properties"] allKeys]){
                        PolyNumberProperty * savedProp = [[moduleDict objectForKey:@"properties"] objectForKey:propKey];
                        PolyNumberProperty * prop = [[module properties] objectForKey:propKey];
                        if(prop != nil){
                            [prop setValue:[savedProp valueForKey:@"value"] forKey:@"value"];
                            [prop setValue:[savedProp valueForKey:@"sceneTokens"] forKey:@"sceneTokens"];
                            [prop setValue:[savedProp valueForKey:@"minValue"] forKey:@"minValue"];
                            [prop setValue:[savedProp valueForKey:@"maxValue"] forKey:@"maxValue"];
                        }
                    }
                }
            }
            [self setSceneTokens:self];
            
        }
        
    }
    //   NSLog(@"object %@",[[modulesTreeController selectedObjects] objectAtIndex:0] );
    
    //  NSLog(@"tokens: %@",  [polyEngine allSceneTokens]);
    
}

- (IBAction)saveArrangement:(id)sender {
    [[polyEngine arrangement] saveArrangement];
}

- (IBAction)loadArrangement:(id)sender {
    [[globalController openglLock] lock];
    [[polyEngine arrangement] loadArrangement];
    [[globalController openglLock] unlock];
}

- (IBAction)clearArrangement:(id)sender {
    [[globalController openglLock] lock];
    [[polyEngine arrangement] clearArrangement];
    [[globalController openglLock] unlock];
}

- (IBAction)setSceneTokens:(id)sender {
    [self.groups removeAllObjects];
    
    
    // Add first group of items.
	NSMutableArray *items = [NSMutableArray array];	
	// Add second group of items.
    
    for(NSString * tok in [polyEngine allSceneTokens]){
        [items addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                           tok, ITEM_IDENTIFIER, 
                           tok, ITEM_NAME, 
                           nil]];
    }
    
    if([items count]> 0){
        [self.groups addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                // deliberately not specifying a label
                                [NSNumber numberWithBool:NO], GROUP_SEPARATOR, 
                                [NSNumber numberWithInt:MGMultipleSelectionMode], GROUP_SELECTION_MODE, // multiple selection group.
                                items, GROUP_ITEMS, 
                                nil]];
    }
    [scopeBar reloadData];
    
	
}


#pragma mark MGScopeBarDelegate methods


- (int)numberOfGroupsInScopeBar:(MGScopeBar *)theScopeBar
{
	return [self.groups count];
}


- (NSArray *)scopeBar:(MGScopeBar *)theScopeBar itemIdentifiersForGroup:(int)groupNumber
{
	return [[self.groups objectAtIndex:groupNumber] valueForKeyPath:[NSString stringWithFormat:@"%@.%@", GROUP_ITEMS, ITEM_IDENTIFIER]];
}


- (NSString *)scopeBar:(MGScopeBar *)theScopeBar labelForGroup:(int)groupNumber
{
	return [[self.groups objectAtIndex:groupNumber] objectForKey:GROUP_LABEL]; // might be nil, which is fine (nil means no label).
}


- (NSString *)scopeBar:(MGScopeBar *)theScopeBar titleOfItem:(NSString *)identifier inGroup:(int)groupNumber
{
	NSArray *items = [[self.groups objectAtIndex:groupNumber] objectForKey:GROUP_ITEMS];
	if (items) {
		// We'll iterate here, since this is just a demo. This avoids having to keep an NSDictionary of identifiers 
		// for each group as well as an array for ordering. In a more realistic scenario, you'd probably want to be 
		// able to look-up an item by its identifier in constant time.
		for (NSDictionary *item in items) {
			if ([[item objectForKey:ITEM_IDENTIFIER] isEqualToString:identifier]) {
				return [item objectForKey:ITEM_NAME];
				break;
			}
		}
	}
	return nil;
}


- (MGScopeBarGroupSelectionMode)scopeBar:(MGScopeBar *)theScopeBar selectionModeForGroup:(int)groupNumber
{
	return (MGScopeBarGroupSelectionMode)[[[self.groups objectAtIndex:groupNumber] objectForKey:GROUP_SELECTION_MODE] intValue];
}


- (BOOL)scopeBar:(MGScopeBar *)theScopeBar showSeparatorBeforeGroup:(int)groupNumber
{
	// Optional method. If not implemented, all groups except the first will have a separator before them.
	return [[[self.groups objectAtIndex:groupNumber] objectForKey:GROUP_SEPARATOR] boolValue];
}


- (NSImage *)scopeBar:(MGScopeBar *)scopeBar imageForItem:(NSString *)identifier inGroup:(int)groupNumber
{
    return nil;
	// Optional method. If not implemented (or if you return nil), items will not have an image.
	if (groupNumber == 0) {
		return [NSImage imageNamed:@"NSComputer"];
		
	} else if (groupNumber == 2) {
		if ([identifier isEqualToString:@"AllFilesItem"]) {
			return [NSImage imageNamed:@"NSGenericDocument"];
			
		} else if ([identifier isEqualToString:@"ImagesOnlyItem"]) {
			return [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
		}
	}
	
	return nil;
}


- (void)scopeBar:(MGScopeBar *)theScopeBar selectedStateChanged:(BOOL)selected 
		 forItem:(NSString *)identifier inGroup:(int)groupNumber
{
    if(selected){
        [selectedTokens addObject:identifier];
    } else {
        [selectedTokens removeObject:identifier];
    }
    if([selectedTokens count] > 0){
        [propertiesDictController setFilterPredicate:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY value.sceneTokens in %@", selectedTokens];    
        [propertiesDictController setFilterPredicate:predicate];
        //        [modulesTreeController fetch:self];
    } else {
        [propertiesDictController setFilterPredicate:nil];
    }
    
}

#pragma mark Tableview

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    if([[tableColumn identifier] isEqualToString:@"val"]){
        id property = [[[propertiesDictController arrangedObjects] objectAtIndex:row] value];
        if([property isKindOfClass:[NumberProperty class]]){
            return [tableView makeViewWithIdentifier:@"slider" owner:self];
        }
        
        
        return [tableView makeViewWithIdentifier:@"textfield" owner:self];
    } else {
        return [tableView makeViewWithIdentifier:@"name" owner:self];
    }
}


#pragma mark Accessors and properties


@synthesize groups;

- (PolyModule*) selectedModule{
    return [[[modulesTreeController selectedObjects]objectAtIndex:0] valueForKey:@"module"]; 
}

- (NSArray *)propertiesSortDescriptor{
    NSSortDescriptor * ageDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"value.sortNumber"
                                                 ascending:YES] autorelease];
    return [NSArray arrayWithObject:ageDescriptor];
}

@end
