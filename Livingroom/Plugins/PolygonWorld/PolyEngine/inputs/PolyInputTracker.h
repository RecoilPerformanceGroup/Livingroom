
#import "PolyInput.h"

@interface PolyInputTracker : PolyInput{
    BOOL mousePressed;
    ofVec2f mouse;
}

- (vector< vector<ofVec2f> >) getTrackerCoordinates;
- (vector<ofVec2f>) getTrackerCoordinatesCentroids;
- (vector<ofVec2f>) getTrackerCoordinatesFeets;

@end
