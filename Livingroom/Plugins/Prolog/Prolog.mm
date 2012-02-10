#import "Prolog.h"
#import "Tracker.h"

@implementation Prolog

- (id)init{
    self = [super init];
    if (self) {
        [[self addPropF:@"circleSize"] setMaxValue:2];
        [[self addPropF:@"aspect"] setMaxValue:2];
        
        
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
    //    vector<ofVec2f> centroids = [GetPlugin(Tracker) trackerCentroidVector];
    if(surface == nil){
        surface = Surface(@"Floor", 0);
    }
    
    if([GetPlugin(Tracker) numberTrackers] > 0){
        ofVec2f centroid = [GetPlugin(Tracker) trackerCentroid:0];
        vector< ofVec2f > points = [GetPlugin(Tracker) trackerBlob:0];
        
        if(points.size() > 0){
            float highest=-1, lowest=-1;
            
            for(int i=0;i<points.size();i++){
                ofVec2f projp = [surface convertToProjection:points[i]];
                if(highest == -1 || projp.y > highest){
                    highest = projp.y;
                }
                if(lowest == -1 || projp.y < lowest){
                    lowest = projp.y;
                }
            }
            
            ofVec2f v = [surface convertToProjection:centroid];
            p.x = filterX.filter(v.x);
            p.y = filterY.filter(lowest+(highest-lowest)/2.0);
            size = filterSize.filter((highest-lowest));
        }
    }
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
//    ofVec2f s = [surface convertToProjection:p];
        ofVec2f s = p;
    ofFill();
    ofSetColor(255,255,255);
    
    ofEllipse(s.x*0.5, s.y, size*PropF(@"circleSize"), size*PropF(@"circleSize")*PropF(@"aspect"));
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
