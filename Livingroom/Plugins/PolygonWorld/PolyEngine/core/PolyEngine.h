//#import "PolyInclude.h"
#import "lrAppDelegate.h"
#import <Foundation/Foundation.h>


@class PolyData;
@class PolyRender, PolyInput, PolyAnimator;

@interface PolyEngine : NSObject{
    NSMutableDictionary * renders;
    NSMutableDictionary * animators;
    NSMutableDictionary * inputs;
    
    PolyData * data;
}

-(PolyRender*) getRenderer:(NSString*)renderer;
-(PolyInput*) getInput:(NSString*)renderer;
-(PolyAnimator*) getAnimator:(NSString*)renderer;

@property (readonly) PolyData * data;



- (void) setup;
- (void) draw:(NSDictionary*)drawingInformation;
- (void) update:(NSDictionary*)drawingInformation;
- (void) controlDraw:(NSDictionary*)drawingInformation;

- (void) controlMouseMoved:(float) x y:(float)y;
- (void) controlMousePressed:(float) x y:(float)y button:(int)button;
- (void) controlMouseReleased:(float) x y:(float)y;
- (void) controlMouseDragged:(float) x y:(float)y button:(int)button;
- (void) controlMouseScrolled:(NSEvent *)theEvent;
- (void) controlKeyPressed:(int)key modifier:(int)modifier;
- (void) controlKeyReleased:(int)key modifier:(int)modifier;

@end
