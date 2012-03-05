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
        
        [[self addPropF:@"triangleLine"]  setMidiSmoothing:0.8];
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

        [self addPropF:@"colorR"];
        [self addPropF:@"colorG"];
        [self addPropF:@"colorB"];
    }
    
    return self;
}

//
//----------------
//

-(void)setup{
    [Prop(@"video") setFloatValue:0];
    ofSetCircleResolution(200);
    
    moviePlayer = [[QTKitMovieRenderer alloc] init];
    BOOL loaded = [moviePlayer loadMovie:@"~/Movies/Shadow/export/Prolog.mp4" allowTexture:YES allowPixels:NO];
    
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
    
    if(PropB(@"video"))
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

    
    if(numTrackers == 0){
        trackingPoint = p;
    }
    
    
    ofVec2f _p = fixPoint*(1-PropF(@"tracking")) +trackingPoint * PropF(@"tracking");
    
    CachePropF(spotVideo);
    if(spotVideo && [moviePlayer movieSize].width > 0){
        ofVec2f trianglePoint = [GetPlugin(Mask) triangleFloorCoordinate:0];
        trianglePoint = [surface convertToProjection:trianglePoint];
//
//        glTranslated(trianglePoint.x*0.5,trianglePoint.y,0);
//        
//        glScaled(0.5,4.0/3.,1);
//        glRotated(PropF(@"videoRotation"),0,0,1);
//
//
        float videoAspect = [moviePlayer movieSize].width / [moviePlayer movieSize].height;

        ofVec2f videoSpotCenter = ofVec2f(282-[moviePlayer movieSize].width*0.5,380) / ofVec2f([moviePlayer movieSize].width , [moviePlayer movieSize].height);
        
     //   circleSize = circleSize * (1-spotVideo) + spotVideo* (PropF(@"videoScale")*([moviePlayer movieSize].width - 24)/[moviePlayer movieSize].width);
       circleSize = videoAspect*(PropF(@"videoScale")*([moviePlayer movieSize].width - 24 )/[moviePlayer movieSize].width);
        
        ofVec2f v1 = ofVec2f(videoSpotCenter.x*PropF(@"videoScale"),videoSpotCenter.y*PropF(@"videoScale")).rotate(PropF(@"videoRotation"));;
        v1 *= ofVec2f(1,4.0/3.0);
                                                                                                                   
        ofVec2f videoCenter = trianglePoint + v1;
//        videoCenter.rotate(PropF(@"videoRotation"), trianglePoint);

        _p = _p * (1.0-spotVideo) + videoCenter * spotVideo;
        
    }
    p = p*PropF(@"smoothing") + _p*(1-PropF(@"smoothing"));
    
    
    
    if(circleSize == 0){
        size = 0;
        filterSize.setStartValue(0);
    } else {
        size = filterSize.filter(circleSize);
    }
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
    ofSetColor(255*PropF(@"colorR"),255*PropF(@"colorG"),255*PropF(@"colorB"));
    
    ofEllipse(s.x*0.5, s.y, size*0.5, size*4.0/3.0);
    
    if(PropB(@"debug")){
        ofSetColor(255,255,0);
        ofCircle(top.x*0.5, top.y*4.0/3.0,0.01);
        ofCircle(bottom.x*0.5, bottom.y*4.0/3.0,0.01);
    }
    
    
    ApplySurface(@"Floor");

    ofFill();
    ofSetColor(0,0,0,255);
    ofRect(-1,-1,1,3);
    ofRect(1,-1,1,3);
    
    ofRect(-1,-1,3,1);
    ofRect(-1,1,3,1);

    PopSurface();

    
    
    CachePropF(triangleLine) 
    if(triangleLine > 0){
        ApplySurfaceForProjector(@"Triangle",PropI(@"triangleProjector"));{
            glLineWidth(10.0*PropF(@"triangleLineWidth"));
            ofSetColor(92,92,92);
            glBegin(GL_LINE_STRIP);
            glVertex2f(2,-1);
            glVertex2f((2.0-triangleLine*2),(triangleLine*2)-1);
            glEnd();
        } PopSurfaceForProjector();
    }
    
    CachePropF(video);
    if(video){
        ofEnableAlphaBlending();
        glColor4f(1.,1.,1.,video);
        ofVec2f trianglePoint = [GetPlugin(Mask) triangleFloorCoordinate:0];
        trianglePoint = [surface convertToProjection:trianglePoint];
        
        if(![moviePlayer rate]){
           // [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [moviePlayer setRate:1.0];
            [moviePlayer setPosition:0];
         //   }];
        }
        
        glPushMatrix();
        glTranslated(trianglePoint.x*0.5,trianglePoint.y,0);
        
        glScaled(0.5,4.0/3.,1);
        glRotated(PropF(@"videoRotation"),0,0,1);
        float videoAspect = [moviePlayer movieSize].width / [moviePlayer movieSize].height;
        //   glTranslated(-[moviePlayer movieSize].width*PropF(@"videoScale")*0.5,0,0);        
        [moviePlayer draw:NSMakeRect(-PropF(@"videoScale")*videoAspect*0.51,0,PropF(@"videoScale")*videoAspect,PropF(@"videoScale"))];
        
        glPopMatrix();
    } else {
        [moviePlayer setPosition:0];
        [moviePlayer setRate:0.0];
    }
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
