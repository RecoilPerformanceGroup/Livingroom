#import "Tracker.h"
#import "OSCControl.h"
#import <ofxCocoaPlugins/BlobTracker2d.h>

@implementation Tracker

- (id)init{
    self = [super init];
    if (self) {
        controlMouse = ofVec2f(-1,-1);
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
//    cout<<[self numberTrackers]<<endl;
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{ 
    ofBackground(0,0,0);
    
    int n = [self numberTrackers];

    ofSetColor(255,255,255);
    int w = ofGetWidth();
    int h = ofGetHeight();
    for(int i=0; i<n;i++){
        ofVec2f centroid = [self trackerCentroid:i];
        ofRect(centroid.x*w-10, centroid.y*h-10, 20, 20);
    }
}


-(int) numberTrackers{
    int num = 0;
    
    // OSC Control blobs
    {
        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        num += blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            num ++;
        }
    }
    
    // Camera tracker
    if(num == 0){
        num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
    }
    
    return num;
}

-(ofVec2f) trackerCentroid:(int)n{
    // OSC Control blobs
    {
        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        if(blobs.size() > n){
            return blobs[n];
        }
        n -= blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            if(n == 0){
                return controlMouse;
            }
            n --;            
        }

    }
    
    // Camera tracker
    {
        int num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
        if(num > n){
            return *[[GetPlugin(BlobTracker2d) getInstance:0] getPBlob:n]->centroid;
        }
        n -= num;
    }
    
    return ofVec2f();
}

-(vector<ofVec2f>) trackerCentroidVector{
    int n = [self numberTrackers];
    vector<ofVec2f> v;
    for(int i=0; i<n;i++){
        v.push_back([self trackerCentroid:i]);
    }
    return v;
}

@end
