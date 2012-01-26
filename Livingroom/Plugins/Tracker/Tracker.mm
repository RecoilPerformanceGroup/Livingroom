#import "Tracker.h"
#import "OSCControl.h"
#import <ofxCocoaPlugins/BlobTracker2d.h>
#import <ofxCocoaPlugins/Keystoner.h>

@implementation Tracker

- (id)init{
    self = [super init];
    if (self) {
        controlMouse = ofVec2f(-1,-1);
        [[self addPropF:@"generatedBlobPoints"] setMinValue:1 maxValue:300];
        [[self addPropF:@"generatedBlobSize"] setMinValue:0.01 maxValue:1];

        [self addPropB:@"drawDebug"];
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
    if(PropB(@"drawDebug")){
        ApplySurface(@"Floor");
        
        int n = [self numberTrackers];

        
        for(int i=0; i<n;i++){
            ofVec2f centroid = [self trackerCentroid:i];
            
            ofSetColor(255,255,255);
            ofCircle(centroid.x, centroid.y, 0.01);
            
            
            switch (i) {
                case 0:
                    ofSetColor(255, 0, 0,255);
                    break;
                case 1:
                    ofSetColor(0, 255, 0,255);
                    break;
                case 2:
                    ofSetColor(0, 0, 255,255);
                    break;
                case 3:
                    ofSetColor(255, 255, 0,255);
                    break;
                case 4:
                    ofSetColor(0, 255, 255,255);
                    break;
                case 5:
                    ofSetColor(255, 0, 255,255);
                    break;
                    
                default:
                    ofSetColor(255, 255, 255,255);
                    break;
            }
            
            
            vector< ofVec2f > blob = [self trackerBlob:i];
            for(int u=0;u<blob.size();u++){
                ofCircle(blob[u].x, blob[u].y, 0.01);
                //   ofRect(blob[u].x*w, blob[u].y*h, 6,6);
                
            }
        }
        
        PopSurface();
    }
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{ 
    ofBackground(0,0,0);
    
    int n = [self numberTrackers];

    int w = ofGetWidth();
    int h = ofGetHeight();
    for(int i=0; i<n;i++){
        ofVec2f centroid = [self trackerCentroid:i];

        ofSetColor(255,255,255);
        ofCircle(centroid.x*w, centroid.y*h, 5);
        
        
        switch (i) {
			case 0:
				ofSetColor(255, 0, 0,255);
				break;
			case 1:
				ofSetColor(0, 255, 0,255);
				break;
			case 2:
				ofSetColor(0, 0, 255,255);
				break;
			case 3:
				ofSetColor(255, 255, 0,255);
				break;
			case 4:
				ofSetColor(0, 255, 255,255);
				break;
			case 5:
				ofSetColor(255, 0, 255,255);
				break;
				
			default:
				ofSetColor(255, 255, 255,255);
				break;
		}
        
        
        vector< ofVec2f > blob = [self trackerBlob:i];
        for(int u=0;u<blob.size();u++){
           ofCircle(blob[u].x*w, blob[u].y*h, 2);
         //   ofRect(blob[u].x*w, blob[u].y*h, 6,6);
            
        }
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

-(vector<ofVec2f>) trackerBlob:(int)n{
    vector<ofVec2f> v;

    // OSC Control blobs
    {
        vector<ofVec2f> blobs = [GetPlugin(OSCControl) getTrackerCoordinates];
        if(blobs.size() > n){
            ofVec2f p = [self trackerCentroid:n];

            CachePropF(generatedBlobPoints);
            CachePropF(generatedBlobSize);
            
            float aStep = TWO_PI / generatedBlobPoints;
            for(int i=0;i<generatedBlobPoints;i++){
                v.push_back(ofVec2f(sin(aStep*i), cos(aStep*i))*generatedBlobSize  * (sin(aStep*i*6) + 2)+ p );
            }
            return v;
        }
        n -= blobs.size();
    }
    
    // Control mouse 
    {
        if(controlMouse.x != -1){
            if(n == 0){
                CachePropF(generatedBlobPoints);
                CachePropF(generatedBlobSize);
                
                float aStep = TWO_PI / generatedBlobPoints;
                for(int i=0;i<generatedBlobPoints;i++){
                    v.push_back(ofVec2f(sin(aStep*i), cos(aStep*i))*generatedBlobSize * (sin(aStep*i*4) + 2.0) + controlMouse );
                }
                return v;
            }
            n --;            
        }
        
    }
    
    // Camera tracker
    {
        int num = [[GetPlugin(BlobTracker2d) getInstance:0] numPBlobs];
        if(num > n){
//            return *[[GetPlugin(BlobTracker2d) getInstance:0] getPBlob:n]->;
            
        }
        n -= num;
    }
    

    
    
    
    return v;
}

-(vector< vector<ofVec2f> >) trackerBlobVector{
    int n = [self numberTrackers];
    vector< vector<ofVec2f> > v;
    for(int i=0; i<n;i++){
        v.push_back([self trackerBlob:i]);
    }
    return v;
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
