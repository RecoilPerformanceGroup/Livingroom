#import "LEDGrid.h"
#import "Tracker.h"
#import <ofxCocoaPlugins/OpenDMX.h>

@implementation LEDGrid

-(void)initPlugin{
    [self addPropF:@"fillAdd"];    
    [self addPropF:@"fillAddMax"];    
    [[self addPropF:@"fillSet"] setMidiSmoothing:0.7];    
    [self addPropF:@"fade"];
    [self addPropF:@"tracker"];
    
    [[self addPropF:@"blur"] setMaxValue:20];
    [self addPropB:@"sendWhite"];
    [self addPropB:@"reset"];
    
    [[self addPropF:@"rectDrawX"] setMidiSmoothing:0.9];
    [[self addPropF:@"rectDrawY"] setMidiSmoothing:0.9];
    [[self addPropF:@"rectDrawA"] setMidiSmoothing:0.9];
    [[self addPropF:@"rectDrawSize"] setMidiSmoothing:0.9];
    
    [self addPropF:@"clouds"];
    
    [self addPropF:@"maskTop"];
    
    numGradients = 0;
}

//
//----------------
//


-(void)setup{
    int i=0;
    for(int y=0;y<8;y++){
        for(int x=0;x<8;x++){
            bool add = YES;
            if(y == 6 && x >= 2) add = NO;
            if(add){
                lamps[i].pos = ofVec2f(x/8.0, 1-(y+1)/8.0);
                lamps[i].color[0] = 1;
                lamps[i].color[1] = 1;
                lamps[i].color[2] = 1;
                lamps[i].color[3] = 0;
                lamps[i].channel = i*4;
                if(y == 7)
                    lamps[i].maxDim = 100;
                else
                    lamps[i].maxDim = 255;
                i++;
            }
        }
    }
    
    
    cvImage.allocate(GRID,GRID);
    cvImage.set(0);
    
    trackerFloat.allocate(GRID,GRID);
    
    mask.allocate(GRID,GRID);    
    
    cloudImage.allocate(GRID,GRID);
    tmpImage.allocate(GRID,GRID);
    
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

-(void) setGradients:(gradientVals*)_gradients num:(int)num{
    gradients = _gradients;
    numGradients = num;
}


-(void)update:(NSDictionary *)drawingInformation{
    if(PropB(@"reset")){
        [Prop(@"reset") setBoolValue:NO];
        cvImage.set(0);
    }
    
    cvImage.resetROI();
    cvImage += PropF(@"fillAdd");
    cvImage -= PropF(@"fade");
    
    ofxCvGrayscaleImage tracker = [GetPlugin(Tracker) trackerImageWithResolution:GRID];
    trackerFloat.set(0);
    trackerFloat = tracker;
    
    trackerFloat *= PropF(@"tracker");
    cvImage += trackerFloat;
    
    
    
    
    
    //Rect
    {
        if(PropF(@"rectDrawA") > 0){
            CachePropF(rectDrawX);
            CachePropF(rectDrawY);
            CachePropF(rectDrawA);
            CachePropF(rectDrawSize);
            
            
         //   tmpImage.set(0);
            int nPoints = 4;
            CvPoint _cp[4] = {
                {rectDrawX*GRID-rectDrawSize*GRID*0.5,rectDrawY*GRID-rectDrawSize*GRID*0.5}, 
                {rectDrawX*GRID+rectDrawSize*GRID*0.5,rectDrawY*GRID-rectDrawSize*GRID*0.5},
                {rectDrawX*GRID+rectDrawSize*GRID*0.5,rectDrawY*GRID+rectDrawSize*GRID*0.5},
                {rectDrawX*GRID-rectDrawSize*GRID*0.5,rectDrawY*GRID+rectDrawSize*GRID*0.5}};		
            
            CvPoint* cp = _cp; 
            cvFillPoly(cvImage.getCvImage(), &cp, &nPoints, 1, cvScalar(rectDrawA));
            
         //   cvImage += tmpImage;
            
        }
    }
    
    

    
    if(PropF(@"fillSet")){
        cvImage.set(PropF(@"fillSet"));
    }
    
    //Clouds
    {
        CachePropF(clouds);
        if(clouds > 0){
            cloudImage.set(0);
            for(int i=0;i<numGradients;i++){
                gradientVals gradient = gradients[i];
                
                if(gradient.val > 0){
                    
                    //  
                    
                    int nPoints = 4;
                    CvPoint _cp[4] = {
                        {gradient.x*GRID-0.8*gradient.size*GRID*0.5,gradient.y*GRID-0.8*gradient.size*GRID*0.5}, 
                        {gradient.x*GRID+0.8*gradient.size*GRID*0.5,gradient.y*GRID-0.8*gradient.size*GRID*0.5},
                        {gradient.x*GRID+0.8*gradient.size*GRID*0.5,gradient.y*GRID+0.8*gradient.size*GRID*0.5},
                        {gradient.x*GRID-0.8*gradient.size*GRID*0.5,gradient.y*GRID+0.8*gradient.size*GRID*0.5}};		
                    
                    CvPoint* cp = _cp; 
                    cvFillPoly(cloudImage.getCvImage(), &cp, &nPoints, 1, cvScalar(gradient.val));
                }
            }
            cloudImage *= clouds;
            cvImage -= cloudImage;
            
        }
    }
    
    cvThreshold(cvImage.getCvImage(), cvImage.getCvImage(), PropF(@"fillAddMax"), 255, CV_THRESH_TRUNC);
	cvThreshold(cvImage.getCvImage(), cvImage.getCvImage(), 0, 255, CV_THRESH_TOZERO);
    cvImage.flagImageChanged();
    
    if(PropF(@"blur"))
        cvImage.blur(PropF(@"blur"));
   
    
    
    //Mask top
    {
        CachePropF(maskTop);
        
        if(maskTop){
            int nPoints = 4;
            CvPoint _cp[4] = {
                {0,0}, 
                {GRID,0},
                {GRID,maskTop*GRID},
                {0,maskTop*GRID}};		
            
            CvPoint* cp = _cp; 
            cvFillPoly(cvImage.getCvImage(), &cp, &nPoints, 1, cvScalar(0));
        }
    }
    
    
    //----------------------------------------------------
    
    
    OpenDMX * dmx = GetPlugin(OpenDMX);
    CachePropB(sendWhite);
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
        
        if(sendWhite){
            [dmx setValue:lamps[i].color[0]*255.0 forChannel:1+lamps[i].channel+0];
            [dmx setValue:lamps[i].color[1]*255.0 forChannel:1+lamps[i].channel+1];
            [dmx setValue:lamps[i].color[2]*255.0 forChannel:1+lamps[i].channel+2];
        }
        [dmx setValue:lamps[i].color[3]*lamps[i].maxDim forChannel:1+lamps[i].channel+3];
        
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
