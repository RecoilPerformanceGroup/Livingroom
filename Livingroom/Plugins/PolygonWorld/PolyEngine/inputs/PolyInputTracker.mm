#import "PolyInputTracker.h"
#import "OSCControl.h"

@implementation PolyInputTracker

- (vector<ofVec2f>) getTrackerCoordinates{
    vector<ofVec2f> v;
    if(mousePressed){
        v.push_back(mouse);
    } else {
        vector<ofVec2f> osc = [GetPlugin(OSCControl) getTrackerCoordinates];
        v.assign(osc.begin(), osc.end());
    }
       
    return v;
}

- (void) controlMousePressed:(float) x y:(float)y button:(int)button{
    mousePressed = YES;
    mouse = ofVec2f(x,y);    
}

- (void) controlMouseMoved:(float) x y:(float)y{
    mouse = ofVec2f(x,y);    
}

- (void) controlMouseReleased:(float) x y:(float)y{
    mousePressed = NO;
}

-(void)controlMouseDragged:(float)x y:(float)y button:(int)button{
    mouse = ofVec2f(x,y);
}

@end
