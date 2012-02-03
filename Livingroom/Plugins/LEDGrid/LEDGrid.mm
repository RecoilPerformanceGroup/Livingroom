#import "LEDGrid.h"

@implementation LEDGrid

- (id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
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
                i++;
            }
        }
    }
    
    
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
