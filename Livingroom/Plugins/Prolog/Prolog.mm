#import "Prolog.h"
#import "Tracker.h"
#import "Mask.h"

@implementation Prolog

- (id)init{
    self = [super init];
    if (self) {
        [[self addPropF:@"circleSize"] setMaxValue:0.5];
        [Prop(@"circleSize") setMidiSmoothing:0.9];
        
      //  [[self addPropF:@"circleSizeMin"] setMidiSmoothing:0.99];
        //[[self addPropF:@"circleSizeMax"] setMidiSmoothing:0.99];
        
        [[self addPropF:@"aspect"] setMaxValue:2];
        
        [[self addPropF:@"triangleLine"]  setMidiSmoothing:0.99];
        [self addPropF:@"triangleLineWidth"];
        [self addPropF:@"triangleProjector"];
        
        [self addPropF:@"fixPositionX"];
        [self addPropF:@"fixPositionY"];
        [self addPropF:@"tracking"];
        
        [[self addPropF:@"trackingOffsetX"]setMidiSmoothing:0.8];
        [[self addPropF:@"trackingOffsetY"] setMidiSmoothing:0.8];

        [self addPropF:@"smoothing"];

        [self addPropB:@"debug"];
        
        [self addPropF:@"video"];
        [self addPropF:@"videoScale"];
        [[self addPropF:@"videoRotation"] setMinValue:-90 maxValue:90];
        
        [self addPropF:@"spotVideo"];
        
    }
    
    return self;
}

//
//----------------
//


-(void)setup{
    ofSetCircleResolution(200);
    
    moviePlayer = [[QTKitMovieRenderer alloc] init];
    BOOL loaded = [moviePlayer loadMovie:@"~/Movies/Shadow/export/Prototype_1.mp4" allowTexture:YES allowPixels:NO];
    
    if(!loaded){
        NSLog(@"Kunne ikke loade prolog video %@!!!!!!!!!!", [moviePlayer path]);
    }
    
    [moviePlayer setLoops:NO];
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    const CVTimeStamp * time;
    [[drawingInformation objectForKey:@"outputTime"] getValue:&time];	
    [moviePlayer update:time];
    //    vector<ofVec2f> centroids = [GetPlugin(Tracker) trackerCentroidVector];
    if(surface == nil){
        surface = Surface(@"Floor", 0);
    }
    
   // CachePropF(circleSizeMin);
   // CachePropF(circleSizeMax);
    CachePropF(circleSize);

    ofVec2f trackingPoint;
    ofVec2f fixPoint = p ;//[surface convertToProjection:ofVec2f(PropF(@"fixPositionX"), PropF(@"fixPositionY"))];
    
    ofVec2f trianglePoint = [GetPlugin(Mask) triangleFloorCoordinate:0];
    trianglePoint = [surface convertToProjection:trianglePoint];
    
//    ofVec2f videoPoint = ofVec2f(
    
    int numTrackers = [GetPlugin(Tracker) numberTrackers];
    if(numTrackers > 0){
        top=ofVec2f(-1,-1);
        bottom=ofVec2f(-1,-1);

        for(int i=0;i<numTrackers;i++){
            vector< ofVec2f > points = [GetPlugin(Tracker) trackerBlob:i];
           
            if(points.size() > 0){                
                for(int i=0;i<points.size();i++){
                    ofVec2f projp = [surface convertToProjection:points[i]];
                    if(top.y == -1 || projp.y > top.y){
                        top = projp;
                    }
                    if(bottom.y == -1 || projp.y < bottom.y){
                        bottom = projp;
                    }
                    
                    /*
                     //if reverse 
                     
                     if(top.y == -1 || projp.y < top.y){
                     top = projp;
                     }
                     if(bottom.y == -1 || projp.y > bottom.y){
                     bottom = projp;
                     }
                     
                     */
                    
                }
            }

        }
        
//        if(top.y != -1 > 0){
//            ofVec2f v = (top-bottom)*0.5+bottom;
//            
//            
//            top.y *= 3.0/4.0;
//            bottom.y *= 3.0/4.0;
//            float dist = top.distance(bottom);
//            
//            if(dist > circleSize){
//                float diff = dist - circleSize; 
//                
//                v -= (top-bottom).normalized()*diff*0.7;
//            }
//            trackingPoint = v + ofVec2f(PropF(@"trackingOffsetX"), PropF(@"trackingOffsetY"));;
//        }
        if(top.y != -1 > 0){
            ofVec2f v = top;
            
            
            top.y *= 3.0/4.0;
            bottom.y *= 3.0/4.0;
            float dist = top.distance(bottom);
            
            if(dist > circleSize){
                float diff = dist - circleSize; 
                
                v -= (top-bottom).normalized()*diff;
            }
            trackingPoint = v - ofVec2f(0,0.5*circleSize) - ofVec2f(PropF(@"trackingOffsetX"), PropF(@"trackingOffsetY"));;
        }
    }
    
    if(circleSize == 0){
        size = 0;
        filterSize.setStartValue(0);
    } else {
        size = filterSize.filter(circleSize);
    }
    
    
    if(numTrackers == 0){
        trackingPoint = p;
    }
    
    ofVec2f _p = fixPoint*(1-PropF(@"tracking")) +trackingPoint * PropF(@"tracking");
    
    p = p*PropF(@"smoothing") + _p*(1-PropF(@"smoothing"));
    //p.x = filterX.filter(_p.x);
    //p.y = filterY.filter(_p.y);
    
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    //    ofVec2f s = [surface convertToProjection:p];
    ofVec2f s = p;
    ofFill();
    ofSetColor(255,255,255);
    
    ofEllipse(s.x*0.5, s.y, size*0.5, 4.0/3.0*size*PropF(@"aspect"));
    
    if(PropB(@"debug")){
        ofSetColor(255,255,0);
        ofCircle(top.x*0.5, top.y*4.0/3.0,0.01);
        ofCircle(bottom.x*0.5, bottom.y*4.0/3.0,0.01);
    }
    
    CachePropF(triangleLine) 
    if(triangleLine > 0){
        ApplySurfaceForProjector(@"Triangle",PropI(@"triangleProjector"));{
            glLineWidth(10.0*PropF(@"triangleLineWidth"));
            ofSetColor(255,255,255);
            glBegin(GL_LINE_STRIP);
            glVertex2f(2,-1);
            glVertex2f((2.0-triangleLine*2),(triangleLine*2)-1);
            glEnd();
        } PopSurfaceForProjector();
    }
    
    CachePropF(video);
    if(video){
        ofVec2f trianglePoint = [GetPlugin(Mask) triangleFloorCoordinate:0];
        trianglePoint = [surface convertToProjection:trianglePoint];
        
        if(![moviePlayer rate]){
            [moviePlayer setRate:1.0];
            [moviePlayer setPosition:0];
        }
        
        glPushMatrix();
        glTranslated(trianglePoint.x*0.5,trianglePoint.y,0);
        glRotated(PropF(@"videoRotation"),0,0,1);
        [moviePlayer draw:NSMakeRect(0,0,PropF(@"videoScale")*0.5,PropF(@"videoScale")*4.0/3.)];
        
        glPopMatrix();
    } else {
        [moviePlayer setRate:0.0];
    }
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
