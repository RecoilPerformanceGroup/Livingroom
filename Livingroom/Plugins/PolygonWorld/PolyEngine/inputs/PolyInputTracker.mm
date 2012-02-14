#import "PolyInputTracker.h"
#import "Tracker.h"

@implementation PolyInputTracker

- (vector< vector<ofVec2f> >) getTrackerCoordinates{
    vector< vector<ofVec2f> > v;
    if(mousePressed){
        vector< ofVec2f > v2;
        v2.push_back( mouse);
        v.push_back(v2);
    } else {
        vector< vector<ofVec2f> > osc = [GetPlugin(Tracker) trackerBlobVector];
        return osc;
    }
       
    return v;
}


- (vector<ofVec2f>) getTrackerCoordinatesCentroids{
    vector< ofVec2f > v;
    if(mousePressed){
        v.push_back( mouse);
    } else {
        vector<ofVec2f> osc = [GetPlugin(Tracker) trackerCentroidVector];
        return osc;
    }
    
    return v;
}

- (vector<ofVec2f>) getTrackerCoordinatesFeets{
    vector< ofVec2f > v;
    if(mousePressed){
        v.push_back( mouse);
    } else {
        vector<ofVec2f> osc = [GetPlugin(Tracker) trackerFeetVector];
        return osc;
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
