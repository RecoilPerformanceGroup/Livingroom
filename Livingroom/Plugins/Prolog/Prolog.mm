#import "Prolog.h"
#import "Tracker.h"
#import <ofxCocoaPlugins/Keystoner.h>

@implementation Prolog

- (id)init{
    self = [super init];
    if (self) {
        [[self addPropF:@"circleSize"] setMaxValue:0.1];
        
        [Prop(@"circleSize") setMidiSmoothing:0.1];
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
    ofSetCircleResolution(100);

}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    vector<ofVec2f> centroids = [GetPlugin(Tracker) trackerCentroidVector];
    
    if(centroids.size() > 0){
        ofVec2f v = centroids[0];
        p.x = filterX.filter(v.x);
        p.y = filterY.filter(v.y);
    }
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    KeystoneSurface * surface = Surface(@"Floor", 0);
    ofVec2f s = [surface convertToProjection:p];
    ofFill();
    ofSetColor(255,255,255);
    
    ofCircle(s.x*0.5, s.y, PropF(@"circleSize"));
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
