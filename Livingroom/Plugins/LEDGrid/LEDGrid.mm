#import "LEDGrid.h"
#import "Tracker.h"
#import <ofxCocoaPlugins/OpenDMX.h>

@implementation LEDGrid

-(void)initPlugin{
    [self addPropF:@"fillAdd"];    
    [self addPropF:@"fade"];
    [self addPropF:@"tracker"];
    
}

//
//----------------
//


-(void)setup{
    int i=0;
    for(int x=0;x<8;x++){
        for(int y=0;y<7;y++){
            bool add = YES;
            if(y == 0 && x == 7) add = NO;
            if(y == 1 && x >= 3) add = NO;
            if(add){
                lamps[i].pos = ofVec2f(x/8.0, y/7.0);
                lamps[i].color[0] = 1;
                lamps[i].color[1] = 0;
                lamps[i].color[2] = 0;
                lamps[i].color[3] = 0;
                lamps[i].channel = i*4;
                i++;
            }
        }
    }
    
    
    cvImage.allocate(GRID,GRID);
    cvImage.set(0);
    
    trackerFloat.allocate(GRID,GRID);
    
    mask.allocate(GRID,GRID);    
    
    NSBundle *framework=[NSBundle bundleForClass:[self class]];
    NSString * path = [framework pathForResource:@"chess" ofType:@"jpg"];
    chessImage = new ofImage();
    bool imageLoaded = chessImage->loadImage([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if(!imageLoaded){
        NSLog(@"chessImage image not found!!");
    }
    
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    cvImage.resetROI();
    cvImage += PropF(@"fillAdd");
    cvImage -= PropF(@"fade");
    
    ofxCvGrayscaleImage tracker = [GetPlugin(Tracker) trackerImageWithResolution:GRID];
    trackerFloat.set(0);
    trackerFloat = tracker;
    
    trackerFloat *= PropF(@"tracker");
    cvImage += trackerFloat;
    
    
    
    cvThreshold(cvImage.getCvImage(), cvImage.getCvImage(), 1, 255, CV_THRESH_TRUNC);
	cvThreshold(cvImage.getCvImage(), cvImage.getCvImage(), 0, 255, CV_THRESH_TOZERO);
    cvImage.flagImageChanged();
    
    OpenDMX * dmx = GetPlugin(OpenDMX);
    for(int i=0;i<NUM_LAMPS;i++){
        mask.set(0);
        int nPoints = 4;
        CvPoint _cp[4] = {
            {lamps[i].pos.x*GRID,lamps[i].pos.y*GRID}, 
            {lamps[i].pos.x*GRID + GRID/8.0,lamps[i].pos.y*GRID},
            {lamps[i].pos.x*GRID + GRID/8.0,lamps[i].pos.y*GRID + GRID/8.0},
            {lamps[i].pos.x*GRID,lamps[i].pos.y*GRID + GRID/8.0}};		
        
        CvPoint* cp = _cp; 
        cvFillPoly(mask.getCvImage(), &cp, &nPoints, 1, cvScalar(255));
        mask.flagImageChanged();
        
        // cvImage = mask;
        
        lamps[i].color[3] = cvMean(cvImage.getCvImage(),mask.getCvImage());
        
        
        [dmx setValue:lamps[i].color[0]*255.0 forChannel:1+lamps[i].channel+0];
        [dmx setValue:lamps[i].color[1]*255.0 forChannel:1+lamps[i].channel+1];
        [dmx setValue:lamps[i].color[2]*255.0 forChannel:1+lamps[i].channel+2];

        [dmx setValue:lamps[i].color[3]*255.0 forChannel:1+lamps[i].channel+3];
        
    }
    
    
    
    
    
    
    /*
     //  cvImage.setROI(0, 0, 50, 50);
     
     
     */
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
    float w = ofGetWidth() - 40;
    float h = ofGetHeight() - 40;
    
    ofEnableAlphaBlending();
    ofSetColor(255,255,255,255);
    
    float i = 30;
    for(int x=0;x<i;x++){
        for(int y=0;y<i;y++){
            chessImage->draw((x/i)*w, (y/i)*h, w/i, h/i);
        }
    }
    
    
    ofFill();
    cvImage.draw(0,0,w,h);
    
    ofSetColor(50,50,50,150);
    ofRect(0,0,w,h);
    
    for(int i=0;i<NUM_LAMPS;i++){
        
        ofFill();
        ofSetColor(lamps[i].color[0]*255.0, lamps[i].color[1]*255.0, lamps[i].color[2]*255.0, lamps[i].color[3]*255.0);
        ofRect(lamps[i].pos.x * w + 5, lamps[i].pos.y * h + 5, 20, 20);
        
        ofSetLineWidth(2.0);
        ofNoFill();
        ofSetColor(0,0,0);
        ofRect(lamps[i].pos.x * w+5, lamps[i].pos.y * h + 5, 20, 20);
        ofSetLineWidth(1.0);
        
        
        
    }
}

@end
