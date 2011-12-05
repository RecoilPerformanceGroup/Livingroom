#import "PolyEngine.h"
#import "PolygonWorld.h"
#import <ofxCocoaPlugins/Keystoner.h>

@implementation PolygonWorld

- (id)init{
    self = [super init];
    if (self) {
        polyEngine = [[PolyEngine alloc] init];
    }
    
    return self;
}

-(void)draw:(NSDictionary *)drawingInformation{
    ofBackground(0, 0, 0);
    [polyEngine draw:drawingInformation];
    
    ofColor(255,0,0,255);
    ofCircle(cMouseX, cMouseY, 0.01);

}

-(void)update:(NSDictionary *)drawingInformation{
    [polyEngine update:drawingInformation];

}

-(void)controlDraw:(NSDictionary *)drawingInformation{    
    ofBackground(0, 0, 0);
    ofSetColor(0,0,0);

    glScaled(ofGetWidth(), ofGetHeight(),1);
    
    cW = ofGetWidth();
    cH = ofGetHeight();

    [polyEngine controlDraw:drawingInformation];

}

-(void)controlMousePressed:(float)x y:(float)y button:(int)button{
    [polyEngine controlMousePressed:x/cW y:y/cH button:button];
}
-(void)controlMouseReleased:(float)x y:(float)y{
    [polyEngine controlMouseReleased:x/cW y:y/cH];
}

-(void)controlKeyPressed:(int)key modifier:(int)modifier{
    [polyEngine controlKeyPressed:key modifier:modifier];
}

-(void)controlMouseMoved:(float)x y:(float)y {
    x /= cW;
    y /= cH;
    
    cMouseX = x;
    cMouseY = y;

}
    
-(void)controlMouseDragged:(float)x y:(float)y button:(int)button {
    
    [polyEngine controlMouseDragged:x/cW y:y/cH button:button];
    
    x /= cW;
    y /= cH;
    
    cMouseX = x;
    cMouseY = y;
}

- (IBAction)saveArrangement:(id)sender {
    [[polyEngine arrangement] saveArrangement];
}

- (IBAction)loadArrangement:(id)sender {
    [[globalController openglLock] lock];
    [[polyEngine arrangement] loadArrangement];
        [[globalController openglLock] unlock];
}
@end
