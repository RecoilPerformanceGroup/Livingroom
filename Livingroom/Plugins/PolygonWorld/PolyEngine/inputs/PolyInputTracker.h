
#import "PolyInput.h"

@interface PolyInputTracker : PolyInput{
    BOOL mousePressed;
    ofVec2f mouse;
}

- (vector<ofVec2f>) getTrackerCoordinates;

@end
